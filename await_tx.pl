#!/usr/bin/perl

use Mojo::Base qw(-strict -signatures -async_await);
use Mojo::UserAgent;
use Mojo::Promise;
use Mojo::Util qw(steady_time);

my $ua=Mojo::UserAgent->new;
my $t = Mojo::UserAgent::Transactor->new;
#$ua->proxy->http("http://127.0.0.1:8080")->https("http://127.0.0.1:8080");
$ua->connect_timeout(4)->inactivity_timeout(5)->request_timeout(5);#2.8 a ~3.7seg

my @urls = map{"http://ffuf.me/cd/pipes/user?id=$_"} 1..1000;
my $cont=0;

async sub get_txp($url) {

    my $tx = $t->tx("GET" => $url); # <PROTOCOLO-string> => <URL-string> => <HEADERS-hash> => <BODY-string>
    $tx->req->headers->remove('Accept-Encoding');
    await $ua->insecure(1)->start_p($tx);

    #say $tx->req->url. " " . $tx->res->body;
    my $body=$tx->res->body;
    
    if ($body!~/Not Found/i) {
       say $tx->req->url . " " . $body;
       say steady_time-$time;
       say "requests enviadas: $cont";
       exit;
    }
    $cont++
}

async sub main(@urls) {
    await Mojo::Promise->map({concurrency => 100}, sub {
            get_txp($_)
        }, @urls);
}

my $time = steady_time;
await main(@urls);
say steady_time-$time;
say "Requests Hechas: $cont";
