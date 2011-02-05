#!/usr/bin/env perl

# Keldair.pm - IRC client library
# Copyright 2011 Alexandria M. Wolcott <alyx@woomoo.org>
# Licensed under the 3-clause BSD.

use strict;
use warnings;
use Class::Keldair;

package Keldair;

our (%V) = (
    'MAJOR' => 0,
    'MINOR' => 0,
    'PATCH' => 0
);

our $VERSION = "$V{MAJOR}.$V{MINOR}.$V{PATCH}";

our $keldair = Class::Keldair->new();
