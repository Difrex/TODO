package TODO::Usage;

sub new {
    my $class = shift;
    my $self  = {};

    bless $self, $class;
    return $self;
}

sub show {
	print <<EOF;
Simple TODO list.
\t-n\tCreate new task/subtask
\t-d\tDelete task/subtask
\t-T\tTask name
\t-t\tSubtask name
\t-l\tList tasks
\t-h\tShow this help screen and exit
EOF
}

1;