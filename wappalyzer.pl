#!perl

use Mojo::Base qw(-strict -signatures -async_await);
use WWW::Wappalyzer;
use Mojo::UserAgent;
use Mojo::Promise;
use List::Util qw(pairmap);
use Mojo::Util qw(dumper);
use LWP::UserAgent;
use Data::Dumper;
use Mojo::Collection qw(c);

my $ua = Mojo::UserAgent->new;
$ua     = $ua->max_redirects(1);

my $resp = await $ua->insecure(1)->get_p("http://www.drupal.org");

my %params = (
    html    => $resp->res->body,
    headers => $resp->res->headers->to_hash 
);
    
my @wappalyzer = WWW::Wappalyzer->new->detect(%params);

#my $pairs = {pairmap {$a => $b->[0]} @wappalyzer};#hash key 1er elemento => value 2do elemento, asi sucesivamente
#el $b->[0] es solo si quiero el primer elemento del array de los 2do elementos...
my $pairs = {pairmap {$a => $b} @wappalyzer};
say Dumper $pairs;
