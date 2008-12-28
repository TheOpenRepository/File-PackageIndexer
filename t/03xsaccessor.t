use strict;
use warnings;

use Test::More tests => 24;
BEGIN { use_ok('File::PackageIndexer') };

my $indexer = File::PackageIndexer->new();
isa_ok($indexer, 'File::PackageIndexer');

my @tests = (
  {
    name => 'empty',
    code => <<'HERE',
HERE
    'cmp' => undef,
  },
  {
    name => 'simple',
    code => <<'HERE',
sub foo {}
HERE
    'cmp' => {
      main => { name => 'main', subs => {foo => 1} },
    },
  },
  {
    name => 'empty xsa',
    code => <<'HERE',
sub foo {}
use Class::XSAccessor;
HERE
    'cmp' => {
      main => { name => 'main', subs => {foo => 1} },
    },
  },
  {
    name => 'simple xsa constructor',
    code => <<'HERE',
sub foo {}
use Class::XSAccessor
  constructor => 'bar';
HERE
    'cmp' => {
      main => { name => 'main', subs => {foo => 1, bar => 1} },
    },
  },
  {
    name => 'simple xsa getter',
    code => <<'HERE',
use Class::XSAccessor
  getters => { bar => 'bar' };

sub foo {}
HERE
    'cmp' => {
      main => { name => 'main', subs => {foo => 1, bar => 1} },
    },
  },
  {
    name => 'simple xsa getters',
    code => <<'HERE',
use Class::XSAccessor
  getters => { bar => 'bar',
  baz => 'buz' };

sub foo {}
HERE
    'cmp' => {
      main => { name => 'main', subs => {foo => 1, bar => 1, baz => 1} },
    },
  },
  {
    name => 'xsa1',
    code => <<'HERE',
use Class::XSAccessor
  getters => { bar => 'bar',
  baz => 'buz' },
  setters => { frob => 'nicate' };

sub foo {}
HERE
    'cmp' => {
      main => { name => 'main', subs => {foo => 1, bar => 1, baz => 1, frob => 1} },
    },
  },
  {
    name => 'xsa constructors',
    code => <<'HERE',
use Class::XSAccessor
  constructors => ['new', 'spawn'],
  getters => { bar => 'bar',
  baz => 'buz' },
  setters => { frob => 'nicate' };

sub foo {}
HERE
    'cmp' => {
      main => { name => 'main', subs => {foo => 1, bar => 1, baz => 1, frob => 1, 'new' => 1, spawn => 1} },
    },
  },
  {
    name => 'xsa constructors, option',
    code => <<'HERE',
use Class::XSAccessor
  constructors => ['new', 'spawn'],
  getters => { bar => 'bar',
  baz => 'buz' },
  setters => { frob => 'nicate' },
  replace => 1;

sub foo {}
HERE
    'cmp' => {
      main => { name => 'main', subs => {foo => 1, bar => 1, baz => 1, frob => 1, 'new' => 1, spawn => 1} },
    },
  },
  {
    name => 'xsa constructors, option, package',
    code => <<'HERE',
package Bar;
use Class::XSAccessor
  constructors => ['new', 'spawn'],
  getters => { bar => 'bar',
  baz => 'buz' },
  setters => { frob => 'nicate' },
  replace => 1;

sub foo {}
HERE
    'cmp' => {
      Bar => { name => 'Bar', subs => {foo => 1, bar => 1, baz => 1, frob => 1, 'new' => 1, spawn => 1} },
    },
  },
  {
    name => 'xsa constructors, option, packages',
    code => <<'HERE',
package Bar;
use Class::XSAccessor
  constructors => ['new', 'spawn'],
  getters => { bar => 'bar',
  baz => 'buz' },
  setters => { frob => 'nicate' },
  replace => 1;

package Bar2;
use Class::XSAccessor
  constructors => ['new', 'spawn'],
  replace => 1;
sub foo {}
HERE
    'cmp' => {
      Bar => { name => 'Bar', subs => {bar => 1, baz => 1, frob => 1, 'new' => 1, spawn => 1} },
      Bar2 => { name => 'Bar2', subs => {foo => 1, 'new' => 1, spawn => 1} },
    },
  },
  {
    name => 'xsa constructors, option, packages, class',
    code => <<'HERE',
package Bar;
use Class::XSAccessor
  constructors => ['new', 'spawn'],
  getters => { bar => 'bar',
  baz => 'buz' },
  setters => { frob => 'nicate' },
  replace => 1;

package Bar2;
use Class::XSAccessor
  class => qq{Fun},
  constructors => ['new', 'spawn'],
  replace => 1;
sub foo {}
HERE
    'cmp' => {
      Bar => { name => 'Bar', subs => {bar => 1, baz => 1, frob => 1, 'new' => 1, spawn => 1} },
      Bar2 => { name => 'Bar2', subs => {foo => 1} },
      Fun => { name => 'Fun', subs => {'new' => 1, spawn => 1} },
    },
  },


  {
    name => 'empty xsaa',
    code => <<'HERE',
sub foo {}
use Class::XSAccessor::Array;
HERE
    'cmp' => {
      main => { name => 'main', subs => {foo => 1} },
    },
  },
  {
    name => 'simple xsaa constructor',
    code => <<'HERE',
sub foo {}
use Class::XSAccessor::Array
  constructor => 'bar';
HERE
    'cmp' => {
      main => { name => 'main', subs => {foo => 1, bar => 1} },
    },
  },
  {
    name => 'simple xsaa getter',
    code => <<'HERE',
use Class::XSAccessor::Array
  getters => { bar => 0 };

sub foo {}
HERE
    'cmp' => {
      main => { name => 'main', subs => {foo => 1, bar => 1} },
    },
  },
  {
    name => 'simple xsaa getters',
    code => <<'HERE',
use Class::XSAccessor::Array
  getters => { bar => 1,
  baz => 0, };

sub foo {}
HERE
    'cmp' => {
      main => { name => 'main', subs => {foo => 1, bar => 1, baz => 1} },
    },
  },
  {
    name => 'xsaa1',
    code => <<'HERE',
use Class::XSAccessor::Array
  getters => { bar => 0,
  baz => 1 },
  setters => { frob => 2 };

sub foo {}
HERE
    'cmp' => {
      main => { name => 'main', subs => {foo => 1, bar => 1, baz => 1, frob => 1} },
    },
  },
  {
    name => 'xsaa constructors',
    code => <<'HERE',
use Class::XSAccessor::Array
  constructors => ['new', 'spawn'],
  getters => { bar => 0,
  baz => 1 },
  setters => { frob => 2 };

sub foo {}
HERE
    'cmp' => {
      main => { name => 'main', subs => {foo => 1, bar => 1, baz => 1, frob => 1, 'new' => 1, spawn => 1} },
    },
  },
  {
    name => 'xsaa constructors, option',
    code => <<'HERE',
use Class::XSAccessor::Array
  constructors => ['new', 'spawn'],
  getters => { bar => 0,
  baz => 1 },
  setters => { frob => 2 },
  replace => 1;

sub foo {}
HERE
    'cmp' => {
      main => { name => 'main', subs => {foo => 1, bar => 1, baz => 1, frob => 1, 'new' => 1, spawn => 1} },
    },
  },
  {
    name => 'xsaa constructors, option, package',
    code => <<'HERE',
package Bar;
use Class::XSAccessor::Array
  constructors => ['new', 'spawn'],
  getters => { bar => 0,
  baz => 1 },
  setters => { frob => 2, },
  replace => 1;

sub foo {}
HERE
    'cmp' => {
      Bar => { name => 'Bar', subs => {foo => 1, bar => 1, baz => 1, frob => 1, 'new' => 1, spawn => 1} },
    },
  },
  {
    name => 'xsaa constructors, option, packages',
    code => <<'HERE',
package Bar;
use Class::XSAccessor::Array
  constructors => ['new', 'spawn'],
  getters => { bar => 1,
  baz => 2 },
  setters => { frob => 0 },
  replace => 1;

package Bar2;
use Class::XSAccessor::Array
  constructors => ['new', 'spawn'],
  replace => 1;
sub foo {}
HERE
    'cmp' => {
      Bar => { name => 'Bar', subs => {bar => 1, baz => 1, frob => 1, 'new' => 1, spawn => 1} },
      Bar2 => { name => 'Bar2', subs => {foo => 1, 'new' => 1, spawn => 1} },
    },
  },
  {
    name => 'xsaa constructors, option, packages, class',
    code => <<'HERE',
package Bar;
use Class::XSAccessor::Array
  constructors => ['new', 'spawn'],
  getters => { bar => 0,
  baz => 1},
  setters => { frob => 2},
  replace => 1;

package Bar2;
use Class::XSAccessor::Array
  class => qq{Fun},
  constructors => ['new', 'spawn'],
  replace => 1;
sub foo {}
HERE
    'cmp' => {
      Bar => { name => 'Bar', subs => {bar => 1, baz => 1, frob => 1, 'new' => 1, spawn => 1} },
      Bar2 => { name => 'Bar2', subs => {foo => 1} },
      Fun => { name => 'Fun', subs => {'new' => 1, spawn => 1} },
    },
  },
);

foreach my $test (@tests) {
  my $name = $test->{name};
  my $code = $test->{code};
  my $ref = $test->{"cmp"};
  my $index = $indexer->parse($code);
  is_deeply($index, $ref, "equivalence test: $name");
}

