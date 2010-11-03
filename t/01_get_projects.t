use strict;
use warnings;
use utf8;

use Test::More;
use Test::TCP;
use Plack::Loader;

use WebService::Backlog;
use Encode;

my $app = sub {
    my $env = shift;
    local $/;
    my $content = <DATA>;
    return [ 200, [ 'Content-Type' => 'text/xml' ], [ encode_utf8($content) ] ];
};

test_tcp(
    client => sub {
        my $port    = shift;
        my $backlog = WebService::Backlog->new(
            url      => "http://127.0.0.1:$port/XML-RPC",
            username => 'guest',
            password => 'guest',
        );
        my $projects = $backlog->getProjects;
        is( scalar( @{$projects} ), 1 );
        is( $projects->[0]->id,     20 );
        is( $projects->[0]->key,    'DORA' );
        is( $projects->[0]->name,
            decode_utf8('ネコ型ロボット製造計画') );
        is( $projects->[0]->url, 'https://demo.backlog.jp/projects/DORA' );
    },
    server => sub {
        my $port = shift;
        Plack::Loader->auto( port => $port, host => '127.0.0.1' )->run($app);
    },
);

done_testing;

__DATA__
<?xml version="1.0" encoding="utf-8"?>
<methodResponse>
  <params>
    <param>
      <value>
        <array>
          <data>
            <value>
              <struct>
                <member>
                  <name>url</name>
                  <value>
                    <string>https://demo.backlog.jp/projects/DORA</string>
                  </value>
                </member>
                <member>
                  <name>name</name>
                  <value>
                    <string>ネコ型ロボット製造計画</string>
                  </value>
                </member>
                <member>
                  <name>id</name>
                  <value>
                    <i4>20</i4>
                  </value>
                </member>
                <member>
                  <name>key</name>
                  <value>
                    <string>DORA</string>
                  </value>
                </member>
              </struct>
            </value>
          </data>
        </array>
      </value>
    </param>
  </params>
</methodResponse>

