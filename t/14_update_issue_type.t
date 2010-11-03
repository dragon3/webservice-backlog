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
        eval { $backlog->updateIssueType( {} ); };
        ok($@);
        like( $@, qr/id must be specified/, 'croak("id must be specified.")' );
    }
    {
        local $@;
        eval { $backlog->updateIssueType( { id => 123 } ); };
        ok($@);
        like(
            $@,
            qr/name must be specified/,
            'croak("name must be specified.")'
        );
    }
    {
        local $@;
        eval { $backlog->updateIssueType( { id => 123, name => 'Task' } ); };
        ok($@);
        like(
            $@,
            qr/color must be specified/,
            'croak("color must be specified.")'
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
        my $issueType = $backlog->updateIssueType(
            {
                id    => 1234,
                name  => 'TaskTask',
                color => '#990099'
            }
        );
        ok($issueType);
        is( $issueType->id,    1234 );
        is( $issueType->name,  'TaskTask' );
        is( $issueType->color, '#990099' );
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
              <int>1234</int>
            </value>
          </member>
          <member>
            <name>name</name>
            <value>
              <string>TaskTask</string>
            </value>
          </member>
          <member>
            <name>color</name>
            <value>
              <string>#990099</string>
            </value>
          </member>
        </struct>
      </value>
    </param>
  </params>
</methodResponse>
