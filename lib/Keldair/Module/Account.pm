# Copyright 2011 Ethrik Project, et al.
# Licensed under the 3-clause BSD.

package Keldair::Module::Account;
use strict;
use warnings;
use Keldair;

# Stores account information
# name => passwd
# name => salt
# name => acl
my %account;

$keldair->hook_add(OnStart => sub {
	my $ap = $keldair->conf->get('account/admin_passwd');
	if(!defined $ap)
	{
		$keldair->log(WARN => 'Admin pass not set in config (account/admin_pass); it will be inaccessible until next rehash.');
		return;
	}
	$account{'admin'}{passwd} = $ap;
});

$keldair->help_add(CREATE => 'Create Keldair Accounts.');

$keldair->command_bind(CREATE => sub {
	my ($chan, $dst, $name, $passwd) = @_;
	
	if(exists $account{lc($name)})
	{
		$keldair->msg($chan, '%s: Account for %s already exists.', $dst->name, $name);
		return;
	}

	if(!defined $name || !defined $passwd)
	{
		$keldair->msg($chan, '%s: CREATE <account> <password>', $dst->name);
		return;
	}

	my $salt = int rand 1337;
	my $crypt = crypt $passwd, $salt;

	$account{lc($name)}{passwd} = $crypt;
	$account{lc($name)}{salt} = $salt;

	$keldair->notice($dst, 'Account %s successfully created.', $name);
	$keldair->logf(ACCOUNT => '%s!%s@%s created account %s.', $dst->name, $dst->ident, $dst->host, $name);

});

$keldair->command_bind(IDENTIFY => sub {
	my ($chan, $dst, $name, $password) = @_;
	
	if(!exists $account{lc($name)})
	{
		$keldair->notice($dst, 'No such account "%s".', $name);
		return;
	}

	my $passchk = crypt $password, $account{lc($name)}{salt} unless $name eq 'admin';
	$passchk ||= $password; # Should only occur for admin account
	
	if($passchk ne $account{lc($name)}{passwd})
	{
		$keldair->notice($dst, 'Invalid password for account %s.', $name);
		
		$keldair->logf(ACCOUNT => 
			'%s!%s@%s failed to identify to account %s (bad password).',
			$dst->name,
			$dst->ident,
			$dst->host
		);

		return;
	}

	my @notify = split /\,/, $account{lc($name)}{identified};
	
	foreach (@notify)
	{
		next if $_ eq '';
		if($_ eq $dst->name)
		{
			$keldair->notice($dst, 'You are already identified to account %s.', $name);
			return;
		}
	}

	$account{lc($name)}{identified} .= ','.$dst->name;
	
	$keldair->logf(ACCOUNT =>
		'%s!%s@%s successfully identifed to account %s.',
		$dst->name, $dst->ident, $dst->host, $name
	);

	$keldair->notice($dst, 'Successfully identified to account %s.', $name);

	foreach (@notify)
	{
		next if $_ eq ''; # This is for the first value that is always blank
		$keldair->logf(DEBUG => 'Notifying %s that %s identified to the same account as them.', $_, $dst->name);
		next if $_ eq ($dst->name);
		$keldair->notice($keldair->find_user($_), '%s!%s@%s identified to your account (%s).',
			$dst->name, $dst->ident,
			$dst->host, $name);
	}
});

1;
