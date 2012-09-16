use strict;
use warnings;
use Test::More tests => 4;
use Test::SharedFork;
use AnyEvent::plackup;
use LWP::Simple qw($ua);

my $server = plackup();

if (my $pid = fork()) {
    my $req = $server->recv;
    is $req->parameters->{foo}, 'bar';
    is $req->uri->path, '/test';
    $req->respond([ 200, [], [ 'AnyEvent::plackup' ] ]);
    waitpid $pid, 0;
} else {
    my $res = $ua->get("$server/test?foo=bar");
    is $res->code, 200;
    is $res->content, 'AnyEvent::plackup';
}

done_testing;
