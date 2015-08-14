#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use Sys::Cmd 'spawn';

use Log::Any::Adapter 'Stdout';

print "Spawning process\n";
my $proc = spawn('file-not-found');

#$proc->stdin->print("x\n");
$proc->wait_child;

print "Process ended with " . $proc->exit . "\n";

END {
    print "END block\n";
}
