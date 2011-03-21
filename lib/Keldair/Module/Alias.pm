# Copyright 2011 Ethrik Project, et al.
# Licensed under the 3-clause BSD.
	
package Keldair::Module::Alias;
use strict;
use warnings;
use Keldair;

$keldair->help_add(ALIAS => 'Create command aliases for other commands.');
$keldair->help_add(UNALIAS => 'Remove commands and/or aliases.');

$keldair->command_bind(ALIAS => sub {
	my ($chan, $dst, $cmd, $alias) = @_;

	if(!$keldair->command_get(uc $cmd))
	{
		$keldair->msg($chan, '%s: No such command "%s".', $dst->name, uc $cmd);
		return;
	}

	$keldair->command_bind(uc $alias, $keldair->command_get(uc $cmd));

	$keldair->msg($chan, "%s: \002%s\002 is now an alias for the command \002%s\002.", $dst->name, uc $alias, uc $cmd);
});

$keldair->command_bind(UNALIAS => sub {
	my ($chan, $dst, $cmd) = @_;
	if(!$keldair->command_get(uc $cmd))
	{
		$keldair->msg($chan, "%s: No such command or alias \002%s\002.", $dst->name, uc $cmd);
		return;
	}

	$keldair->command_unbind(uc $cmd);
	$keldair->msg($chan, "%s: \002%s\002 has been unbound.", $dst->name, uc $cmd);
});

1;
