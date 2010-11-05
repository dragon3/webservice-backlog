use strict;
use utf8;

use Test::More;
use Test::TCP;
use Plack::Loader;
use Plack::Request;

use WebService::Backlog;
use Encode;

# validation
{
    my $backlog = WebService::Backlog->new(
        url      => "http://127.0.0.1:8080/XML-RPC",
        username => 'guest',
        password => 'guest',
    );
    {
        local $@;
        eval { $backlog->updateVersion( {} ); };
        ok($@);
        like( $@, qr/id must be specified/, 'croak("id must be specified.")' );
    }
    {
        local $@;
        eval { $backlog->updateVersion( { id => 777 } ); };
        ok($@);
        like(
            $@,
            qr/name must be specified/,
            'croak("name must be specified.")'
        );
    }
}

my $app = sub {
    my $env  = shift;
    my $req  = Plack::Request->new($env);
    my $body = $req->content;
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
        my $version = $backlog->updateVersion(
            {
                name => encode_utf8('リリースv2'),
                id   => 733,
            }
        );
        ok($version);
        is( $version->id,       733 );
        is( $version->name,     decode_utf8('リリースv2') );
        is( $version->archived, 0 );
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
        <struct>
          <member>
            <name>id</name>
            <value>
              <int>733</int>
            </value>
          </member>
          <member>
            <name>name</name>
            <value>
              <string>リリースv2</string>
            </value>
          </member>
          <member>
            <name>archived</name>
            <value>
              <boolean>0</boolean>
            </value>
          </member>
        </struct>
      </value>
    </param>
  </params>
</methodResponse>
