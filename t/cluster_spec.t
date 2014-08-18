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

        exit(1);
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
                # got_ismaster($cluster, $response[0], $response[1]);
            }

            # Process outcome
            # check_outcome($cluster, $phase->{'outcome'});
        }
    };
}

done_testing;
