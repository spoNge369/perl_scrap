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

$concurrency = 10 if $concurrency == 0;

open my $fh, '<', $wordlist or die "Failed to open file: $wordlist";
chomp( my @diccionario = <$fh> );

my @urlsdata = map {"https://api.hackertarget.com/hostsearch/?q=$_"} @diccionario;
my @urlsdata2 = map {"https://urlscan.io/api/v1/search/?q=$_"} @diccionario;

#push @urlsdata, @urlsdata2;

my $ua = Mojo::UserAgent->new;

my $get_fast = Mojo::Promise->map( { concurrency => $concurrency }, sub { $ua->get_p($_) }, @urlsdata )
        ->then( sub { for (@_) { if ($_->[0]->result->body=~/.+/gi) { 


                                my $body = $_->[0]->result->body;

                                my @domain = $body=~/(.+)\,.*/gi;


                                my $domain = join("\n", @domain);


                                open(BODY, '>', "./output.txt") or die $!;
                                print BODY $domain;



                        } } } );
  
$get_fast->wait;


my $ua2 = Mojo::UserAgent->new;

my $get_fast1 = Mojo::Promise->map( { concurrency => $concurrency }, sub { $ua2->get_p($_) }, @urlsdata2 )
        ->then( sub { for (@_) {

                        my $body = $_->[0]->result->body;

                        my @domain = $body=~/\s*.*\"domain\": \"(.*)\".*\s+/gi;

                        my $domain = join("\n", @domain);

                        open(BODY1, '>>', "./output.txt") or die $!;
                        print BODY1 $domain;

                }


                } );
  
$get_fast1->wait;
