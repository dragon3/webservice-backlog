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
        eval { $backlog->addIssueType( {} ); };
        ok($@);
        like(
            $@,
            qr/project_id must be specified/,
            'croak("project_id must be specified.")'
        );
    }
    {
        local $@;
        eval { $backlog->addIssueType( { project_id => 123 } ); };
        ok($@);
        like(
            $@,
            qr/name must be specified/,
            'croak("name must be specified.")'
        );
    }
    {
        local $@;
        eval {
            $backlog->addIssueType( { project_id => 123, name => 'Task' } );
        };
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
        my $issueType = $backlog->addIssueType(
            {
                name       => encode_utf8('問題'),
                project_id => 123,
                color      => '#990000'
            }
        );
        ok($issueType);
        is( $issueType->id,    5 );
        is( $issueType->name,  decode_utf8('問題') );
        is( $issueType->color, '#990000' );
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
                    <int>5</int>
                  </value>
                </member>
                <member>
                  <name>name</name>
                  <value>
                    <string>問題</string>
                  </value>
                </member>
                <member>
                  <name>color</name>
                  <value>
                    <string>#990000</string>
                  </value>
                </member>
              </struct>
      </value>
    </param>
  </params>
</methodResponse>
