#!/usr/bin/env perl
# This program will get installed current available drivers on this system
# prerequisite
# $ sudo perl -MCPAN -e shell
# cpan> install DBI
# Strict and warnings are recommended.
use strict;
use warnings;
use DBI;
my @ary = DBI->available_drivers();
print join( "\n", @ary ), "\n";
