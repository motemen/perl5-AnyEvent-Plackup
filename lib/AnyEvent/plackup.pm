package AnyEvent::plackup;
use strict;
use warnings;
use 5.008_001;
use overload (
    '""' => 'origin',
    fallback => 1
);

use AnyEvent;
use Twiggy::Server;
use Test::TCP qw(empty_port);
use Scalar::Util qw(weaken);
use Carp;

use Class::Accessor::Lite (
    ro => [
        'host', 'port',
        'ready_cv', 'request_cv',
        'twiggy',
    ],
);

use Exporter::Lite;

our $VERSION = '0.01';
our @EXPORT = qw(plackup);

sub plackup (@) {
    return __PACKAGE__->new(@_);
}

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        app  => delete $args{app},
        args => \%args,
    }, $class;
    $self->_run;
    return $self;
}

sub recv {
    my $self = shift;
    my $cv = $self->request_cv
        or croak 'request_cv not set; maybe specified app?';
    $self->{request_cv} = AE::cv if $cv->ready; # reset
    return $cv->recv;
}

sub origin {
    my $self = shift;
    return sprintf "http://%s:%s", $self->host, $self->port;
}

sub _run {
    my $self = shift;

    weaken $self;

    $self->{ready_cv} = AE::cv;

    my $app = $self->{app} || $self->_mk_default_app;

    my $twiggy = Twiggy::Server->new(
        port => $self->{port} || empty_port(),
        %{ $self->{args} || {} },
        server_ready => sub {
            my $args = shift;

            $self->{host} = $args->{host};
            $self->{port} = $args->{port};

            $self->ready_cv->send($args);
        }
    );
    $twiggy->register_service($app);

    $self->{twiggy} = $twiggy;
}

sub _mk_default_app {
    my $self = shift;

    $self->{request_cv} = AE::cv;

    require AnyEvent::plackup::Request;

    return sub {
        my ($env) = @_;

        my $req = AnyEvent::plackup::Request->new($env);

        $self->request_cv->send($req);

        return sub {
            my $respond = shift;
            $req->_response_cv->cb(sub {
                my $res = $_[0]->recv;
                if (ref $res eq 'CODE') {
                    $res->($respond);
                } else {
                    $respond->($res);
                }
            });
        };
    };
}

sub DESTROY {
    my $self = shift;
    local $@;
    $self->{twiggy}->{exit_guard}->end;
}

1;

__END__

=head1 NAME

AnyEvent::plackup - Easily establish an HTTP server inside a program

=head1 SYNOPSIS

  use AnyEvent::plackup;

  my $server = plackup(); # port is automatically chosen
  my $req = $server->recv; # isa Plack::Request

  my $value = $req->parameters->{foo};

  $req->respond([ 200, [], [ 'OK' ] ]);

  # or specify PSGI app:

  my $server = plackup(app => \&app);

=head1 DESCRIPTION

AnyEvent::plackup provides functionality of establishing an HTTP server inside a program using L<Twiggy>. If not specified, open port is automatically chosen.

=head1 FUNCTIONS

=over 4

=item my $server = AnyEvent::plackup->new([ app => \&app, port => $port, %args ])

=item my $server = plackup([ app => \&app, port => $port, %args ])

Creates and starts an HTTP server. Internally calls C<new> and C<run>.

If I<app> is not specified, C<< $server->recv >> is available and you should respond this manually.

=item my $req = $server->recv

Waits until next request comes. Returns an C<AnyEvent::plackup::Request> (isa C<Plack::Request>).

=item my $origin = $server->origin, "$server"

Returns server's origin. e.g. C<"http://0.0.0.0:8290">.

=back

=head1 AUTHOR

motemen E<lt>motemen@gmail.comE<gt>

=head1 SEE ALSO

L<Twiggy>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
