#!/usr/bin/perl

use Mojo::Base qw(-strict -signatures);
use Term::ANSIColor qw(:constants);
use Mojo::Util qw(getopt dumper);
use Mojo::Promise;
use Mojo::UserAgent;

binmode(STDOUT, "encoding( UTF-8 )");

my $concurrency=1;
my $wordlist = '';

getopt
    'c|concurrency=i' => \$concurrency,
    'w|wordlist=s' => \$wordlist;

my $ua = Mojo::UserAgent->new;
#$ua->proxy
#    ->http('socks://127.0.0.1:9050')
#    ->https('socks://127.0.0.1:9050');
#$ua->proxy
#    ->http('http://127.0.0.1:8080')
#    ->https('http://127.0.0.1:8080');

#$ua->max_redirects(5);
#$ua->max_connections(0);
#$ua->request_timeout(0.4);

my $headers = {
    "User-Agent" => "Mozilla/5.0 (X11; Linux x86_64; rv:102.0) Gecko/20100101 Firefox/102.0",
    "Host"       => "search.illicit.services",
    "Accept-Encoding" => "gzip, deflate",
    "Accept" => "*/*",
    "Connection" => "keep-alive",
};

my @users = qw(s4vitar);
#say dumper @users;

sub usernames {
        my $get_fast = Mojo::Promise->map({concurrency=>$concurrency}, sub {
                $ua
            ->get_p(
                    "https://search.illicit.services/records?usernames=$_" 
#"https://httpbin.org/get"
#                    "http://ifconfig.co"
                        => $headers)
                }, @users)
                ->then(
                        sub{
                        foreach (@_) {
                            #my @user = split "=", $_->[0]->req->url->query;
                            #say $user[1];

                             say $_->[0]->res->dom->find('dd')
                                ->map('text')->join("\n");
# say $_->[0]->req->to_string;
                        }


                        });

    $get_fast->wait;
}

sub main {
    usernames();
}

main();
