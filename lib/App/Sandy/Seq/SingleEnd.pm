package App::Sandy::Seq::SingleEnd;
# ABSTRACT: App::Sandy::Seq subclass for simulate single-end entries.

use App::Sandy::Base 'class';
use App::Sandy::Read::SingleEnd;

extends 'App::Sandy::Seq';

# VERSION

has '_read' => (
	is         => 'ro',
	isa        => 'App::Sandy::Read::SingleEnd',
	builder    => '_build_read',
	lazy_build => 1,
	handles    => ['gen_read']
);

sub BUILD {
	my $self = shift;
	## Just to ensure that the lazy attributes are built before &new returns
	$self->_read;
}

sub _build_read {
	my $self = shift;
	App::Sandy::Read::SingleEnd->new(
		sequencing_error => $self->sequencing_error
	);
}

sub sprint_seq {
	my ($self, $id, $num, $seq_id, $seq_id_type, $ptable, $ptable_size, $is_leader, $rng) = @_;

	my $read_size = $self->_get_read_size($rng);

	# In order to work third gen sequencing
	# simulator, it is necessary to truncate
	# the read according to the ptable size
	if ($read_size > $ptable_size) {
		$read_size = $ptable_size;
	}

	my ($read_ref, $attr) = $self->gen_read($ptable, $ptable_size, $read_size, $is_leader, $rng);

	my $error_a = $attr->{error};
	my $error = @$error_a
		? join ',' => @$error_a
		: 'none';

	my $annot_a = $attr->{annot};
	my $var = @$annot_a
		? join ',' => @$annot_a
		: 'none';

	$self->_set_info(
		'id'          => $id,
		'num'         => $num,
		'seq_id'      => $seq_id,
		'read'        => 1,
		'error'       => $error,
		'var'         => $var,
		'seq_id_type' => $seq_id_type,
		'read_size'   => $read_size,
		$is_leader
			? (
				'start'     => $attr->{start},
				'end'       => $attr->{end},
				'start_ref' => $attr->{start_ref},
				'end_ref'   => $attr->{end_ref},
				'strand'    => 'P')
			: (
				'start'     => $attr->{end},
				'end'       => $attr->{start},
				'start_ref' => $attr->{end_ref},
				'end_ref'   => $attr->{start_ref},
				'strand'    => 'M')
	);

	my $seqid = $self->_gen_id($self->_info);
	my $quality_ref = $self->gen_quality($read_size, $rng);

	return $self->_gen_seq(\$seqid, $read_ref, $quality_ref, 0, $read_size);
}
