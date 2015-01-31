#!/usr/bin/perl 

use Getopt::Std;

use TODO::Store;
use TODO::Usage;

use Data::Dumper;

my $store = TODO::Store->new();
my $usage = TODO::Usage->new();

# Otions parsing
sub init() {
    my $opt_string = 'T:ndt:l:h';
    getopts("$opt_string") or $usage->show();
    our ( $opt_T, $opt_t, $opt_n, $opt_d, $opt_l, $opt_h );

    $usage->show() if $opt_h;
}

init();

# Option switch
if ( $opt_T and $opt_n and !($opt_t) ) {

    # Create new task
    $store->new_task($opt_T);
}
else {
    $usage->show();
}
