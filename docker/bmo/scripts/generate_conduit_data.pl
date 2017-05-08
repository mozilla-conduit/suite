#!/usr/bin/perl -w
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

use strict;
use warnings;
use lib qw(. lib local/lib/perl5);

use Bugzilla;
use Bugzilla::Bug;
use Bugzilla::Constants;
use Bugzilla::User;
use Bugzilla::User::APIKey;

BEGIN {
    Bugzilla->extensions;
}

my $dbh = Bugzilla->dbh;

# set Bugzilla usage mode to USAGE_MODE_CMDLINE
Bugzilla->usage_mode(USAGE_MODE_CMDLINE);

my $admin_email = shift || 'admin@mozilla.bugs';
Bugzilla->set_user(Bugzilla::User->check({ name => $admin_email }));

##########################################################################
# Create Conduit User
##########################################################################

my $conduit_login    = $ENV{CONDUIT_LOGIN}    || 'conduit@mozilla.bugs';
my $conduit_password = $ENV{CONDUIT_PASSWORD} || 'password';
my $conduit_api_key  = $ENV{CONDUIT_API_KEY}  || '';

print "creating conduit user account...\n";
my $new_user = Bugzilla::User->create(
    {
        login_name    => $conduit_login,
        realname      => 'Conduit Test User',
        cryptpassword => $conduit_password
    },
);

if ($conduit_api_key) {
    Bugzilla::User::APIKey->create_special(
        {
            user_id     => $new_user->id,
            description => 'API key for Conduit User',
            api_key     => $conduit_api_key
        }
    );
}

##########################################################################
# Create Conduit Test Bug
##########################################################################
print "creating conduit test bug...\n";
Bugzilla->set_user(Bugzilla::User->check({ name => 'conduit@mozilla.bugs' }));
Bugzilla::Bug->create(
    {
        product      => 'Firefox',
        component    => 'General',
        priority     => '--',
        bug_status   => 'NEW',
        version      => 'unspecified',
        comment      => '-- Comment Created By Conduit User --',
        rep_platform => 'Unspecified',
        short_desc   => 'Conduit Test Bug',
        op_sys       => 'Unspecified',
        bug_severity => 'normal',
        version      => 'unspecified',
    }
);

print "installation and configuration complete!\n";
