package AnyEvent::plackup::Request;
use strict;
use warnings;
use parent 'Plack::Request';
use AnyEvent;

sub respond {
    my ($self, $psgi_res) = @_;
    $self->response_cv->send($psgi_res);
}

sub response_cv {
    my $self = shift;
    return $self->env->{'anyevent.plackup.response_cv'} ||= AE::cv;
}

1;
