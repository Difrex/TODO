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
    TODO::Store->check_files();

    my $self = {
        _parent => $ENV{HOME} . "/.local/share/todo/parent.dat",
        _child  => $ENV{HOME} . "/.local/share/todo/child.dat",
    };

    bless $self, $class;
    return $self;
}

# Create new task
sub new_task {
    my ( $self, $title, $description ) = @_;
    my $parent_file = $self->{_parent};

    $description = '' if !($description);

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
    my $childs      = {};
    if ( -e $child_file ) {
        $childs = retrieve($child_file);
    }

    print Dumper($parents);
    print Dumper($childs);

    my $formated = '';

    # Show only tasks titles and description
    if ( $list eq 'tasks' ) {
        foreach my $unixt ( reverse sort keys( %{$parents} ) ) {
            $formated
                .= colored( '*', 'yellow' ) . "—"
                . colored( "$unixt",                    'green' ) . ' '
                . colored( $parents->{$unixt}->{title}, 'cyan' ) . "\n|\n";
        }
        chomp($formated);
        chop($formated);
        print $formated;
    }
    elsif ( $list eq 'all' ) {
        foreach my $unixt ( reverse sort keys( %{$parents} ) ) {
            $formated
                .= colored( '*', 'yellow' ) . "—"
                . colored( "$unixt",                    'green' ) . ' '
                . colored( $parents->{$unixt}->{title}, 'cyan' ) . "\n|\n";
            if ( $parents->{$unixt}->{childs} ) {
                chomp($formated);
                chop($formated);
                foreach my $hash ( $parents->{$unixt}->{childs} ) {
                    foreach my $x (@$hash) {
                        # body...
                        $formated
                            .= "  "
                            . colored( '*',   'yellow' ) . "—"
                            . colored( "$x", 'green' ) . "\n";
                    }
                }
            }
        }
        # chomp($formated);
        # chop($formated);
        print $formated;
    }
    elsif ( $list =~ /^\d{10}$/ ) {

    }
    else {
        TODO::Usage->show();
    }

}

# Create new subtask
sub new_subtask {
    my ( $self, $unixt, $task ) = @_;
    my $parent_file = $self->{_parent};
    my $child_file  = $self->{_child};
    my $parent      = retrieve($parent_file);
    my $child       = retrieve($child_file);

    $unixt =~ /\d{10}/ or warn "Wrong task id!\n" and TODO::Usage->show();

    # Create random hash
    my $rand_hash = TODO::Store->gen_hash();

    my @ch = $parent->{$unixt}->{childs};
    {
        no warnings;    # I know this is experimental feature
        push( $parent->{$unixt}->{childs}, $rand_hash );
    }

    # $parent->{$unixt}->{childs} = @ch;
    my %p = %$parent;

    # Save parents file
    store( \%p, $parent_file );

    # Generate child task hash
    $child->{$rand_hash} = {
        title       => $task,
        state       => 'uncomplete',
        time        => time(),
        parent      => $unixt,
        description => '',
    };

    my %c = %$child;

    # Save childrend file
    store( \%c, $child_file );

    print colored( $task, 'cyan' ) . " stored.\n";
}

# Generate random hash
sub gen_hash {
    my @chars = ( "A" .. "Z", "a" .. "z", 0 .. 9 );
    my $string;
    $string .= $chars[ rand @chars ] for 1 .. 8;

    return $string;
}

# Check storables folder
sub check_folders {
    if ( !( -d $ENV{HOME} . "/.local/share/todo/" ) ) {
        my @mkdir_cmd = ( 'mkdir', '-p', $ENV{HOME} . "/.local/share/todo/" );
        system(@mkdir_cmd) == 0 or die "Cannot create dir: $!\n";
    }
}

# Check storable files
sub check_files {
    my $parent_file = $ENV{HOME} . "/.local/share/todo/parent.dat";
    my $child_file  = $ENV{HOME} . "/.local/share/todo/child.dat";

    my %stor = ();
    if ( !( -e $parent_file ) ) {
        store( \%stor, $parent_file );
    }

    if ( !( -e $child_file ) ) {
        store( \%stor, $child_file );
    }
}

1;
