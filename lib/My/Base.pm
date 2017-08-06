#
#===============================================================================
#
#         FILE: Base.pm
#
#  DESCRIPTION: Base class that enables Modern::Perl and other goodies
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Thiago Miller (tmiller), tmiller@mochsl.org.br
# ORGANIZATION: Group of Bioinformatics
#      VERSION: 1.0
#      CREATED: 08/05/2017 05:38:02 AM
#     REVISION: ---
#===============================================================================

package My::Base;
 
use 5.018;
use strict;
use warnings FATAL => 'all';
no warnings 'experimental::smartmatch';
use utf8 ();
use feature ();
use true ();
use Carp ();
use Try::Tiny ();
use namespace::autoclean;
use Hook::AfterRuntime;
use Import::Into;
use Data::OptList;
use Module::Runtime 'use_module';

our $LOG_VERBOSE = 0;

sub log_msg($) {
	my ($msg) = @_;
	return if not defined $msg;
	chomp $msg;
	say STDERR $msg if $LOG_VERBOSE;
}

sub import {
my ($class, @opts) = @_;
	my $caller = caller;

	# Import as in Moder::Perl
	strict->import;
	feature->import(':5.18');
	utf8->import($caller);
	true->import;
	Carp->import::into($caller);
	Try::Tiny->import::into($caller);

	# Custom handy function
	do {
		no strict 'refs';
		*{"${caller}\:\:log_msg"} = \&log_msg;
		*{"${caller}\:\:LOG_VERBOSE"} = \$LOG_VERBOSE;
	};

	@opts = @{
		Data::OptList::mkopt(
			\@opts,
		)
	};

	for my $opt_spec (@opts) {
		my ($opt, $opt_args) = @$opt_spec;		
		given ($opt) {
			when ('class') {
				require Moose;
				require MooseX::StrictConstructor;
				require MooseX::UndefTolerant;
				require My::Types;
				Moose->import({into=>$caller});
				MooseX::StrictConstructor->import({into=>$caller});
				MooseX::UndefTolerant->import({into=>$caller});
				after_runtime {
					$caller->meta->make_immutable;
				}
			};
			when ('role') {
				require Moose::Role;
				Moose::Role->import({into=>$caller});
			};
			when ('types') {
				require Moose::Util::TypeConstraints;
				Moose::Util::TypeConstraints->import({into=>$caller});
			}
			when ('test') {
				use_module('Test::Most')->import::into($caller);
			}
			when ('test_class') {
				use_module('Test::Class::Load')->import::into($caller, 't/lib');
			}
			when ('test_class_base') {
				my @classes = qw(Test::Class Class::Data::Inheritable);
				use_module('base')->import::into($caller, @classes);
			}
			default {
				Carp::carp "Ignoring unknown import option '$_'";
			};
		}
	}

	#This must come after anything else that might change warning
	# levels in the caller (e.g. Moose)
	warnings->import('FATAL'=>'all');

	namespace::autoclean->import(
		-cleanee => $caller,
	);

	return;
}

1; ## --- end module My::Base
