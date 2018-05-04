package App::SimulateReads::Command::Transcriptome;
# ABSTRACT: simulate command class. Simulate transcriptome sequencing

use App::SimulateReads::Base 'class';

extends 'App::SimulateReads::CLI::Command';

with 'App::SimulateReads::Role::Digest';

# VERSION
sub default_opt {
	'paired-end-id'    => '%i.%U_%c %U',
	'single-end-id'    => '%i.%U_%c %U',
	'seed'             => time,
	'verbose'          => 0,
	'prefix'           => 'out',
	'output-dir'       => '.',
	'jobs'             => 1,
	'gzip'             => 1,
	'count-loops-by'   => 'number-of-reads',
	'number-of-reads'  => 1000000,
	'strand-bias'      => 'minus',
	'seqid-weight'     => 'count',
	'sequencing-type'  => 'paired-end',
	'fragment-mean'    => 300,
	'fragment-stdd'    => 50,
	'sequencing-error' => 0.005,
	'read-size'        => 100,
	'quality-profile'  => 'poisson'
}

sub rm_opt {
	'strand-bias',
	'coverage',
	'seqid-weight'
}

__END__

=head1 SYNOPSIS

 simulate_reads transcriptome [options] -f <expression-matrix> <fasta-file>

 Arguments:
  a fasta-file 

 Mandatory options:
  -f, --expression-matrix        an expression-matrix entry from database

 Options:
  -h, --help                     brief help message
  -M, --man                      full documentation
  -v, --verbose                  print log messages
  -p, --prefix                   prefix output [default:"out"]	
  -o, --output-dir               output directory [default:"."]
  -i, --append-id                append to the defined template id [Format]
  -I, --id                       overlap the default template id [Format]
  -j, --jobs                     number of jobs [default:"1"; Integer]
  -z, --gzip                     compress output file
  -s, --seed                     set the seed of the base generator
                                 [default:"time()"; Integer]
  -n, --number-of-reads          set the number of reads
                                 [default:"1000000", Integer]
  -t, --sequencing-type          single-end or paired-end reads
                                 [default:"paired-end"]
  -q, --quality-profile          sequencing system profiles from quality
                                 database [default:"poisson"]
  -e, --sequencing-error         sequencing error rate
                                 [default:"0.005"; Number]
  -r, --read-size                the read size [default:"100"; Integer]
                                 the quality_profile from database overrides
                                 this value
  -m, --fragment-mean            the fragment mean size for paired-end reads
                                 [default:"300"; Integer]
  -d, --fragment-stdd            the fragment standard deviation size for
                                 paired-end reads [default:"50"; Integer]

=head1 OPTIONS

=over 8

=item B<--help>

Print a brief help message and exits.

=item B<--man>

Prints the manual page and exits.

=item B<--verbose>

Prints log information to standard error

=item B<--prefix>

Concatenates the prefix to the output-file name.

=item B<--output-dir>

Creates output-file inside output-dir. If output-dir
does not exist, it is created recursively

=item B<--append-id>

Append string template to the defined template id.
See B<Format>

=item B<--id>

Overlap the default defined template id:
I<single-end> %i.%U %U and I<paired-end> %i.%U %U
e.g. SR123.1 1
See B<Format>

=item B<Format>

A string B<Format> is a combination of literal and escape characters similar to the way I<printf> works.
That way, the user has the freedom to customize the fastq sequence identifier to fit her needs. Valid
escape characteres are:

Common escape characters

	Escape       Meaning
	------       ------------------------------------------
	%i   	     instrument id composed by SR + PID
	%I           job slot number
	%q           quality profile
	%e           sequencing error
	%x           sequencing error position
	%R           read 1, or 2 if it is the paired-end mate
	%U           read number
	%r           read size
	%c           sequence id as chromossome, ref
	%s           read or fragment strand
	%t           read start position
	%n           read end position

Paired-end specific escape characters

	Escape       Meaning
	------       ------------------------------------------
	%T           mate read start position
	%N           mate read end position
	%D           distance between the paired-reads
	%m           fragment mean
	%d           fragment standard deviation
	%f           fragment size
	%S           fragment start position
	%E           fragment end position

=item B<--jobs>

Sets the number of child jobs to be created

=item B<--gzip>

Compress the output-file with gzip algorithm. It is
possible to pass --no-gzip if one wants
uncompressed output-file

=item B<--seed>

Sets the seed of the base generator. The ability to set the seed is
useful for those who want reproducible simulations. Pay attention to
the number of jobs (--jobs) set, because each job receives a different
seed calculated from the I<main seed>. So, for reproducibility, the
same seed set before needs the same number of jobs set before as well.

=item B<--read-size>

Sets the read size, if quality-profile is equal to 'poisson'. The
quality-profile from database overrides the read-size

=item B<--number-of-reads>

Sets the number of reads desired. This is the default option
for transcriptome sequencing simulation

=item B<--sequencing-type>

Sets the sequencing type to single-end or paired-end

=item B<--fragment-mean>

If the sequencing-type is set to paired-end, it sets the
fragment mean

=item B<--fragment-stdd>

If the sequencing-type is set to paired-end, it sets the
fragment standard deviation

=item B<--sequencing-error>

Sets the sequencing error rate. Valid values are between zero and one

=item B<--quality-profile>

Sets the sequencing system profile for quality. The default value is a poisson
distribution, but the user can choose among several profiles stored into the
database or import his own data.
See B<quality> command for more details

=item B<--expression-matrix>

The expression-matrix entries are found into the database.
See B<expression> command for more details

=back

=head1 DESCRIPTION

Simulate transcriptome sequencing.

=cut
