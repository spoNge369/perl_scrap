#!/usr/bin/perl

use Mojo::Base qw(-strict -signatures);
use Mojo::Util qw(dumper trim getopt) ;
use Mojo::Collection qw(c);
use Mojo::UserAgent;
use Mojo::URL;

my $ua = Mojo::UserAgent->new;
#$ua->proxy->http("http://127.0.0.1:8080")->https("http://127.0.0.1:8080");


my $request = '';
my $protocol = '';
my $url = '';
my $path = '';

getopt
    'r|request=s' => \$request,
    'p|protocol=s'  => \$protocol;

$request = "req.txt" if($request eq '');
$protocol = "https" if($protocol eq '');

open my $fh, '<', $request or die "Failed to open file: $request";
my @r = <$fh>;

@r = grep{s/\r\n|\n//g; /\S/} @r;

#say dumper @r;
my $headers = {};

#my ($path) = $r[0]=~/\w+ (.+) .*/g;
#say trim $path;



sub reqBurp {
    my ($header, @req) = @_;

    ($path) = $req[0]=~/\w+\s(\/.*)\s.*/g;

        foreach my $e (@req) {
            if($e=~/\w+: .+/) {
                my ($key, $value) = $e=~/(^.+):\s(.+)/g;
            #say dumper $value;
            $header->{$key}=$value;
            }

        }

}

sub main {
    reqBurp($headers, @r);
    $url = $protocol."://".$headers->{Host}.$path;
    #say dumper $url;
    say $ua->get($url => $headers)->res->body;
}

main();
