use inc::Module::Install;

name 'AnyEvent-plackup';
all_from 'lib/AnyEvent/plackup.pm';

tests 't/*.t';
author_tests 'xt';

requires 'AnyEvent';
requires 'Twiggy';
requires 'Test::TCP';
requires 'Plack::Request';
requires 'Scalar::Util';
requires 'Carp';
requires 'Exporter::Lite';

test_requires 'Test::More';
test_requires 'Test::SharedFork';

auto_set_repository;
auto_include_deps;

readme_markdown_from 'lib/AnyEvent/plackup.pm';

if ($Module::Install::AUTHOR) {
    require File::Copy;
    File::Copy::mv('README.mkdn', 'README.md');
}

WriteAll;
