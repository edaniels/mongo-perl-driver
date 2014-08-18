#
#  Copyright 2009-2014 MongoDB, Inc.
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
use Test::More 0.88;
use File::Find;
use Path::Tiny;

use YAML::XS;

File::Find::find({wanted => \&wanted, no_chdir => 1}, 't/cluster');

sub wanted {

    if (-f && /^.*\.ya?ml\z/) {

        my $name = path($_)->basename(qr/.ya?ml/);
        my $plan = YAML::XS::LoadFile($_);

        run_test($name, $plan);
    };
}

sub run_test {

    my ($test_name, $plan) = @_;

    subtest "test_$test_name" => sub {

        # Create mock cluster
        # my $cluster = create_mock_cluster(plan->{'uri'});

        for my $phase (@{$plan->{'phases'}}) {

            for my $response (@{$phase->{'responses'}}) {

                # Process response
                # got_ismaster($cluster, @$response[0], @$response[1]);
            }

            # Process outcome
            # check_outcome($cluster, $phase->{'outcome'});
        }
    };
}

sub got_ismaster {

    my ($cluster, $address, $response) = @_;

    # my $server_desc = ServerDescription->new($address, IsMaster->new($response), MovingAverage->new([0]));
    # $cluster->on_change($server_desc);
}

sub check_outcome {

    my ($cluster, $outcome) = @_;

    my %expected_servers = %{$outcome->{'servers'}};

    # is(
    #         scalar key %{$cluster->description->server_descriptions},
    #         scalar keys %expected_servers,
    #         'correct amount of servers');

    while (my ($key, $value) = each %expected_servers) {

        # ok($cluster->has_server($key));
        # my $actual_server_desc = $cluster->get_server_by_address($key)->description;

        # is($actual_server_desc->server_type, $value->{'serverType'}, 'correct server type');
        # is($actual_server_desc->set_name, $value->{'setName'}, 'correct setName for server');
    }

    # is(, $outcome->{'setName'}, 'correct setName for cluster');
    # is(, $outcome->{'clusterType'}, 'correct cluster type');
}

done_testing;
