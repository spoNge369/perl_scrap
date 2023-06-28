#!/usr/bin/perl

use Mojo::Base qw(-strict -signatures);
use Mojo::UserAgent;
use Mojo::Util qw(getopt);

my $concurrency;
my $tokken;

getopt
    'c|concurrency=i' => \$concurrency,
    't|tokken=s' => \$tokken;

my $ua = Mojo::UserAgent->new;

my $headers = {
    "User-Agent" => "Mozilla/5.0 (X11; Linux x86_64; rv:102.0) Gecko/20100101 Firefox/102.0",
    "Host"       => "url[.]com",
    "Access_token" => $tokken,
    "Client_id" => "9b5c477f-c121-3f7b-9ce5-faede440c13b"
};


my @id = map{$_}971078..971100;

my $get_fast = Mojo::Promise->map({concurrency=>$concurrency}, sub {
                $ua->get_p(
                "https://url[.]com/$_"
                        => $headers)
                }, @id)
                ->then(
                        sub{
                            say $_->[0]->res->body foreach @_;

                        });

$get_fast->wait;
