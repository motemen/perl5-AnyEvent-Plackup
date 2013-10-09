requires 'AnyEvent';
requires 'Carp';
requires 'Class::Accessor::Lite';
requires 'Exporter::Lite';
requires 'Plack::Request';
requires 'Scalar::Util';
requires 'Test::TCP', 2;
requires 'Twiggy';
requires 'parent';
requires 'perl', '5.008001';

on build => sub {
    requires 'ExtUtils::MakeMaker', '6.59';
    requires 'Test::More';
};
