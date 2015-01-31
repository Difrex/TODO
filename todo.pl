#!/usr/bin/perl 

use Getopt::Std;
use Term::ANSIColor;

use TODO::Store;

sub check_folders {
    if ( !( -d $ENV{HOME} . "/.local/share/todo/" ) ) {
        my @mkdir_cmd = ( 'mkdir', '-p', $ENV{HOME} . "/.local/share/todo/" );
        system(@mkdir_cmd) == 0 or die "Cannot create dir: $!\n";
    }
}

check_folders()