#!/bin/env perl
# This program was designed to work with Zabbix to keep monitored PostgreSQL databases.
# Copyright (C) 2012 Wilmer Jaramillo M. <wilmer@fedoraproject.org>

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>

use strict;
use DBI;
use Getopt::Long;
use Sys::Hostname;

my ($database, $user, $pass, $help);
my $hostname = hostname;

my %querys = (
# State    
    "size"              =>  qq{SELECT SUM(pg_database_size(datid)) as total_size from pg_stat_database},
    "threads"           =>  qq{SELECT COUNT(*) FROM pg_stat_activity},    
    "activeconn"        =>	qq{SELECT SUM(numbackends) FROM pg_stat_database},    
    "tupreturned"       =>	qq{SELECT SUM(tup_returned) FROM pg_stat_database},
    "tupfetched"        =>	qq{SELECT SUM(tup_fetched) FROM pg_stat_database},
    "tupinserted"       =>	qq{SELECT SUM(tup_inserted) FROM pg_stat_database},
    "tupupdated"        =>	qq{SELECT SUM(tup_updated) FROM pg_stat_database},
    "tupdeleted"        =>	qq{SELECT SUM(tup_deleted) FROM pg_stat_database},
    "xactcommit"        =>	qq{SELECT SUM(xact_commit) FROM pg_stat_database},
    "xactrollback"      =>	qq{SELECT SUM(xact_rollback) FROM pg_stat_database},
# Locks
    "exclusivelock"             =>	qq{SELECT COUNT(*) FROM pg_locks WHERE mode='ExclusiveLock'},
    "accessexclusivelock"       =>	qq{SELECT COUNT(*) FROM pg_locks WHERE mode='AccessExclusiveLock'},
    "accesssharelock"           =>	qq{SELECT COUNT(*) FROM pg_locks WHERE mode='AccessShareLock'},
    "rowsharelock"              =>	qq{SELECT COUNT(*) FROM pg_locks WHERE mode='RowShareLock'},
    "rowexclusivelock"          =>	qq{SELECT COUNT(*) FROM pg_locks WHERE mode='RowExclusiveLock'},
    "shareupdateexclusivelock"  =>	qq{SELECT COUNT(*) FROM pg_locks WHERE mode='ShareUpdateExclusiveLock'},
    "sharerowexclusivelock"     =>	qq{SELECT COUNT(*) FROM pg_locks WHERE mode='ShareRowExclusiveLock'},
# Checkpoints
    "checkpoints_timed"     =>	qq{SELECT checkpoints_timed FROM pg_stat_bgwriter},
    "checkpoints_req"       =>	qq{SELECT checkpoints_req FROM pg_stat_bgwriter},
    "buffers_checkpoint"    =>	qq{SELECT buffers_checkpoint FROM pg_stat_bgwriter},
    "buffers_clean"         =>	qq{SELECT buffers_clean FROM pg_stat_bgwriter},
    "maxwritten_clean"	    =>	qq{SELECT maxwritten_clean FROM pg_stat_bgwriter},
    "buffers_backend"	    =>	qq{SELECT buffers_backend FROM pg_stat_bgwriter},
    "buffers_alloc"         =>	qq{SELECT buffers_alloc FROM pg_stat_bgwriter},
);

GetOptions(
    'help!'     =>  \&usage,
    'user=s'    =>  \$user,
    'pass=s'    =>  \$pass,
    'database=s'    =>  \$database,
    'size'          => sub { print query_database($querys{size}) },
    'threads'       => sub { print query_database($querys{threads}) },
    'activeconn'    => sub { print query_database($querys{activeconn}) },
    'tupreturned'   => sub { print query_database($querys{tupreturned}) }, 
    'tupfetched'    => sub { print query_database($querys{tupfetched}) },
    'tupinserted'   => sub { print query_database($querys{tupinserted}) },
    'tupupdated'    => sub { print query_database($querys{tupupdated}) },
    'tupdeleted'    => sub { print query_database($querys{tupdeleted}) },
    'xactcommit'    => sub { print query_database($querys{xactcommit}) },
    'xactrollback'  => sub { print query_database($querys{xactrollback}) },
    
    'exclusivelock'             => sub { print query_database($querys{exclusivelock}) },
    'accessexclusivelock'       => sub { print query_database($querys{accessexclusivelock}) },
    'accesssharelock'           => sub { print query_database($querys{accesssharelockery}) },
    'rowsharelock'              => sub { print query_database($querys{rowsharelock}) },
    'rowexclusivelock'          => sub { print query_database($querys{xactcommit}) },
    'shareupdateexclusivelock'  => sub { print query_database($querys{shareupdateexclusivelock}) },
    'sharerowexclusivelock'     => sub { print query_database($querys{sharerowexclusivelock}) },

    'checkpoints_timed'     => sub { print query_database($querys{checkpoints_timed}) },
    'checkpoints_req'       => sub { print query_database($querys{checkpoints_req}) },
    'buffers_checkpoint'    => sub { print query_database($querys{buffers_checkpoint}) },
    'buffers_clean'         => sub { print query_database($querys{buffers_clean}) },
    'maxwritten_clean'      => sub { print query_database($querys{maxwritten_clean}) },
    'buffers_backend'       => sub { print query_database($querys{buffers_backend}) },
    'buffers_alloc'         => sub { print query_database($querys{buffers_alloc}) }
) or die "$0: try --help for more information\n";

sub query_database {
	my $query = shift(@_);
	my $dbh = DBI->connect("dbi:Pg:dbname=$database;host=$hostname",$user,$pass);
	my $sth = $dbh->prepare("$query") or die $|;
	$sth->execute;

	while (my @array = $sth->fetchrow_array)  {
		return @array[0];
	}
    $sth->disconnect
}

sub usage {
    print << "__EOF__";
[-] $0 is a perl script designed to work with Zabbix to keep monitored PostgreSQL databases
some features monitored are: threads, connection pool, size, buffers, locks, checkpoints.
Usage: $0 [--OPTION]
Mandatory arguments:
__EOF__

    while ( my($key, undef) = each %querys ) {
        print "\t--".$key."\n";
    } 
    exit 0
}

usage() unless defined(@ARGV);

# vim: ts=4 sw=4 sts=4 et ai nu nowrap bg=dark
