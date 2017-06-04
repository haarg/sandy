#
#===============================================================================
#
#         FILE: Fastq.pm
#
#  DESCRIPTION: Tests for 'Fastq' class
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Thiago Miller (tmiller), tmiller@mochsl.org.br
# ORGANIZATION: Group of Bioinformatics
#      VERSION: 1.0
#      CREATED: 13-05-2017 23:54:09
#     REVISION: ---
#===============================================================================
 
package TestsFor::Fastq;

use Test::Most;
use autodie;
use base 'TestsFor';

use constant {
	SEQ_SYS       => 'HiSeq',
	QUALITY_SIZE  => 10,
};

sub startup : Tests(startup) {
	my $test = shift;
	$test->SUPER::startup;
	my $class = ref $test;
	$class->mk_classdata('default_fastq');
	$class->mk_classdata('default_attr');
	$class->mk_classdata('seq');
	$class->mk_classdata('seq_len');
}

sub setup : Tests(setup) {
	my $test = shift;
	my %child_arg = @_;
	$test->SUPER::setup;

	my %default_attr = (
		sequencing_system => SEQ_SYS,
		read_size         => QUALITY_SIZE,
		%child_arg
	);

	$test->default_attr(\%default_attr);
	$test->default_fastq($test->class_to_test->new(%default_attr));

	my $seq = 'TGACCCGCTAACCTCAGTTCTGCAGCAGTAACAACTGCCGTATCTGGACTTTCCTAATACCTCGCATAGTCCGTCCCCTCGCGCGGCAAGAGGTGCGGCG';
	$test->seq($seq);
	$test->seq_len(length $seq);
}

sub constructor : Tests(4) {
	my $test = shift;

	my $class = $test->class_to_test;
	my $fastq = $test->default_fastq;
	my %default_attr = %{ $test->default_attr };

	while (my ($attr, $value) = each %default_attr) {
		can_ok $fastq, $attr;
		is $fastq->$attr, lc $value, "The value for $attr shold be correct";
	}
}

sub sprint_fastq : Tests(3) {
	my $test = shift;

	my $class = $test->class_to_test;
	my $fastq = $test->default_fastq;
	
	my $header = "PONGA_HEADER";		
	my $seq = "ATCGATCGAT";
	throws_ok { $fastq->sprint_fastq($header, \$seq) }
	qr/Validation failed for 'ScalarRef\[Str\]'/,
		"Not passing a reference to SCALAR (as header) to fastq should fail";

	throws_ok { $fastq->sprint_fastq(\$header, $seq) }
	qr/Validation failed for 'ScalarRef\[Str\]'/,
		"Not passing a reference to SCALAR (as seq) to fastq should fail";
	
	my $quality_size = QUALITY_SIZE;
	my $rg = qr/\@${header}\n${seq}\n\+${header}\n.{$quality_size}/;
	ok $fastq->sprint_fastq(\$header, \$seq) =~ $rg,
		"'fastq' should return an entry in fastq format";
}

1;
