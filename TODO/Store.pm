package TODO::Store;

use Storable;
use Term::ANSIColor;

use TODO::Usage;

use strict;
use warnings;

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
        $h{ time() } = {
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
            time() => {
                'title'       => "$title",
                'description' => "$description",
                'state'       => 'uncomplete',
                'create_time' => time(),
                'childs'      => [],
            },
        );
        store( \%tasks, $parent_file );
    }

    print "Task '" . colored( "$title", 'cyan' ) . "' was stored.\n";
}

# List tasks
sub list {
    my ( $self, $list ) = @_;
    my $parent_file = $self->{_parent};
    my $child_file  = $self->{_child};
    my $parents     = retrieve($parent_file);
    my $childs      = '';
    if ( -e $child_file ) {
        $childs = retrieve($child_file);
    }

	my $formated;
    if ( $list eq 'tasks' ) {
        foreach my $unixt ( reverse sort keys( %{$parents} ) ) {
            my $loct = localtime($unixt);
            $formated
                .= colored( '*', 'yellow' ) . " "
                . colored( $loct,                       'green' ) . ' '
                . colored( $parents->{$unixt}->{title}, 'cyan' ) . "\n|\n";
        }
        chomp($formated);
        chop($formated);
        print $formated;
    }
    elsif ( $list eq 'all' ) {

    }
    elsif ( $list =~ /^.{8}$/ ) {

    }
    else {
        TODO::Usage->show();
    }

}

# Create new subtask
sub new_subtask {

}

# Sort
sub sort_tasks {
    my ( $self, $tasks, $type ) = @_;

    # Sort tasks
    my $sorted;
    if ( $type eq 'tasks' ) {
        foreach my $unixt ( sort keys( %{ $tasks->{parents} } ) ) {
            print $unixt. "\n";
            push(
                @$sorted,
                {   time  => localtime($unixt),
                    title => $tasks->{parents}->{title}
                }
            );
        }
    }
    elsif ( $type eq 'all' ) {

    }
    elsif ( $type =~ /^.{8}$/ ) {

    }
    else {
        TODO::Usage->show();
    }

}

# Generate random hash
sub gen_hash {
    my @chars = ( "A" .. "Z", "a" .. "z", 0 .. 9 );
    my $string;
    $string .= $chars[ rand @chars ] for 1 .. 8;

    return $string;
}

1;
