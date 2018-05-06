package App::Sandy::Command::Quality::Add;
# ABSTRACT: quality subcommand class. Add a quality profile to the database.

use App::Sandy::Base 'class';

extends 'App::Sandy::Command::Quality';

our $VERSION = '0.18'; # VERSION

use constant {
	TYPE_OPT => ['raw', 'fastq']
};

override 'opt_spec' => sub {
	super,
	'verbose|v',
	'quality-profile|q=s',
	'read-size|r=i',
	'source|s=s'
};

sub _default_opt {
	'verbose' => 0,
	'type'    => 'fastq',
	'source'  => 'not defined'
}

sub validate_args {
	my ($self, $args) = @_;
	my $file = shift @$args;

	# Mandatory file
	if (not defined $file) {
		die "Missing file (a quality file or fastq file)\n";
	}

	# Is it really a file?
	if (not -f $file) {
		die "<$file> is not a file. Please, give me a valid quality or fastq file\n";
	}

	die "Too many arguments: '@$args'\n" if @$args;
}

sub validate_opts {
	my ($self, $opts) = @_;
	my %default_opt = $self->_default_opt;
	$self->fill_opts($opts, \%default_opt);

	if (not exists $opts->{'quality-profile'}) {
		die "Option 'quality-profile' not defined\n";
	}

	if (not exists $opts->{'read-size'}) {
		die "Option 'read-size' not defined\n";
	}

	if ($opts->{'read-size'} <= 0) {
		die "Option 'read-size' requires an integer greater than zero\n";
	}
}

sub execute {
	my ($self, $opts, $args) = @_;
	my $file = shift @$args;

	my %default_opt = $self->_default_opt;
	$self->fill_opts($opts, \%default_opt);

	# Set if user wants a verbose log
	$LOG_VERBOSE = $opts->{verbose};

	# Set the type of file
	if ($file !~ /.+\.(fastq)(\.gz)?$/) {
		$opts->{type} = 'raw';
	}

	# Go go go
	log_msg ":: Inserting $opts->{'quality-profile'} from $file ...";
	$self->insertdb(
		$file,
		$opts->{'quality-profile'},
		$opts->{'read-size'},
		$opts->{'source'},
		1,
		$opts->{'type'}
	);

	log_msg ":: Done!";
}

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Sandy::Command::Quality::Add - quality subcommand class. Add a quality profile to the database.

=head1 VERSION

version 0.18

=head1 SYNOPSIS

 sandy quality add -q <entry name> -r <size> [-s <source>] FILE

 Arguments:
  a file (fastq or a matrix with only quality entries)

 Mandatory options:
  -q, --quality-profile    quality-profile name for the database [required]
  -r, --read-size          the read-size to be used for the quality [required, Integer]

 Options:
  -h, --help               brief help message
  -M, --man                full documentation
  -v, --verbose            print log messages
  -s, --source             qaulity-profile source detail for database

=head1 DESCRIPTION

Add a quality profile to the database.

=head1 AUTHORS

=over 4

=item *

Thiago L. A. Miller <tmiller@mochsl.org.br>

=item *

Gabriela Guardia <gguardia@mochsl.org.br>

=item *

J. Leonel Buzzo <lbuzzo@mochsl.org.br>

=item *

Fernanda Orpinelli <forpinelli@mochsl.org.br>

=item *

Pedro A. F. Galante <pgalante@mochsl.org.br>

=back

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2018 by Teaching and Research Institute from Sírio-Libanês Hospital.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
