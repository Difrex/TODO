package TODO::Store;

use Storable;
use Term::ANSIColor;

use strict;
use warnings;
use utf8;

use Data::Dumper;

sub new {
    my $class = shift;

    TODO::Store->check_folders();

    my $self = {
        _parent => $ENV{HOME} . "/.local/share/todo/parent.dat",
        _child  => $ENV{HOME} . "/.local/share/todo/child.dat",
    };

    bless $self, $class;
    return $self;
}

# Check storables folder
sub check_folders {
    if ( !( -d $ENV{HOME} . "/.local/share/todo/" ) ) {
        my @mkdir_cmd = ( 'mkdir', '-p', $ENV{HOME} . "/.local/share/todo/" );
        system(@mkdir_cmd) == 0 or die "Cannot create dir: $!\n";
    }
}

# Create new task
sub new_task {
    my ( $self, $title, $description ) = @_;
    my $parent_file = $self->{_parent};

    $description = '' if !($description);

    # Create hash
    my $rand_hash = TODO::Store->gen_hash();

    # Load tasks and store new
    if ( -e $parent_file ) {
        my $tasks = retrieve($parent_file);
        my %h     = %$tasks;
        $h{$rand_hash} = {
            'title'       => "$title",
            'description' => "$description",
            'state'       => 'uncomplete',
            'create_time' => time(),
            'childs'      => [],
        };
        store( \%h, $parent_file );
    }
    else {
        my %tasks = (
            $rand_hash => {
                'title'       => "$title",
                'description' => "$description",
                'state'       => 'uncomplete',
                'create_time' => time(),
                'childs'      => [],
            },
        );
        store( \%tasks, $parent_file );
    }

    my $tasks = retrieve($parent_file);
    print Dumper($tasks);

    print "Task "
        . colored( 'cyan', $title )
        . " was saved with "
        . colored( 'yellow', 'uncomplete' )
        . " state.";
}

# List tasks
sub list {
	my ($self, $) = @_;
}

# Create new subtask
sub new_subtask {

}

# Generate random hash
sub gen_hash {
    my @chars = ( "A" .. "Z", "a" .. "z", 0 .. 9, '.' );
    my $string;
    $string .= $chars[ rand @chars ] for 1 .. 8;

    return $string;
}

1;
