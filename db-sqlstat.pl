#!/bin/env perl
# This program was designed to work with Zabbix to keep monitored MySQL databases.
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
my $hostname = '127.0.0.1';

my %querys = (
# State    
    "Uptime" => qq{SHOW GLOBAL STATUS WHERE Variable_name = 'Uptime'},
    "Aborted_clients" => qq{SHOW GLOBAL STATUS WHERE Variable_name = 'Aborted_clients'},
    "Aborted_connects" =>  qq{SHOW GLOBAL STATUS WHERE Variable_name = 'Aborted_connects'},
    "Slow_queries" => qq{SHOW GLOBAL STATUS WHERE Variable_name = 'Slow_queries'},
    "Com_select" => qq{SHOW GLOBAL STATUS WHERE Variable_name = 'Com_select'},    
    "Max_used_connections" => qq{SHOW GLOBAL STATUS WHERE Variable_name = 'Max_used_connections'},    
    "Connections" => qq{SHOW GLOBAL STATUS WHERE Variable_name = 'Connections'},    
    "Com_show_errors" => qq{SHOW GLOBAL STATUS WHERE Variable_name = 'Com_show_errors'},    
    "Delayed_errors" => qq{SHOW GLOBAL STATUS WHERE Variable_name = 'Delayed_errors'},    
    "Com_show_databases" => qq{SHOW GLOBAL STATUS WHERE Variable_name = 'Com_show_databases'},
# Traffic
    "Bytes_received" => qq{SHOW GLOBAL STATUS WHERE Variable_name = 'Bytes_received'},    
    "Bytes_sent" => qq{SHOW GLOBAL STATUS WHERE Variable_name = 'Bytes_sent'},    
# Threads
    "Threads_created" => qq{SHOW GLOBAL STATUS WHERE Variable_name = 'Threads_created'},
    "Threads_connected" => qq{SHOW GLOBAL STATUS WHERE Variable_name = 'Threads_connected'},
    "Threads_running" => qq{SHOW GLOBAL STATUS WHERE Variable_name = 'Threads_running'},
    "Threads_cached" =>	qq{SHOW GLOBAL STATUS WHERE Variable_name = 'Threads_cached'},
# Open resources
    "Open_tables" => qq{SHOW GLOBAL STATUS WHERE Variable_name = 'Open_tables'},
    "Open_files" => qq{SHOW GLOBAL STATUS WHERE Variable_name = 'Open_files'},
    "Opened_tables" =>	qq{SHOW GLOBAL STATUS WHERE Variable_name = 'Opened_tables'},
# Transactions
    "Com_insert" => qq{SHOW GLOBAL STATUS WHERE Variable_name = 'Com_insert'},
    "Com_update" => qq{SHOW GLOBAL STATUS WHERE Variable_name = 'Com_update'},
    "Com_commit" => qq{SHOW GLOBAL STATUS WHERE Variable_name = 'Com_commit'},
    "Com_delete" => qq{SHOW GLOBAL STATUS WHERE Variable_name = 'Com_delete'},
# Cached
    "Qcache_free_blocks" => qq{SHOW GLOBAL STATUS WHERE Variable_name = 'Qcache_free_blocks'},
    "Qcache_free_memory" => qq{SHOW GLOBAL STATUS WHERE Variable_name = 'Qcache_free_memory'},
    "Qcache_hits" => qq{SHOW GLOBAL STATUS WHERE Variable_name = 'Qcache_hits'},
    "Qcache_inserts" =>	qq{SHOW GLOBAL STATUS WHERE Variable_name = 'Qcache_inserts'},
    "Qcache_lowmem_prunes" => qq{SHOW GLOBAL STATUS WHERE Variable_name = 'Qcache_lowmem_prunes'},
    "Qcache_not_cached"	=> qq{SHOW GLOBAL STATUS WHERE Variable_name = 'Qcache_not_cached'},
    "Qcache_queries_in_cache" => qq{SHOW GLOBAL STATUS WHERE Variable_name = 'Qcache_queries_in_cache'},
    "Qcache_total_blocks" => qq{SHOW GLOBAL STATUS WHERE Variable_name = 'Qcache_total_blocks'},
# Temp
    "Created_tmp_disk_tables" => qq{SHOW GLOBAL STATUS WHERE Variable_name = 'Created_tmp_disk_tables'},
    "Created_tmp_files" => qq{SHOW GLOBAL STATUS WHERE Variable_name = 'Created_tmp_files'},
    "Created_tmp_tables" => qq{SHOW GLOBAL STATUS WHERE Variable_name = 'Created_tmp_tables'},
    "Sort_merge_passes" => qq{SHOW GLOBAL STATUS WHERE Variable_name = 'Sort_merge_passes'},


);

