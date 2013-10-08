requires 'AnyEvent';
requires 'Carp';
requires 'Exporter::Lite';
requires 'Plack::Request';
requires 'Scalar::Util';
requires 'Test::TCP';
requires 'Twiggy';
requires 'perl', '5.008001';

on build => sub {
    requires 'ExtUtils::MakeMaker', '6.59';
    requires 'Test::More';
};
