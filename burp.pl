#!/usr/bin/perl

use Mojo::Base qw(-strict -signatures);
use Mojo::Util qw(dumper trim getopt) ;
use Mojo::Collection qw(c);
use Mojo::UserAgent;
use Mojo::URL;

my $ua = Mojo::UserAgent->new;
my $t = Mojo::UserAgent::Transactor->new;
#$ua->proxy->http("http://127.0.0.1:8080")->https("http://127.0.0.1:8080");

my $protocol = '';
my $url = '';
my $path = '';
my $method;

getopt
    'r|request=s' => \my $request,
    'p|protocol=s'  => \$protocol;

!defined($request) and say "Colocar -r request_burl.txt" and exit 1;
$protocol = "https" if($protocol eq '');

open my $fh, '<:raw', $request or die "Failed to open file: $request";
my @r = <$fh>;

@r = grep{s/\r\n|\n//g; /\S/} @r;

#say dumper @r;
my $headers = {};
my $body;

#my ($path) = $r[0]=~/\w+ (.+) .*/g;
#say trim $path;


sub reqBurp($header, @req) {
    ($method, $path) = $req[0]=~/^(\w+)\s(\/.*)\s.*/g;

    if($method =~/POST|PUT|PATCH|DELETE/) {
        $body = $req[-1];
        @req = map{$req[$_]}1..$#req-1;
    } elsif($method eq "GET") {
        $body="";
        @req = map{$req[$_]}1..$#req;

    }

    foreach my $e (@req) {
        if($e=~/^\w.+: .+/) {
            my ($key, $value) = $e=~/(^.+):\s(.+)/g;
            #say dumper $value;
            $header->{$key}=$value;
        }
    }

}

sub main {
    reqBurp($headers, @r);
    $url = $protocol."://".$headers->{Host}.$path;
    #say dumper $url
    my $tx = $t->tx($method => $url => $headers => $body);
    $ua->insecure(1)->start($tx);

    say $tx->req->to_string;
    say $tx->res->to_string;
}

main();
