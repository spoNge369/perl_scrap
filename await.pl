#!/usr/bin/perl

use Mojo::Base qw(-strict -signatures -async_await);
use Mojo::Promise;
use Mojo::UserAgent;
use Mojo::Util qw(dumper trim);
use Mojo::IOLoop::Subprocess;

my $ua = Mojo::UserAgent->new;
my @urls = map{"http://ffuf.me/cd/pipes/user?id=$_"} 300..1000;

async sub get_title_p($url) {
    my $tx = await $ua->get_p($url);
    return $tx->res->body;
}

async sub main(@urls) {
    my @titles = await Mojo::Promise
        ->map({concurrency=>20}, sub {
                        get_title_p($_) }, @urls);

    foreach my $l (map{$_->[0]} @titles) {
        say $l;
        #await Mojo::Promise->timer(0.5);
    }
}

await main(@urls);
