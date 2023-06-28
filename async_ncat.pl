#!/usr/bin/perl

use Mojo::Base qw(-strict -signatures -async_await);
use Mojo::IOLoop::Subprocess;


my $listen=Mojo::IOLoop::Subprocess->new->run_p(sub {
        system("nc -nvlp 1212");
    });

my $resp=Mojo::IOLoop::Subprocess->new->run_p(sub {
        system("echo 'enviendo data'|nc 127.0.0.1 1212");
    });
await $resp;
