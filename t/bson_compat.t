#
#  Copyright 2009-2013 MongoDB, Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

use strict;
use warnings;
use Test::More;

use BSON;
use MongoDB::Code;

use lib "t/lib";
use MongoDBTest qw/build_client get_test_db/;

my $client = build_client;
my $testdb = get_test_db($client);

my $c = $testdb->get_collection('bson_compat');

subtest "binary" => sub {
    
	$c->drop;

    my $str = "foo";
    my $bin = {bindata => [
                   \$str,
                   BSON::Binary->new($str),
                   BSON::Binary->new($str, 0x00),
                   BSON::Binary->new($str, 0x01),
                   BSON::Binary->new($str, 0x02),
                   BSON::Binary->new($str, 0x03),
                   BSON::Binary->new($str, 0x04),
                   BSON::Binary->new($str, 0x05),
                   BSON::Binary->new($str, 0x80)]};

    $c->insert($bin, {safe => 1});

    my $doc = $c->find_one;

    my $data = $doc->{'bindata'};
    foreach (@$data) {
        is($_, "foo");
    }

    $MongoDB::BSON::use_binary = 1;

    $doc = $c->find_one;

    $data = $doc->{'bindata'};
    my @arr = @$data;

    is($arr[0]->subtype, 0x00);
    is($arr[0]->data, $str);

    for (my $i=1; $i<=$#arr; $i++ ) {
        is($arr[$i]->subtype, $bin->{'bindata'}->[$i]->subtype);
        is($arr[$i]->data, $bin->{'bindata'}->[$i]->data);
    }
};

subtest "boolean" => sub {

	$c->drop;

	my $bool = BSON::Bool->true;
	$c->insert({bool => $bool}, {safe => 1});
	my $doc = $c->find_one;
	is($doc->{bool}, $bool->value);
};

subtest "code" => sub {

	$c->drop;

	my $js = q[
        function be_weird(a) {
            if ( a > 20 ) {
                alert("It's too big!")
            }
            return function(b){
                alert(b)
            }
        }
    ];
    my $scope = { a => 6, b => 14 };
	my $code = BSON::Code->new($js, $scope);

    $c->insert({code => $code}, {safe => 1});
    my $doc = $c->find_one;
    is($doc->{code}->code, $js);
    is_deeply($doc->{code}->scope, $scope);
};

subtest "datetime" => sub {

	$c->drop;

	# Current time
	my $t = BSON::Time->new;
	$c->insert({time => $t});
	my $doc = $c->find_one;

	is($doc->{time}->epoch, $t->epoch);
};

subtest "maxkey" => sub {

	$c->drop;

	my $min = BSON::MinKey->new;
	$c->insert({min => $min});
	my $doc = $c->find_one;

	ok($doc->{min}->isa("BSON::Types::MinKey"));
};

subtest "minkey" => sub {

	$c->drop;

	my $max = BSON::MaxKey->new;
	$c->insert({max => $max});
	my $doc = $c->find_one;

	ok($doc->{max}->isa("BSON::Types::MaxKey"));
};

subtest "objectid" => sub {

	$c->drop;

	my $oid = BSON::ObjectId->new;
	$c->insert({_id => $oid});
	my $doc = $c->find_one;
	is($doc->{'_id'}->value, $oid->value);
};

subtest "regex" => sub {

	$client->inflate_regexps(1);

	$c->drop;

	my $rx = BSON::Regex->new("abc", "i");
	$c->insert({rx => $rx});
	my $doc = $c->find_one;
	is($doc->{rx}->pattern, $rx->pattern);
	is($doc->{rx}->flags, $rx->flags);

	$client->inflate_regexps(0);
};

subtest "string" => sub {

	$c->drop;

	my $str = BSON::String->new("mystring");
	$c->insert({str => $str});
	my $doc = $c->find_one;
	is($doc->{str}, $str->value);
};

subtest "timestamp" => sub {

	$c->drop;
	
	my $t = BSON::Timestamp->new(12345678, 9876543);
    $c->insert({"ts" => $t});
    my $doc = $c->find_one;
    is($doc->{'ts'}->sec, $t->seconds);
    is($doc->{'ts'}->inc, $t->increment);
};

done_testing;