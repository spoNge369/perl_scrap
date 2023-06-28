#!/usr/bin/perl
#
use Term::ANSIColor qw(:constants);
use Mojo::Base qw( -strict -signatures );
use Mojo::Promise;
use Mojo::UserAgent;
use Getopt::Long;


my $wordlist = '';
my $concurrency = 0;

GetOptions ( 'wordlist|w=s' => \$wordlist, 'concurrency|c=i' => \$concurrency );

$concurrency = 40 if $concurrency == 0;

open my $fh, '<', $wordlist or die "Failed to open file: $wordlist";
chomp( my @diccionario = <$fh> );

my @urlsdata = map {"http://ffuf.me/cd/basic/$_"} @diccionario;



my $ua = Mojo::UserAgent->new;
$ua->max_connections(50_000);
$ua->inactivity_timeout(40);
$ua->connect_timeout(5);

my $get_fast = Mojo::Promise->map( { concurrency => $concurrency }, sub { $ua->get_p($_) }, @urlsdata )
        ->then( sub { for (@_) { if ($_->[0]->res->code == 200) { #just result with code == 200

                                        my $url = $_->[0]->result->to_string;
                                        say $url;

                                } } } );
  
$get_fast->wait;
