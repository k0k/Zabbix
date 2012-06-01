#!/bin/env perl
# This program was designed to create a host in a template profile on zabbix monitoring 
# platform, use the Zabbix JSON-RPC API, this script send a POST request to zabbix URL
# with input data in JSON. 
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
use LWP::UserAgent;
use JSON::XS;
use Sys::Hostname;
use IO::Socket;

# Credenciales Zabbix Portal.
my $json_uri = "http://URL_HERE/zabbix/api_jsonrpc.php";
my $user = "Admin";
my $pass = "CLAVE";

##########################################
# Connect to Zabbix URL
##########################################
sub json_connect {
	my $json_uri = shift(@_);
	my $ua = LWP::UserAgent->new;
	$ua->agent('Puppet/Zabbix Agent '. $ua->_agent);
	$ua->timeout(5);
	$ua->default_header('content-type' => 'application/json-rpc');

	my $response = $ua->get($json_uri);
	if ($response->is_success) {
    	print "Connecting sucessfull to $json_uri\n";
		login();
	} else {
	print "FAILED\n";
	die $response->status_line;
	}
};

##########################
# Login on Zabbix
##########################
sub login { 	# http://www.zabbix.com/documentation/1.8/api/user/login
	my $json_login = JSON::XS->new->pretty(0)->encode(	
	{
		jsonrpc => 2.0,
		method => "user.login",
		params => {
			user => "$user",
			password => "$pass",
		},
			id => 1
	});
	# ToDo: El procedimiento para utilizar el método POST en esta funcion y en la siguiente 
	# podría ser utilizado mas elegantemente a través de una variable de objeto cargada con 
	# el uri y luego procesarla mediante lwp.
	print "Login Zabbix JSON API...\n";
	my $req = HTTP::Request->new( 'POST', $json_uri );
	$req->header( 'Content-Type' => 'application/json-rpc' );
	$req->content( $json_login );

	my $ua = LWP::UserAgent->new;
	my $response = $ua->request( $req );
	my $decode = $response->decoded_content;	# Respuesta del servidor
	# Filtra el "unique authentication token" enviado por el servidor.
	my (undef, undef, $auth_token) = split(':', $decode);
	$auth_token =~ s/(","id")//;$auth_token =~ s/^"//;
	print "id session: $auth_token\n";
	create_host($auth_token);
}

########################
# Server Populate 
########################
sub create_host {	# http://www.zabbix.com/documentation/1.8/api/host/create
	# Se obtienen los datos básicos del servidor: nombre y dirección IP.
	# El éxito de este procedimiento depende de lo correctamente configurado el 
	# servidor en /etc/hosts.
	my $node = hostname;
	my $ipaddr = inet_ntoa((gethostbyname($node))[4]);
	my $auth = shift(@_);
	# En el URL de Zabbix Portal se puede obtener los valores representados por:
	# templateid 10047= "Baseline"
	# groupid 2 = "Linux"
	my $json_host_create = JSON::XS->new->pretty(0)->encode(
	{
	jsonrpc => 2.0,
	method => "host.create",
	params => {
        interfaces => [
            {
		    type => 1,
            main => 1,
            useip => 1,
            ip => "$ipaddr",
            dns => "$node",
            port => 10050,
            }
    	],
		groupid => 2
    }
		],
			templates => [
         		{
			templateid => 10047
         		}
      		]
   	},
	auth => "$auth",
	id => 3
	});

	print "Creating host on Zabbix...\n";
	my $req = HTTP::Request->new( 'POST', $json_uri );
	$req->header( 'Content-Type' => 'application/json-rpc' );
	$req->content( $json_host_create );

	my $ua = LWP::UserAgent->new;
	my $response = $ua->request( $req );
#	print "\n".$response->decoded_content;	# La respuesta del servidor
}

json_connect( $json_uri )

# vim: set nowrap nu foldmethod=marker:

__DATA__
Connecting Sucessfull to http://192.168.xxx.xx/zabbix/api_jsonrpc.php
Login Zabbix JSON API...
id session: 6a7b4582b9e35c1bbc81f02544bd0db1
Creating host on Zabbix...

=head1 NAME

zabbix-JSON-register.pl - Simple perl script to populate Zabbix, designed to deploy via puppet and register
every server without monkey assistence.

=head1 REQUIREMENTS

RHEL based system you need install JSON-XS perl module with 'yum install perl-JSON-XS' command or via CPAN
'cpan JSON::XS'.

=head1 CATEGORY

Networking Unix/System Administration
