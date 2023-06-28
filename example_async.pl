#!/usr/bin/perl

use Mojo::Base qw(-strict -signatures -async_await);
use Mojo::IOLoop::Subprocess;
use Mojo::Promise;
use Mojo::Util qw(steady_time);

async sub count {
    say "One";
    await Mojo::Promise->new->timer(1);
    #    await Mojo::IOLoop::Subprocess->run_p(sub {
    #        sleep(1);
    #   });
    say "Two";
}

async sub main {
    await Mojo::Promise->map({concurrency=>3}, sub {
            count();
        }, 1..3);
}

my $s = steady_time;
await main();
say steady_time - $s;