GetOptions(
    'help!'     =>  \&usage,
    'user=s'    =>  \$user,
    'pass=s'    =>  \$pass,
    'database=s'    =>  \$database,
    'Uptime' => sub { print query_database($querys{Aborted_clients}) },
    'Aborted_clients' => sub { print query_database($querys{Aborted_clients}) },
    'Aborted_connects' => sub { print query_database($querys{Aborted_connects}) },
    'Slow_queries' => sub { print query_database($querys{Slow_queries}) },
    'Com_select' => sub { print query_database($querys{Com_select}) },
    'Max_used_connections' => sub { print query_database($querys{Max_used_connections}) },
    'Connections' => sub { print query_database($querys{Connections}) },
    'Com_show_errors' => sub { print query_database($querys{Com_show_errors}) },
    'Delayed_errors' => sub { print query_database($querys{Delayed_errors}) },
    'Com_show_databases' => sub { print query_database($querys{Com_show_databases}) },

    'Bytes_received' => sub { print query_database($querys{Bytes_received}) },
    'Bytes_sent' => sub { print query_database($querys{Bytes_sent}) },
    
    'Threads_connected' => sub { print query_database($querys{Threads_connected}) },
    'Threads_created' => sub { print query_database($querys{Threads_created}) },
    'Threads_running' => sub { print query_database($querys{Threads_running}) },
    'Threads_cached' => sub { print query_database($querys{Threads_cached}) },

    'Open_tables'     => sub { print query_database($querys{Open_tables}) },
    'Open_files' => sub { print query_database($querys{Open_files}) }, 
    'Opened_tables' => sub { print query_database($querys{Opened_tables}) },

    'Com_insert' => sub { print query_database($querys{Com_insert}) },
    'Com_update' => sub { print query_database($querys{Com_update}) },
    'Com_commit' => sub { print query_database($querys{Com_commit}) },
    'Com_delete' => sub { print query_database($querys{Com_delete}) },

    'Qcache_free_blocks' => sub { print query_database($querys{Qcache_free_blocks}) },
    'Qcache_free_memory' => sub { print query_database($querys{Qcache_free_memory}) },
    'Qcache_hits' => sub { print query_database($querys{Qcache_hits}) },
    'Qcache_inserts' => sub { print query_database($querys{Qcache_inserts}) },
    'Qcache_lowmem_prunes' => sub { print query_database($querys{Qcache_lowmem_prunes}) },
    'Qcache_not_cached' => sub { print query_database($querys{Qcache_not_cached}) },
    'Qcache_queries_in_cache' => sub { print query_database($querys{Qcache_queries_in_cache}) },
    'Qcache_total_blocks' => sub { print query_database($querys{Qcache_total_blocks}) },

) or die "$0: try --help for more information\n";


sub query_database {
	my $query = shift(@_);
	my $dbh = DBI->connect("dbi:mysql:dbname=$database;host=$hostname",$user,$pass);
	my $sth = $dbh->prepare("$query") or die $|;
	$sth->execute;

	while (my @array = $sth->fetchrow_array)  {
		return @array[1];
	}
    $sth->disconnect
}

sub usage {
    print << "__EOF__";
[-] $0 is a perl script designed to work with Zabbix to keep monitored MySQL databases
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
