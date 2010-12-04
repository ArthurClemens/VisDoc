####################################################################
#
#    This file was generated using Parse::Yapp version 1.05.
#
#        Don't edit this file, use source file instead.
#
#             ANY CHANGE MADE HERE WILL BE LOST !
#
####################################################################
package Foswiki::Plugins::FreeMarkerPlugin::FreeMarkerParser;
use vars qw ( @ISA );
use strict;

@ISA= qw ( Parse::Yapp::Driver::FreeMarkerParser );
#Included Parse/Yapp/Driver.pm file----------------------------------------
{
#
# Module Parse::Yapp::Driver::FreeMarkerParser
#
# This module is part of the Parse::Yapp package available on your
# nearest CPAN
#
# Any use of this module in a standalone parser make the included
# text under the same copyright as the Parse::Yapp module itself.
#
# This notice should remain unchanged.
#
# (c) Copyright 1998-2001 Francois Desarmenien, all rights reserved.
# (see the pod text in Parse::Yapp module for use and distribution rights)
#

package Parse::Yapp::Driver::FreeMarkerParser;

require 5.004;

use strict;

use vars qw ( $VERSION $COMPATIBLE $FILENAME );

$VERSION = '1.05';
$COMPATIBLE = '0.07';
$FILENAME=__FILE__;

use Carp;

#Known parameters, all starting with YY (leading YY will be discarded)
my(%params)=(YYLEX => 'CODE', 'YYERROR' => 'CODE', YYVERSION => '',
			 YYRULES => 'ARRAY', YYSTATES => 'ARRAY', YYDEBUG => '');
#Mandatory parameters
my(@params)=('LEX','RULES','STATES');

sub new {
    my($class)=shift;
	my($errst,$nberr,$token,$value,$check,$dotpos);
    my($self)={ ERROR => \&_Error,
				ERRST => \$errst,
                NBERR => \$nberr,
				TOKEN => \$token,
				VALUE => \$value,
				DOTPOS => \$dotpos,
				STACK => [],
				DEBUG => 0,
				CHECK => \$check };

	_CheckParams( [], \%params, \@_, $self );

		exists($$self{VERSION})
	and	$$self{VERSION} < $COMPATIBLE
	and	croak "Yapp driver version $VERSION ".
			  "incompatible with version $$self{VERSION}:\n".
			  "Please recompile parser module.";

        ref($class)
    and $class=ref($class);

    bless($self,$class);
}

sub YYParse {
    my($self)=shift;
    my($retval);

	_CheckParams( \@params, \%params, \@_, $self );

	if($$self{DEBUG}) {
		_DBLoad();
		$retval = eval '$self->_DBParse()';#Do not create stab entry on compile
        $@ and die $@;
	}
	else {
		$retval = $self->_Parse();
	}
    $retval
}

sub YYData {
	my($self)=shift;

		exists($$self{USER})
	or	$$self{USER}={};

	$$self{USER};
	
}

sub YYErrok {
	my($self)=shift;

	${$$self{ERRST}}=0;
    undef;
}

sub YYNberr {
	my($self)=shift;

	${$$self{NBERR}};
}

sub YYRecovering {
	my($self)=shift;

	${$$self{ERRST}} != 0;
}

sub YYAbort {
	my($self)=shift;

	${$$self{CHECK}}='ABORT';
    undef;
}

sub YYAccept {
	my($self)=shift;

	${$$self{CHECK}}='ACCEPT';
    undef;
}

sub YYError {
	my($self)=shift;

	${$$self{CHECK}}='ERROR';
    undef;
}

sub YYSemval {
	my($self)=shift;
	my($index)= $_[0] - ${$$self{DOTPOS}} - 1;

		$index < 0
	and	-$index <= @{$$self{STACK}}
	and	return $$self{STACK}[$index][1];

	undef;	#Invalid index
}

sub YYCurtok {
	my($self)=shift;

        @_
    and ${$$self{TOKEN}}=$_[0];
    ${$$self{TOKEN}};
}

sub YYCurval {
	my($self)=shift;

        @_
    and ${$$self{VALUE}}=$_[0];
    ${$$self{VALUE}};
}

sub YYExpect {
    my($self)=shift;

    keys %{$self->{STATES}[$self->{STACK}[-1][0]]{ACTIONS}}
}

sub YYLexer {
    my($self)=shift;

	$$self{LEX};
}


#################
# Private stuff #
#################


sub _CheckParams {
	my($mandatory,$checklist,$inarray,$outhash)=@_;
	my($prm,$value);
	my($prmlst)={};

	while(($prm,$value)=splice(@$inarray,0,2)) {
        $prm=uc($prm);
			exists($$checklist{$prm})
		or	croak("Unknow parameter '$prm'");
			ref($value) eq $$checklist{$prm}
		or	croak("Invalid value for parameter '$prm'");
        $prm=unpack('@2A*',$prm);
		$$outhash{$prm}=$value;
	}
	for (@$mandatory) {
			exists($$outhash{$_})
		or	croak("Missing mandatory parameter '".lc($_)."'");
	}
}

sub _Error {
	print "Parse error.\n";
}

sub _DBLoad {
	{
		no strict 'refs';

			exists(${__PACKAGE__.'::'}{_DBParse})#Already loaded ?
		and	return;
	}
	my($fname)=__FILE__;
	my(@drv);
	open(DRV,"<$fname") or die "Report this as a BUG: Cannot open $fname";
	while(<DRV>) {
                	/^\s*sub\s+_Parse\s*{\s*$/ .. /^\s*}\s*#\s*_Parse\s*$/
        	and     do {
                	s/^#DBG>//;
                	push(@drv,$_);
        	}
	}
	close(DRV);

	$drv[0]=~s/_P/_DBP/;
	eval join('',@drv);
}

#Note that for loading debugging version of the driver,
#this file will be parsed from 'sub _Parse' up to '}#_Parse' inclusive.
#So, DO NOT remove comment at end of sub !!!
sub _Parse {
    my($self)=shift;

	my($rules,$states,$lex,$error)
     = @$self{ 'RULES', 'STATES', 'LEX', 'ERROR' };
	my($errstatus,$nberror,$token,$value,$stack,$check,$dotpos)
     = @$self{ 'ERRST', 'NBERR', 'TOKEN', 'VALUE', 'STACK', 'CHECK', 'DOTPOS' };

#DBG>	my($debug)=$$self{DEBUG};
#DBG>	my($dbgerror)=0;

#DBG>	my($ShowCurToken) = sub {
#DBG>		my($tok)='>';
#DBG>		for (split('',$$token)) {
#DBG>			$tok.=		(ord($_) < 32 or ord($_) > 126)
#DBG>					?	sprintf('<%02X>',ord($_))
#DBG>					:	$_;
#DBG>		}
#DBG>		$tok.='<';
#DBG>	};

	$$errstatus=0;
	$$nberror=0;
	($$token,$$value)=(undef,undef);
	@$stack=( [ 0, undef ] );
	$$check='';

    while(1) {
        my($actions,$act,$stateno);

        $stateno=$$stack[-1][0];
        $actions=$$states[$stateno];

#DBG>	print STDERR ('-' x 40),"\n";
#DBG>		$debug & 0x2
#DBG>	and	print STDERR "In state $stateno:\n";
#DBG>		$debug & 0x08
#DBG>	and	print STDERR "Stack:[".
#DBG>					 join(',',map { $$_[0] } @$stack).
#DBG>					 "]\n";


        if  (exists($$actions{ACTIONS})) {

				defined($$token)
            or	do {
				($$token,$$value)=&$lex($self);
#DBG>				$debug & 0x01
#DBG>			and	print STDERR "Need token. Got ".&$ShowCurToken."\n";
			};

            $act=   exists($$actions{ACTIONS}{$$token})
                    ?   $$actions{ACTIONS}{$$token}
                    :   exists($$actions{DEFAULT})
                        ?   $$actions{DEFAULT}
                        :   undef;
        }
        else {
            $act=$$actions{DEFAULT};
#DBG>			$debug & 0x01
#DBG>		and	print STDERR "Don't need token.\n";
        }

            defined($act)
        and do {

                $act > 0
            and do {        #shift

#DBG>				$debug & 0x04
#DBG>			and	print STDERR "Shift and go to state $act.\n";

					$$errstatus
				and	do {
					--$$errstatus;

#DBG>					$debug & 0x10
#DBG>				and	$dbgerror
#DBG>				and	$$errstatus == 0
#DBG>				and	do {
#DBG>					print STDERR "**End of Error recovery.\n";
#DBG>					$dbgerror=0;
#DBG>				};
				};


                push(@$stack,[ $act, $$value ]);

					$$token ne ''	#Don't eat the eof
				and	$$token=$$value=undef;
                next;
            };

            #reduce
            my($lhs,$len,$code,@sempar,$semval);
            ($lhs,$len,$code)=@{$$rules[-$act]};

#DBG>			$debug & 0x04
#DBG>		and	$act
#DBG>		and	print STDERR "Reduce using rule ".-$act." ($lhs,$len): ";

                $act
            or  $self->YYAccept();

            $$dotpos=$len;

                unpack('A1',$lhs) eq '@'    #In line rule
            and do {
                    $lhs =~ /^\@[0-9]+\-([0-9]+)$/
                or  die "In line rule name '$lhs' ill formed: ".
                        "report it as a BUG.\n";
                $$dotpos = $1;
            };

            @sempar =       $$dotpos
                        ?   map { $$_[1] } @$stack[ -$$dotpos .. -1 ]
                        :   ();

            $semval = $code ? &$code( $self, @sempar )
                            : @sempar ? $sempar[0] : undef;

            splice(@$stack,-$len,$len);

                $$check eq 'ACCEPT'
            and do {

#DBG>			$debug & 0x04
#DBG>		and	print STDERR "Accept.\n";

				return($semval);
			};

                $$check eq 'ABORT'
            and	do {

#DBG>			$debug & 0x04
#DBG>		and	print STDERR "Abort.\n";

				return(undef);

			};

#DBG>			$debug & 0x04
#DBG>		and	print STDERR "Back to state $$stack[-1][0], then ";

                $$check eq 'ERROR'
            or  do {
#DBG>				$debug & 0x04
#DBG>			and	print STDERR 
#DBG>				    "go to state $$states[$$stack[-1][0]]{GOTOS}{$lhs}.\n";

#DBG>				$debug & 0x10
#DBG>			and	$dbgerror
#DBG>			and	$$errstatus == 0
#DBG>			and	do {
#DBG>				print STDERR "**End of Error recovery.\n";
#DBG>				$dbgerror=0;
#DBG>			};

			    push(@$stack,
                     [ $$states[$$stack[-1][0]]{GOTOS}{$lhs}, $semval ]);
                $$check='';
                next;
            };

#DBG>			$debug & 0x04
#DBG>		and	print STDERR "Forced Error recovery.\n";

            $$check='';

        };

        #Error
            $$errstatus
        or   do {

            $$errstatus = 1;
            &$error($self);
                $$errstatus # if 0, then YYErrok has been called
            or  next;       # so continue parsing

#DBG>			$debug & 0x10
#DBG>		and	do {
#DBG>			print STDERR "**Entering Error recovery.\n";
#DBG>			++$dbgerror;
#DBG>		};

            ++$$nberror;

        };

			$$errstatus == 3	#The next token is not valid: discard it
		and	do {
				$$token eq ''	# End of input: no hope
			and	do {
#DBG>				$debug & 0x10
#DBG>			and	print STDERR "**At eof: aborting.\n";
				return(undef);
			};

#DBG>			$debug & 0x10
#DBG>		and	print STDERR "**Dicard invalid token ".&$ShowCurToken.".\n";

			$$token=$$value=undef;
		};

        $$errstatus=3;

		while(	  @$stack
			  and (		not exists($$states[$$stack[-1][0]]{ACTIONS})
			        or  not exists($$states[$$stack[-1][0]]{ACTIONS}{error})
					or	$$states[$$stack[-1][0]]{ACTIONS}{error} <= 0)) {

#DBG>			$debug & 0x10
#DBG>		and	print STDERR "**Pop state $$stack[-1][0].\n";

			pop(@$stack);
		}

			@$stack
		or	do {

#DBG>			$debug & 0x10
#DBG>		and	print STDERR "**No state left on stack: aborting.\n";

			return(undef);
		};

		#shift the error token

#DBG>			$debug & 0x10
#DBG>		and	print STDERR "**Shift \$error token and go to state ".
#DBG>						 $$states[$$stack[-1][0]]{ACTIONS}{error}.
#DBG>						 ".\n";

		push(@$stack, [ $$states[$$stack[-1][0]]{ACTIONS}{error}, undef ]);

    }

    #never reached
	croak("Error in driver logic. Please, report it as a BUG");

}#_Parse
#DO NOT remove comment

1;

}
#End of include--------------------------------------------------




sub new {
        my($class)=shift;
        ref($class)
    and $class=ref($class);

    my($self)=$class->SUPER::new( yyversion => '1.05',
                                  yystates =>
[
	{#State 0
		ACTIONS => {
			'variable_verbatim' => 15,
			'string' => 8,
			'tag_else' => 9,
			"<#" => 10,
			"whitespace" => 19,
			"<\@" => -19,
			"\${" => 21
		},
		DEFAULT => -3,
		GOTOS => {
			'tag_assign' => 3,
			'tag_ftl' => 2,
			'whitespace' => 1,
			'content_item' => 5,
			'variable' => 4,
			'tmp_tag_condition' => 16,
			'tag_list' => 6,
			'tag_dump' => 18,
			'tag_if' => 17,
			'content' => 7,
			'tag_macro' => 11,
			'tag_open_start' => 20,
			'tag_macro_call' => 12,
			'tag' => 13,
			'tag_comment' => 14
		}
	},
	{#State 1
		ACTIONS => {
			"<\@" => 22
		},
		GOTOS => {
			'tag_macro_open_start' => 23
		}
	},
	{#State 2
		DEFAULT => -15
	},
	{#State 3
		DEFAULT => -8
	},
	{#State 4
		DEFAULT => -5
	},
	{#State 5
		ACTIONS => {
			'variable_verbatim' => 15,
			'string' => 8,
			'tag_else' => 9,
			"<#" => 10,
			"whitespace" => 19,
			"<\@" => -19,
			"\${" => 21
		},
		DEFAULT => -1,
		GOTOS => {
			'tag_assign' => 3,
			'tag_ftl' => 2,
			'whitespace' => 1,
			'content_item' => 5,
			'variable' => 4,
			'tmp_tag_condition' => 16,
			'tag_list' => 6,
			'tag_if' => 17,
			'tag_dump' => 18,
			'content' => 24,
			'tag_macro' => 11,
			'tag_open_start' => 20,
			'tag_macro_call' => 12,
			'tag' => 13,
			'tag_comment' => 14
		}
	},
	{#State 6
		DEFAULT => -11
	},
	{#State 7
		ACTIONS => {
			'' => 25
		}
	},
	{#State 8
		DEFAULT => -7
	},
	{#State 9
		DEFAULT => -13
	},
	{#State 10
		ACTIONS => {
			"dump" => 26
		},
		DEFAULT => -96
	},
	{#State 11
		DEFAULT => -9
	},
	{#State 12
		DEFAULT => -10
	},
	{#State 13
		DEFAULT => -4
	},
	{#State 14
		DEFAULT => -16
	},
	{#State 15
		DEFAULT => -6
	},
	{#State 16
		DEFAULT => -14
	},
	{#State 17
		DEFAULT => -12
	},
	{#State 18
		DEFAULT => -17
	},
	{#State 19
		DEFAULT => -18
	},
	{#State 20
		ACTIONS => {
			"if" => 28,
			"list" => 32,
			"ftl" => 30,
			"assign" => 34,
			"_if_" => 27,
			"macro" => 35,
			"--" => 29
		},
		GOTOS => {
			'directive_assign' => 31,
			'directive_macro' => 33
		}
	},
	{#State 21
		DEFAULT => -149,
		GOTOS => {
			'@24-1' => 36
		}
	},
	{#State 22
		DEFAULT => -97
	},
	{#State 23
		DEFAULT => -124,
		GOTOS => {
			'@9-2' => 37
		}
	},
	{#State 24
		DEFAULT => -2
	},
	{#State 25
		DEFAULT => 0
	},
	{#State 26
		DEFAULT => -146,
		GOTOS => {
			'@22-2' => 38
		}
	},
	{#State 27
		DEFAULT => -135,
		GOTOS => {
			'@17-2' => 39
		}
	},
	{#State 28
		DEFAULT => -132,
		GOTOS => {
			'@15-2' => 40
		}
	},
	{#State 29
		DEFAULT => -144,
		GOTOS => {
			'@21-2' => 41
		}
	},
	{#State 30
		DEFAULT => -138,
		GOTOS => {
			'@19-2' => 42
		}
	},
	{#State 31
		ACTIONS => {
			'DATA_KEY' => 43
		},
		GOTOS => {
			'expr_assignments' => 45,
			'expr_assignment' => 44
		}
	},
	{#State 32
		DEFAULT => -128,
		GOTOS => {
			'@12-2' => 46
		}
	},
	{#State 33
		ACTIONS => {
			'DATA_KEY' => 47
		}
	},
	{#State 34
		DEFAULT => -109
	},
	{#State 35
		DEFAULT => -114
	},
	{#State 36
		ACTIONS => {
			"-" => 50,
			".." => 48,
			".vars" => 60,
			"+" => 53,
			'DATA_KEY' => 52,
			"{" => 61,
			'string' => 54,
			"(" => 67,
			'VAR' => 70,
			"r" => 69,
			"false" => 71,
			"true" => 55,
			"[" => 56,
			'NUMBER' => 57
		},
		GOTOS => {
			'exp' => 58,
			'array_str' => 49,
			'hash_op' => 59,
			'array_pos' => 51,
			'type_op' => 62,
			'data' => 63,
			'func_op' => 64,
			'array_op' => 66,
			'hash' => 65,
			'string_op' => 68
		}
	},
	{#State 37
		ACTIONS => {
			'DATA_KEY' => 72
		}
	},
	{#State 38
		ACTIONS => {
			"-" => 50,
			".." => 48,
			".vars" => 60,
			"+" => 53,
			'DATA_KEY' => 52,
			"{" => 61,
			'string' => 54,
			"(" => 67,
			'VAR' => 70,
			"r" => 69,
			"false" => 71,
			"true" => 55,
			"[" => 56,
			'NUMBER' => 57
		},
		GOTOS => {
			'exp' => 58,
			'array_str' => 49,
			'hash_op' => 59,
			'array_pos' => 51,
			'type_op' => 62,
			'data' => 73,
			'func_op' => 64,
			'array_op' => 66,
			'hash' => 65,
			'string_op' => 68
		}
	},
	{#State 39
		ACTIONS => {
			"-" => 50,
			".." => 48,
			".vars" => 60,
			"+" => 53,
			'DATA_KEY' => 52,
			"{" => 61,
			'string' => 54,
			"(" => 77,
			"!" => 74,
			'VAR' => 70,
			"r" => 69,
			"false" => 71,
			"true" => 55,
			"[" => 56,
			'NUMBER' => 57
		},
		GOTOS => {
			'exp' => 58,
			'array_str' => 49,
			'hash_op' => 59,
			'array_pos' => 51,
			'type_op' => 62,
			'data' => 76,
			'func_op' => 64,
			'array_op' => 66,
			'hash' => 65,
			'string_op' => 68,
			'exp_logic' => 75
		}
	},
	{#State 40
		ACTIONS => {
			"(" => 84,
			"!" => 80,
			'string' => 79,
			'NUMBER' => 82
		},
		GOTOS => {
			'exp_logic_unexpanded' => 81,
			'exp_condition_unexpanded' => 83,
			'exp_condition_var_unexpanded' => 78
		}
	},
	{#State 41
		ACTIONS => {
			'string' => 85
		}
	},
	{#State 42
		ACTIONS => {
			'DATA_KEY' => 86
		},
		GOTOS => {
			'expr_ftl_assignments' => 88,
			'expr_ftl_assignment' => 87
		}
	},
	{#State 43
		ACTIONS => {
			"=" => 89
		},
		DEFAULT => -106,
		GOTOS => {
			'@5-3' => 90
		}
	},
	{#State 44
		ACTIONS => {
			'DATA_KEY' => 91
		},
		DEFAULT => -93,
		GOTOS => {
			'expr_assignments' => 92,
			'expr_assignment' => 44
		}
	},
	{#State 45
		DEFAULT => -104,
		GOTOS => {
			'@4-3' => 93
		}
	},
	{#State 46
		ACTIONS => {
			"-" => 50,
			".." => 48,
			".vars" => 60,
			"+" => 53,
			'DATA_KEY' => 52,
			"{" => 61,
			'string' => 54,
			"(" => 67,
			'VAR' => 70,
			"r" => 69,
			"false" => 71,
			"true" => 55,
			"[" => 56,
			'NUMBER' => 57
		},
		GOTOS => {
			'exp' => 58,
			'array_str' => 49,
			'hash_op' => 59,
			'array_pos' => 51,
			'type_op' => 62,
			'data' => 94,
			'func_op' => 64,
			'array_op' => 66,
			'hash' => 65,
			'string_op' => 68
		}
	},
	{#State 47
		ACTIONS => {
			'DATA_KEY' => 95
		},
		DEFAULT => -119,
		GOTOS => {
			'macroparams' => 96,
			'macroparam' => 97
		}
	},
	{#State 48
		ACTIONS => {
			'DATA_KEY' => 99,
			'NUMBER' => 100
		},
		GOTOS => {
			'array_pos' => 98
		}
	},
	{#State 49
		DEFAULT => -214
	},
	{#State 50
		ACTIONS => {
			"-" => 50,
			'VAR' => 70,
			"+" => 53,
			"false" => 71,
			"true" => 55,
			'NUMBER' => 101
		},
		GOTOS => {
			'exp' => 102
		}
	},
	{#State 51
		ACTIONS => {
			".." => 103
		}
	},
	{#State 52
		ACTIONS => {
			".." => -218,
			"(" => 104
		},
		DEFAULT => -151
	},
	{#State 53
		ACTIONS => {
			"-" => 50,
			'VAR' => 70,
			"+" => 53,
			"false" => 71,
			"true" => 55,
			'NUMBER' => 101
		},
		GOTOS => {
			'exp' => 105
		}
	},
	{#State 54
		DEFAULT => -202
	},
	{#State 55
		DEFAULT => -26
	},
	{#State 56
		ACTIONS => {
			"-" => 50,
			"+" => 53,
			"{" => 61,
			'string' => 108,
			'VAR' => 70,
			"false" => 71,
			"true" => 55,
			"[" => 109,
			'NUMBER' => 101,
			"]" => 110
		},
		GOTOS => {
			'hash' => 65,
			'exp' => 111,
			'array_str' => 106,
			'sequence_item' => 113,
			'hash_op' => 112,
			'sequence' => 107,
			'hashes' => 114
		}
	},
	{#State 57
		ACTIONS => {
			".." => -217
		},
		DEFAULT => -23
	},
	{#State 58
		ACTIONS => {
			"-" => 115,
			"+" => 116,
			"%" => 117,
			"^" => 118,
			"*" => 119,
			"/" => 120
		},
		DEFAULT => -158
	},
	{#State 59
		ACTIONS => {
			"+" => 121
		},
		DEFAULT => -155
	},
	{#State 60
		DEFAULT => -152
	},
	{#State 61
		ACTIONS => {
			'string' => 122
		},
		GOTOS => {
			'hashvalue' => 123,
			'hashvalues' => 124
		}
	},
	{#State 62
		DEFAULT => -154
	},
	{#State 63
		ACTIONS => {
			"}" => 125,
			"!=" => 133,
			"?" => 134,
			"+" => 126,
			"gte" => 135,
			"==" => 128,
			"lte" => 127,
			"??" => 136,
			"!" => 129,
			"*" => 130,
			"gt" => 137,
			"[" => 131,
			"." => 138,
			"lt" => 132
		}
	},
	{#State 64
		DEFAULT => -157
	},
	{#State 65
		DEFAULT => -208
	},
	{#State 66
		DEFAULT => -156
	},
	{#State 67
		ACTIONS => {
			"-" => 50,
			".." => 48,
			".vars" => 60,
			"+" => 53,
			'DATA_KEY' => 52,
			"{" => 61,
			'string' => 54,
			"(" => 67,
			'VAR' => 70,
			"r" => 69,
			"false" => 71,
			"true" => 55,
			"[" => 56,
			'NUMBER' => 57
		},
		GOTOS => {
			'exp' => 58,
			'array_str' => 49,
			'hash_op' => 59,
			'array_pos' => 51,
			'type_op' => 62,
			'data' => 139,
			'func_op' => 64,
			'array_op' => 66,
			'hash' => 65,
			'string_op' => 68
		}
	},
	{#State 68
		ACTIONS => {
			"+" => 140
		},
		DEFAULT => -153
	},
	{#State 69
		ACTIONS => {
			'string' => 141
		}
	},
	{#State 70
		ACTIONS => {
			"=" => 142
		},
		DEFAULT => -24
	},
	{#State 71
		DEFAULT => -27
	},
	{#State 72
		DEFAULT => -125,
		GOTOS => {
			'@10-4' => 143
		}
	},
	{#State 73
		ACTIONS => {
			"+" => 126,
			"==" => 128,
			"lte" => 127,
			"!" => 129,
			"*" => 130,
			"[" => 131,
			"lt" => 132,
			"!=" => 133,
			"?" => 134,
			"gte" => 135,
			"??" => 136,
			"gt" => 137,
			"." => 138
		},
		DEFAULT => -147,
		GOTOS => {
			'@23-4' => 144
		}
	},
	{#State 74
		ACTIONS => {
			"-" => 50,
			".." => 48,
			".vars" => 60,
			"+" => 53,
			'DATA_KEY' => 52,
			"{" => 61,
			'string' => 54,
			"(" => 77,
			"!" => 74,
			'VAR' => 70,
			"r" => 69,
			"false" => 71,
			"true" => 55,
			"[" => 56,
			'NUMBER' => 57
		},
		GOTOS => {
			'exp' => 58,
			'array_str' => 49,
			'hash_op' => 59,
			'array_pos' => 51,
			'type_op' => 62,
			'data' => 76,
			'func_op' => 64,
			'array_op' => 66,
			'hash' => 65,
			'string_op' => 68,
			'exp_logic' => 145
		}
	},
	{#State 75
		ACTIONS => {
			"!" => 146,
			"&&" => 148,
			"||" => 147
		},
		DEFAULT => -136,
		GOTOS => {
			'@18-4' => 149
		}
	},
	{#State 76
		ACTIONS => {
			"+" => 126,
			"==" => 128,
			"lte" => 127,
			"!" => 129,
			"*" => 130,
			"[" => 131,
			"lt" => 132,
			"!=" => 133,
			"?" => 134,
			"gte" => 135,
			"??" => 136,
			"gt" => 137,
			"." => 138
		},
		DEFAULT => -36
	},
	{#State 77
		ACTIONS => {
			"-" => 50,
			".." => 48,
			".vars" => 60,
			"+" => 53,
			'DATA_KEY' => 52,
			"{" => 61,
			'string' => 54,
			"(" => 77,
			"!" => 74,
			'VAR' => 70,
			"r" => 69,
			"false" => 71,
			"true" => 55,
			"[" => 56,
			'NUMBER' => 57
		},
		GOTOS => {
			'exp' => 58,
			'array_str' => 49,
			'hash_op' => 59,
			'array_pos' => 51,
			'type_op' => 62,
			'data' => 151,
			'func_op' => 64,
			'array_op' => 66,
			'hash' => 65,
			'string_op' => 68,
			'exp_logic' => 150
		}
	},
	{#State 78
		ACTIONS => {
			"!=" => 155,
			"gte" => 156,
			"==" => 153,
			"lte" => 152,
			"=" => 158,
			"??" => 157,
			"gt" => 159,
			"lt" => 154
		},
		DEFAULT => -48
	},
	{#State 79
		ACTIONS => {
			"?" => 160
		},
		DEFAULT => -60
	},
	{#State 80
		ACTIONS => {
			"(" => 84,
			"!" => 80,
			'string' => 79,
			'NUMBER' => 82
		},
		GOTOS => {
			'exp_logic_unexpanded' => 161,
			'exp_condition_unexpanded' => 83,
			'exp_condition_var_unexpanded' => 78
		}
	},
	{#State 81
		ACTIONS => {
			"!" => 163,
			"&&" => 165,
			"||" => 164
		},
		DEFAULT => -133,
		GOTOS => {
			'@16-4' => 162
		}
	},
	{#State 82
		DEFAULT => -62
	},
	{#State 83
		DEFAULT => -42
	},
	{#State 84
		ACTIONS => {
			"(" => 84,
			"!" => 80,
			'string' => 79,
			'NUMBER' => 82
		},
		GOTOS => {
			'exp_logic_unexpanded' => 166,
			'exp_condition_unexpanded' => 83,
			'exp_condition_var_unexpanded' => 78
		}
	},
	{#State 85
		ACTIONS => {
			"--" => 167
		}
	},
	{#State 86
		ACTIONS => {
			"=" => 168
		}
	},
	{#State 87
		ACTIONS => {
			'DATA_KEY' => 86
		},
		DEFAULT => -141,
		GOTOS => {
			'expr_ftl_assignments' => 169,
			'expr_ftl_assignment' => 87
		}
	},
	{#State 88
		DEFAULT => -139,
		GOTOS => {
			'@20-4' => 170
		}
	},
	{#State 89
		ACTIONS => {
			"-" => 50,
			".." => 48,
			".vars" => 60,
			"+" => 53,
			'DATA_KEY' => 52,
			"{" => 61,
			'string' => 54,
			"(" => 67,
			'VAR' => 70,
			"r" => 69,
			"false" => 71,
			"true" => 55,
			"[" => 56,
			'NUMBER' => 57
		},
		GOTOS => {
			'exp' => 58,
			'array_str' => 49,
			'hash_op' => 59,
			'array_pos' => 51,
			'type_op' => 62,
			'data' => 171,
			'func_op' => 64,
			'array_op' => 66,
			'hash' => 65,
			'string_op' => 68
		}
	},
	{#State 90
		ACTIONS => {
			">" => 173
		},
		GOTOS => {
			'tag_open_end' => 172
		}
	},
	{#State 91
		ACTIONS => {
			"=" => 89
		}
	},
	{#State 92
		DEFAULT => -94
	},
	{#State 93
		ACTIONS => {
			">" => 173
		},
		GOTOS => {
			'tag_open_end' => 174
		}
	},
	{#State 94
		ACTIONS => {
			"!=" => 133,
			"?" => 134,
			"+" => 126,
			"gte" => 135,
			"==" => 128,
			"lte" => 127,
			"??" => 136,
			"!" => 129,
			"*" => 130,
			"gt" => 137,
			"[" => 131,
			"as" => 175,
			"." => 138,
			"lt" => 132
		}
	},
	{#State 95
		DEFAULT => -118
	},
	{#State 96
		DEFAULT => -111,
		GOTOS => {
			'@7-4' => 176
		}
	},
	{#State 97
		ACTIONS => {
			'DATA_KEY' => 95
		},
		DEFAULT => -116,
		GOTOS => {
			'macroparams' => 177,
			'macroparam' => 97
		}
	},
	{#State 98
		DEFAULT => -216
	},
	{#State 99
		DEFAULT => -218
	},
	{#State 100
		DEFAULT => -217
	},
	{#State 101
		DEFAULT => -23
	},
	{#State 102
		ACTIONS => {
			"-" => 115,
			"+" => 116,
			"%" => 117,
			"^" => 118,
			"*" => 119,
			"/" => 120
		},
		DEFAULT => -32
	},
	{#State 103
		ACTIONS => {
			'DATA_KEY' => 99,
			'NUMBER' => 100
		},
		GOTOS => {
			'array_pos' => 178
		}
	},
	{#State 104
		ACTIONS => {
			'string' => 179
		}
	},
	{#State 105
		ACTIONS => {
			"-" => 115,
			"+" => 116,
			"%" => 117,
			"^" => 118,
			"*" => 119,
			"/" => 120
		},
		DEFAULT => -33
	},
	{#State 106
		DEFAULT => -85
	},
	{#State 107
		ACTIONS => {
			"]" => 180
		}
	},
	{#State 108
		DEFAULT => -87
	},
	{#State 109
		ACTIONS => {
			"-" => 50,
			"+" => 53,
			'string' => 108,
			'VAR' => 70,
			"false" => 71,
			"true" => 55,
			"[" => 109,
			'NUMBER' => 101,
			"]" => 110
		},
		GOTOS => {
			'exp' => 111,
			'array_str' => 106,
			'sequence_item' => 113,
			'sequence' => 107
		}
	},
	{#State 110
		DEFAULT => -90
	},
	{#State 111
		ACTIONS => {
			"-" => 115,
			"+" => 116,
			"/" => 120,
			"%" => 117,
			"^" => 118,
			"*" => 119
		},
		DEFAULT => -86
	},
	{#State 112
		ACTIONS => {
			"+" => 121
		},
		DEFAULT => -206
	},
	{#State 113
		ACTIONS => {
			"," => 181
		},
		DEFAULT => -88
	},
	{#State 114
		ACTIONS => {
			"," => 182,
			"]" => 183
		}
	},
	{#State 115
		ACTIONS => {
			"-" => 50,
			'VAR' => 70,
			"+" => 53,
			"false" => 71,
			"true" => 55,
			'NUMBER' => 101
		},
		GOTOS => {
			'exp' => 184
		}
	},
	{#State 116
		ACTIONS => {
			"-" => 50,
			'VAR' => 70,
			"+" => 53,
			"false" => 71,
			"true" => 55,
			'NUMBER' => 101
		},
		GOTOS => {
			'exp' => 185
		}
	},
	{#State 117
		ACTIONS => {
			"-" => 50,
			'VAR' => 70,
			"+" => 53,
			"false" => 71,
			"true" => 55,
			'NUMBER' => 101
		},
		GOTOS => {
			'exp' => 186
		}
	},
	{#State 118
		ACTIONS => {
			"-" => 50,
			'VAR' => 70,
			"+" => 53,
			"false" => 71,
			"true" => 55,
			'NUMBER' => 101
		},
		GOTOS => {
			'exp' => 187
		}
	},
	{#State 119
		ACTIONS => {
			"-" => 50,
			'VAR' => 70,
			"+" => 53,
			"false" => 71,
			"true" => 55,
			'NUMBER' => 101
		},
		GOTOS => {
			'exp' => 188
		}
	},
	{#State 120
		ACTIONS => {
			"-" => 50,
			'VAR' => 70,
			"+" => 53,
			"false" => 71,
			"true" => 55,
			'NUMBER' => 101
		},
		GOTOS => {
			'exp' => 189
		}
	},
	{#State 121
		ACTIONS => {
			"{" => 61
		},
		GOTOS => {
			'hash' => 190
		}
	},
	{#State 122
		ACTIONS => {
			":" => 191
		}
	},
	{#State 123
		DEFAULT => -211
	},
	{#State 124
		ACTIONS => {
			"}" => 192,
			"," => 193
		}
	},
	{#State 125
		DEFAULT => -150
	},
	{#State 126
		ACTIONS => {
			"-" => 50,
			".." => 48,
			".vars" => 60,
			"+" => 53,
			'DATA_KEY' => 52,
			"{" => 61,
			'string' => 54,
			"(" => 67,
			'VAR' => 70,
			"r" => 69,
			"false" => 71,
			"true" => 55,
			"[" => 56,
			'NUMBER' => 57
		},
		GOTOS => {
			'exp' => 58,
			'array_str' => 49,
			'hash_op' => 59,
			'array_pos' => 51,
			'type_op' => 62,
			'data' => 194,
			'func_op' => 64,
			'array_op' => 66,
			'hash' => 65,
			'string_op' => 68
		}
	},
	{#State 127
		ACTIONS => {
			"-" => 50,
			".." => 48,
			".vars" => 60,
			"+" => 53,
			'DATA_KEY' => 52,
			"{" => 61,
			'string' => 54,
			"(" => 67,
			'VAR' => 70,
			"r" => 69,
			"false" => 71,
			"true" => 55,
			"[" => 56,
			'NUMBER' => 57
		},
		GOTOS => {
			'exp' => 58,
			'array_str' => 49,
			'hash_op' => 59,
			'array_pos' => 51,
			'type_op' => 62,
			'data' => 195,
			'func_op' => 64,
			'array_op' => 66,
			'hash' => 65,
			'string_op' => 68
		}
	},
	{#State 128
		ACTIONS => {
			"-" => 50,
			".." => 48,
			".vars" => 60,
			"+" => 53,
			'DATA_KEY' => 52,
			"{" => 61,
			'string' => 54,
			"(" => 67,
			'VAR' => 70,
			"r" => 69,
			"false" => 71,
			"true" => 55,
			"[" => 56,
			'NUMBER' => 57
		},
		GOTOS => {
			'exp' => 58,
			'array_str' => 49,
			'hash_op' => 59,
			'array_pos' => 51,
			'type_op' => 62,
			'data' => 196,
			'func_op' => 64,
			'array_op' => 66,
			'hash' => 65,
			'string_op' => 68
		}
	},
	{#State 129
		ACTIONS => {
			"-" => 50,
			".." => 48,
			".vars" => 60,
			"+" => 53,
			'DATA_KEY' => 52,
			"{" => 61,
			'string' => 54,
			"(" => 67,
			'VAR' => 70,
			"r" => 69,
			"false" => 71,
			"true" => 55,
			"[" => 56,
			'NUMBER' => 57
		},
		GOTOS => {
			'exp' => 58,
			'array_str' => 49,
			'hash_op' => 59,
			'array_pos' => 51,
			'type_op' => 62,
			'data' => 197,
			'func_op' => 64,
			'array_op' => 66,
			'hash' => 65,
			'string_op' => 68
		}
	},
	{#State 130
		ACTIONS => {
			"-" => 50,
			".." => 48,
			".vars" => 60,
			"+" => 53,
			'DATA_KEY' => 52,
			"{" => 61,
			'string' => 54,
			"(" => 67,
			'VAR' => 70,
			"r" => 69,
			"false" => 71,
			"true" => 55,
			"[" => 56,
			'NUMBER' => 57
		},
		GOTOS => {
			'exp' => 58,
			'array_str' => 49,
			'hash_op' => 59,
			'array_pos' => 51,
			'type_op' => 62,
			'data' => 198,
			'func_op' => 64,
			'array_op' => 66,
			'hash' => 65,
			'string_op' => 68
		}
	},
	{#State 131
		ACTIONS => {
			".." => 199,
			"-" => 50,
			'DATA_KEY' => 201,
			"+" => 53,
			'string' => 202,
			'VAR' => 70,
			"false" => 71,
			"true" => 55,
			'NUMBER' => 57,
			"]" => 203
		},
		GOTOS => {
			'exp' => 204,
			'array_pos' => 200
		}
	},
	{#State 132
		ACTIONS => {
			"-" => 50,
			".." => 48,
			".vars" => 60,
			"+" => 53,
			'DATA_KEY' => 52,
			"{" => 61,
			'string' => 54,
			"(" => 67,
			'VAR' => 70,
			"r" => 69,
			"false" => 71,
			"true" => 55,
			"[" => 56,
			'NUMBER' => 57
		},
		GOTOS => {
			'exp' => 58,
			'array_str' => 49,
			'hash_op' => 59,
			'array_pos' => 51,
			'type_op' => 62,
			'data' => 205,
			'func_op' => 64,
			'array_op' => 66,
			'hash' => 65,
			'string_op' => 68
		}
	},
	{#State 133
		ACTIONS => {
			"-" => 50,
			".." => 48,
			".vars" => 60,
			"+" => 53,
			'DATA_KEY' => 52,
			"{" => 61,
			'string' => 54,
			"(" => 67,
			'VAR' => 70,
			"r" => 69,
			"false" => 71,
			"true" => 55,
			"[" => 56,
			'NUMBER' => 57
		},
		GOTOS => {
			'exp' => 58,
			'array_str' => 49,
			'hash_op' => 59,
			'array_pos' => 51,
			'type_op' => 62,
			'data' => 206,
			'func_op' => 64,
			'array_op' => 66,
			'hash' => 65,
			'string_op' => 68
		}
	},
	{#State 134
		ACTIONS => {
			"sort" => 208,
			"reverse" => 207,
			"xhtml" => 209,
			"replace" => 212,
			"string" => 211,
			"upper_case" => 210,
			"length" => 213,
			"eval" => 214,
			"seq_contains" => 215,
			"lower_case" => 216,
			"html" => 217,
			"substring" => 218,
			"join" => 219,
			"uncap_first" => 220,
			"cap_first" => 221,
			"first" => 222,
			"seq_index_of" => 224,
			"word_list" => 223,
			"sort_by" => 226,
			"last" => 225,
			"size" => 227,
			"capitalize" => 228
		}
	},
	{#State 135
		ACTIONS => {
			"-" => 50,
			".." => 48,
			".vars" => 60,
			"+" => 53,
			'DATA_KEY' => 52,
			"{" => 61,
			'string' => 54,
			"(" => 67,
			'VAR' => 70,
			"r" => 69,
			"false" => 71,
			"true" => 55,
			"[" => 56,
			'NUMBER' => 57
		},
		GOTOS => {
			'exp' => 58,
			'array_str' => 49,
			'hash_op' => 59,
			'array_pos' => 51,
			'type_op' => 62,
			'data' => 229,
			'func_op' => 64,
			'array_op' => 66,
			'hash' => 65,
			'string_op' => 68
		}
	},
	{#State 136
		DEFAULT => -197
	},
	{#State 137
		ACTIONS => {
			"-" => 50,
			".." => 48,
			".vars" => 60,
			"+" => 53,
			'DATA_KEY' => 52,
			"{" => 61,
			'string' => 54,
			"(" => 67,
			'VAR' => 70,
			"r" => 69,
			"false" => 71,
			"true" => 55,
			"[" => 56,
			'NUMBER' => 57
		},
		GOTOS => {
			'exp' => 58,
			'array_str' => 49,
			'hash_op' => 59,
			'array_pos' => 51,
			'type_op' => 62,
			'data' => 230,
			'func_op' => 64,
			'array_op' => 66,
			'hash' => 65,
			'string_op' => 68
		}
	},
	{#State 138
		ACTIONS => {
			'DATA_KEY' => 231
		}
	},
	{#State 139
		ACTIONS => {
			"!=" => 133,
			"?" => 134,
			"+" => 126,
			"gte" => 135,
			"==" => 128,
			"lte" => 127,
			"??" => 136,
			"!" => 129,
			"*" => 130,
			"gt" => 137,
			"[" => 131,
			"." => 138,
			")" => 232,
			"lt" => 132
		}
	},
	{#State 140
		ACTIONS => {
			"-" => 50,
			".." => 48,
			".vars" => 60,
			"+" => 53,
			'DATA_KEY' => 52,
			"{" => 61,
			'string' => 54,
			"(" => 67,
			'VAR' => 70,
			"r" => 69,
			"false" => 71,
			"true" => 55,
			"[" => 56,
			'NUMBER' => 57
		},
		GOTOS => {
			'exp' => 58,
			'array_str' => 49,
			'hash_op' => 59,
			'array_pos' => 51,
			'type_op' => 62,
			'data' => 233,
			'func_op' => 64,
			'array_op' => 66,
			'hash' => 65,
			'string_op' => 68
		}
	},
	{#State 141
		DEFAULT => -204
	},
	{#State 142
		ACTIONS => {
			"-" => 50,
			'VAR' => 70,
			"+" => 53,
			"false" => 71,
			"true" => 55,
			'NUMBER' => 101
		},
		GOTOS => {
			'exp' => 234
		}
	},
	{#State 143
		ACTIONS => {
			'DATA_KEY' => 235
		},
		DEFAULT => -123,
		GOTOS => {
			'macro_assignments' => 236,
			'macro_assignment' => 237
		}
	},
	{#State 144
		ACTIONS => {
			"whitespace" => 19
		},
		DEFAULT => -19,
		GOTOS => {
			'whitespace' => 238
		}
	},
	{#State 145
		ACTIONS => {
			"!" => 146,
			"&&" => 148,
			"||" => 147
		},
		DEFAULT => -40
	},
	{#State 146
		ACTIONS => {
			"-" => 50,
			".." => 48,
			".vars" => 60,
			"+" => 53,
			'DATA_KEY' => 52,
			"{" => 61,
			'string' => 54,
			"(" => 77,
			"!" => 74,
			'VAR' => 70,
			"r" => 69,
			"false" => 71,
			"true" => 55,
			"[" => 56,
			'NUMBER' => 57
		},
		GOTOS => {
			'exp' => 58,
			'array_str' => 49,
			'hash_op' => 59,
			'array_pos' => 51,
			'type_op' => 62,
			'data' => 76,
			'func_op' => 64,
			'array_op' => 66,
			'hash' => 65,
			'string_op' => 68,
			'exp_logic' => 239
		}
	},
	{#State 147
		ACTIONS => {
			"-" => 50,
			".." => 48,
			".vars" => 60,
			"+" => 53,
			'DATA_KEY' => 52,
			"{" => 61,
			'string' => 54,
			"(" => 77,
			"!" => 74,
			'VAR' => 70,
			"r" => 69,
			"false" => 71,
			"true" => 55,
			"[" => 56,
			'NUMBER' => 57
		},
		GOTOS => {
			'exp' => 58,
			'array_str' => 49,
			'hash_op' => 59,
			'array_pos' => 51,
			'type_op' => 62,
			'data' => 76,
			'func_op' => 64,
			'array_op' => 66,
			'hash' => 65,
			'string_op' => 68,
			'exp_logic' => 240
		}
	},
	{#State 148
		ACTIONS => {
			"-" => 50,
			".." => 48,
			".vars" => 60,
			"+" => 53,
			'DATA_KEY' => 52,
			"{" => 61,
			'string' => 54,
			"(" => 77,
			"!" => 74,
			'VAR' => 70,
			"r" => 69,
			"false" => 71,
			"true" => 55,
			"[" => 56,
			'NUMBER' => 57
		},
		GOTOS => {
			'exp' => 58,
			'array_str' => 49,
			'hash_op' => 59,
			'array_pos' => 51,
			'type_op' => 62,
			'data' => 76,
			'func_op' => 64,
			'array_op' => 66,
			'hash' => 65,
			'string_op' => 68,
			'exp_logic' => 241
		}
	},
	{#State 149
		ACTIONS => {
			">" => 173
		},
		GOTOS => {
			'tag_open_end' => 242
		}
	},
	{#State 150
		ACTIONS => {
			"!" => 146,
			"&&" => 148,
			"||" => 147,
			")" => 243
		}
	},
	{#State 151
		ACTIONS => {
			"+" => 126,
			"==" => 128,
			"lte" => 127,
			"!" => 129,
			"*" => 130,
			"[" => 131,
			")" => 232,
			"lt" => 132,
			"!=" => 133,
			"?" => 134,
			"gte" => 135,
			"??" => 136,
			"gt" => 137,
			"." => 138
		},
		DEFAULT => -36
	},
	{#State 152
		ACTIONS => {
			"-" => 50,
			'VAR' => 70,
			"+" => 53,
			"false" => 71,
			"true" => 55,
			'NUMBER' => 101
		},
		GOTOS => {
			'exp' => 244
		}
	},
	{#State 153
		ACTIONS => {
			"-" => 50,
			'VAR' => 70,
			"+" => 53,
			"false" => 71,
			"true" => 55,
			'string' => 245,
			'NUMBER' => 101
		},
		GOTOS => {
			'exp' => 246
		}
	},
	{#State 154
		ACTIONS => {
			"-" => 50,
			'VAR' => 70,
			"+" => 53,
			"false" => 71,
			"true" => 55,
			'NUMBER' => 101
		},
		GOTOS => {
			'exp' => 247
		}
	},
	{#State 155
		ACTIONS => {
			"-" => 50,
			'VAR' => 70,
			"+" => 53,
			"false" => 71,
			"true" => 55,
			'string' => 248,
			'NUMBER' => 101
		},
		GOTOS => {
			'exp' => 249
		}
	},
	{#State 156
		ACTIONS => {
			"-" => 50,
			'VAR' => 70,
			"+" => 53,
			"false" => 71,
			"true" => 55,
			'NUMBER' => 101
		},
		GOTOS => {
			'exp' => 250
		}
	},
	{#State 157
		DEFAULT => -59
	},
	{#State 158
		ACTIONS => {
			"-" => 50,
			'VAR' => 70,
			"+" => 53,
			"false" => 71,
			"true" => 55,
			'string' => 251,
			'NUMBER' => 101
		},
		GOTOS => {
			'exp' => 252
		}
	},
	{#State 159
		ACTIONS => {
			"-" => 50,
			'VAR' => 70,
			"+" => 53,
			"false" => 71,
			"true" => 55,
			'NUMBER' => 101
		},
		GOTOS => {
			'exp' => 253
		}
	},
	{#State 160
		ACTIONS => {
			"sort" => 255,
			"reverse" => 254,
			"xhtml" => 256,
			"upper_case" => 259,
			"string" => 258,
			"replace" => 257,
			"length" => 260,
			"eval" => 261,
			"seq_contains" => 262,
			"lower_case" => 263,
			"html" => 264,
			"substring" => 265,
			"join" => 266,
			"first" => 267,
			"cap_first" => 268,
			"uncap_first" => 269,
			"word_list" => 271,
			"seq_index_of" => 270,
			"sort_by" => 273,
			"last" => 272,
			"size" => 274,
			"capitalize" => 275
		},
		GOTOS => {
			'op' => 276
		}
	},
	{#State 161
		ACTIONS => {
			"!" => 163,
			"&&" => 165,
			"||" => 164
		},
		DEFAULT => -45
	},
	{#State 162
		ACTIONS => {
			">" => 173
		},
		GOTOS => {
			'tag_open_end' => 277
		}
	},
	{#State 163
		ACTIONS => {
			"(" => 84,
			"!" => 80,
			'string' => 79,
			'NUMBER' => 82
		},
		GOTOS => {
			'exp_logic_unexpanded' => 278,
			'exp_condition_unexpanded' => 83,
			'exp_condition_var_unexpanded' => 78
		}
	},
	{#State 164
		ACTIONS => {
			"(" => 84,
			"!" => 80,
			'string' => 79,
			'NUMBER' => 82
		},
		GOTOS => {
			'exp_logic_unexpanded' => 279,
			'exp_condition_unexpanded' => 83,
			'exp_condition_var_unexpanded' => 78
		}
	},
	{#State 165
		ACTIONS => {
			"(" => 84,
			"!" => 80,
			'string' => 79,
			'NUMBER' => 82
		},
		GOTOS => {
			'exp_logic_unexpanded' => 280,
			'exp_condition_unexpanded' => 83,
			'exp_condition_var_unexpanded' => 78
		}
	},
	{#State 166
		ACTIONS => {
			"!" => 163,
			"&&" => 165,
			"||" => 164,
			")" => 281
		}
	},
	{#State 167
		ACTIONS => {
			">" => 283
		},
		GOTOS => {
			'tag_close_end' => 282
		}
	},
	{#State 168
		ACTIONS => {
			"-" => 50,
			".." => 48,
			".vars" => 60,
			"+" => 53,
			'DATA_KEY' => 52,
			"{" => 61,
			'string' => 54,
			"(" => 67,
			'VAR' => 70,
			"r" => 69,
			"false" => 71,
			"true" => 55,
			"[" => 56,
			'NUMBER' => 57
		},
		GOTOS => {
			'exp' => 58,
			'array_str' => 49,
			'hash_op' => 59,
			'array_pos' => 51,
			'type_op' => 62,
			'data' => 284,
			'func_op' => 64,
			'array_op' => 66,
			'hash' => 65,
			'string_op' => 68
		}
	},
	{#State 169
		DEFAULT => -142
	},
	{#State 170
		ACTIONS => {
			">" => 173
		},
		GOTOS => {
			'tag_open_end' => 285
		}
	},
	{#State 171
		ACTIONS => {
			"+" => 126,
			"==" => 128,
			"lte" => 127,
			"!" => 129,
			"*" => 130,
			"[" => 131,
			"lt" => 132,
			"!=" => 133,
			"?" => 134,
			"gte" => 135,
			"??" => 136,
			"gt" => 137,
			"." => 138
		},
		DEFAULT => -95
	},
	{#State 172
		DEFAULT => -107,
		GOTOS => {
			'@6-5' => 286
		}
	},
	{#State 173
		DEFAULT => -98,
		GOTOS => {
			'@1-1' => 287
		}
	},
	{#State 174
		DEFAULT => -105
	},
	{#State 175
		DEFAULT => -129,
		GOTOS => {
			'@13-5' => 288
		}
	},
	{#State 176
		ACTIONS => {
			">" => 173
		},
		GOTOS => {
			'tag_open_end' => 289
		}
	},
	{#State 177
		DEFAULT => -117
	},
	{#State 178
		DEFAULT => -215
	},
	{#State 179
		ACTIONS => {
			")" => 290
		}
	},
	{#State 180
		DEFAULT => -91
	},
	{#State 181
		ACTIONS => {
			"-" => 50,
			"+" => 53,
			'string' => 108,
			'VAR' => 70,
			"true" => 55,
			"false" => 71,
			"[" => 109,
			'NUMBER' => 101
		},
		GOTOS => {
			'exp' => 111,
			'array_str' => 106,
			'sequence_item' => 113,
			'sequence' => 292
		}
	},
	{#State 182
		ACTIONS => {
			"{" => 61
		},
		GOTOS => {
			'hash' => 65,
			'hash_op' => 293
		}
	},
	{#State 183
		DEFAULT => -213
	},
	{#State 184
		ACTIONS => {
			"%" => 117,
			"^" => 118,
			"*" => 119,
			"/" => 120
		},
		DEFAULT => -29
	},
	{#State 185
		ACTIONS => {
			"%" => 117,
			"^" => 118,
			"*" => 119,
			"/" => 120
		},
		DEFAULT => -28
	},
	{#State 186
		ACTIONS => {
			"^" => 118
		},
		DEFAULT => -35
	},
	{#State 187
		DEFAULT => -34
	},
	{#State 188
		ACTIONS => {
			"^" => 118
		},
		DEFAULT => -30
	},
	{#State 189
		ACTIONS => {
			"^" => 118
		},
		DEFAULT => -31
	},
	{#State 190
		DEFAULT => -209
	},
	{#State 191
		ACTIONS => {
			"-" => 50,
			".." => 48,
			"+" => 53,
			'DATA_KEY' => 99,
			'string' => 294,
			'VAR' => 70,
			"false" => 71,
			"true" => 55,
			"[" => 56,
			'NUMBER' => 57
		},
		GOTOS => {
			'array_op' => 297,
			'exp' => 295,
			'array_str' => 49,
			'array_pos' => 51,
			'value' => 296
		}
	},
	{#State 192
		DEFAULT => -205
	},
	{#State 193
		ACTIONS => {
			'string' => 122
		},
		GOTOS => {
			'hashvalue' => 298
		}
	},
	{#State 194
		ACTIONS => {
			"==" => 128,
			"lte" => 127,
			"*" => 130,
			"[" => 131,
			"lt" => 132,
			"!=" => 133,
			"?" => 134,
			"gte" => 135,
			"??" => 136,
			"gt" => 137,
			"." => 138
		},
		DEFAULT => -162
	},
	{#State 195
		ACTIONS => {
			"==" => 128,
			"lte" => undef,
			"[" => 131,
			"lt" => undef,
			"!=" => 133,
			"?" => 134,
			"gte" => undef,
			"??" => 136,
			"gt" => undef
		},
		DEFAULT => -201
	},
	{#State 196
		ACTIONS => {
			"==" => undef,
			"[" => 131,
			"!=" => undef,
			"?" => 134,
			"??" => 136
		},
		DEFAULT => -195
	},
	{#State 197
		ACTIONS => {
			"+" => 126,
			"==" => 128,
			"lte" => 127,
			"!" => 129,
			"*" => 130,
			"[" => 131,
			"lt" => 132,
			"!=" => 133,
			"?" => 134,
			"gte" => 135,
			"??" => 136,
			"gt" => 137,
			"." => 138
		},
		DEFAULT => -194
	},
	{#State 198
		ACTIONS => {
			"==" => 128,
			"lte" => 127,
			"[" => 131,
			"lt" => 132,
			"!=" => 133,
			"?" => 134,
			"gte" => 135,
			"??" => 136,
			"gt" => 137
		},
		DEFAULT => -161
	},
	{#State 199
		ACTIONS => {
			'DATA_KEY' => 99,
			'NUMBER' => 100
		},
		GOTOS => {
			'array_pos' => 299
		}
	},
	{#State 200
		ACTIONS => {
			".." => 300
		}
	},
	{#State 201
		ACTIONS => {
			"]" => 301
		},
		DEFAULT => -218
	},
	{#State 202
		ACTIONS => {
			"]" => 302
		}
	},
	{#State 203
		DEFAULT => -163
	},
	{#State 204
		ACTIONS => {
			"-" => 115,
			"^" => 118,
			"*" => 119,
			"+" => 116,
			"/" => 120,
			"%" => 117,
			"]" => 303
		}
	},
	{#State 205
		ACTIONS => {
			"==" => 128,
			"lte" => undef,
			"[" => 131,
			"lt" => undef,
			"!=" => 133,
			"?" => 134,
			"gte" => undef,
			"??" => 136,
			"gt" => undef
		},
		DEFAULT => -200
	},
	{#State 206
		ACTIONS => {
			"==" => undef,
			"[" => 131,
			"!=" => undef,
			"?" => 134,
			"??" => 136
		},
		DEFAULT => -196
	},
	{#State 207
		DEFAULT => -176
	},
	{#State 208
		DEFAULT => -171
	},
	{#State 209
		DEFAULT => -183
	},
	{#State 210
		DEFAULT => -192
	},
	{#State 211
		ACTIONS => {
			"(" => 304
		},
		DEFAULT => -187
	},
	{#State 212
		ACTIONS => {
			"(" => 305
		}
	},
	{#State 213
		DEFAULT => -184
	},
	{#State 214
		DEFAULT => -181
	},
	{#State 215
		ACTIONS => {
			"(" => 306
		}
	},
	{#State 216
		DEFAULT => -185
	},
	{#State 217
		DEFAULT => -182
	},
	{#State 218
		ACTIONS => {
			"(" => 307
		}
	},
	{#State 219
		ACTIONS => {
			"(" => 308
		}
	},
	{#State 220
		DEFAULT => -191
	},
	{#State 221
		DEFAULT => -179
	},
	{#State 222
		DEFAULT => -178
	},
	{#State 223
		DEFAULT => -193
	},
	{#State 224
		ACTIONS => {
			"(" => 309
		}
	},
	{#State 225
		DEFAULT => -177
	},
	{#State 226
		ACTIONS => {
			"(" => 310
		}
	},
	{#State 227
		DEFAULT => -172
	},
	{#State 228
		DEFAULT => -180
	},
	{#State 229
		ACTIONS => {
			"==" => 128,
			"lte" => undef,
			"[" => 131,
			"lt" => undef,
			"!=" => 133,
			"?" => 134,
			"gte" => undef,
			"??" => 136,
			"gt" => undef
		},
		DEFAULT => -199
	},
	{#State 230
		ACTIONS => {
			"==" => 128,
			"lte" => undef,
			"[" => 131,
			"lt" => undef,
			"!=" => 133,
			"?" => 134,
			"gte" => undef,
			"??" => 136,
			"gt" => undef
		},
		DEFAULT => -198
	},
	{#State 231
		DEFAULT => -159
	},
	{#State 232
		DEFAULT => -160
	},
	{#State 233
		ACTIONS => {
			"==" => 128,
			"lte" => 127,
			"*" => 130,
			"[" => 131,
			"lt" => 132,
			"!=" => 133,
			"?" => 134,
			"gte" => 135,
			"??" => 136,
			"gt" => 137,
			"." => 138
		},
		DEFAULT => -203
	},
	{#State 234
		DEFAULT => -25
	},
	{#State 235
		ACTIONS => {
			"=" => 311
		}
	},
	{#State 236
		DEFAULT => -126,
		GOTOS => {
			'@11-6' => 312
		}
	},
	{#State 237
		ACTIONS => {
			'DATA_KEY' => 235
		},
		DEFAULT => -120,
		GOTOS => {
			'macro_assignments' => 313,
			'macro_assignment' => 237
		}
	},
	{#State 238
		ACTIONS => {
			"/" => 314
		}
	},
	{#State 239
		ACTIONS => {
			"!" => 146,
			"&&" => 148,
			"||" => 147
		},
		DEFAULT => -39
	},
	{#State 240
		DEFAULT => -38
	},
	{#State 241
		ACTIONS => {
			"||" => 147
		},
		DEFAULT => -37
	},
	{#State 242
		DEFAULT => -137
	},
	{#State 243
		DEFAULT => -41
	},
	{#State 244
		ACTIONS => {
			"-" => 115,
			"+" => 116,
			"/" => 120,
			"%" => 117,
			"^" => 118,
			"*" => 119
		},
		DEFAULT => -54
	},
	{#State 245
		DEFAULT => -52
	},
	{#State 246
		ACTIONS => {
			"-" => 115,
			"+" => 116,
			"/" => 120,
			"%" => 117,
			"^" => 118,
			"*" => 119
		},
		DEFAULT => -50
	},
	{#State 247
		ACTIONS => {
			"-" => 115,
			"+" => 116,
			"/" => 120,
			"%" => 117,
			"^" => 118,
			"*" => 119
		},
		DEFAULT => -56
	},
	{#State 248
		DEFAULT => -58
	},
	{#State 249
		ACTIONS => {
			"-" => 115,
			"+" => 116,
			"/" => 120,
			"%" => 117,
			"^" => 118,
			"*" => 119
		},
		DEFAULT => -57
	},
	{#State 250
		ACTIONS => {
			"-" => 115,
			"+" => 116,
			"/" => 120,
			"%" => 117,
			"^" => 118,
			"*" => 119
		},
		DEFAULT => -53
	},
	{#State 251
		DEFAULT => -51
	},
	{#State 252
		ACTIONS => {
			"-" => 115,
			"+" => 116,
			"/" => 120,
			"%" => 117,
			"^" => 118,
			"*" => 119
		},
		DEFAULT => -49
	},
	{#State 253
		ACTIONS => {
			"-" => 115,
			"+" => 116,
			"/" => 120,
			"%" => 117,
			"^" => 118,
			"*" => 119
		},
		DEFAULT => -55
	},
	{#State 254
		DEFAULT => -81
	},
	{#State 255
		DEFAULT => -77
	},
	{#State 256
		DEFAULT => -71
	},
	{#State 257
		DEFAULT => -68
	},
	{#State 258
		DEFAULT => -67
	},
	{#State 259
		DEFAULT => -64
	},
	{#State 260
		DEFAULT => -70
	},
	{#State 261
		DEFAULT => -73
	},
	{#State 262
		DEFAULT => -80
	},
	{#State 263
		DEFAULT => -69
	},
	{#State 264
		DEFAULT => -72
	},
	{#State 265
		DEFAULT => -66
	},
	{#State 266
		DEFAULT => -83
	},
	{#State 267
		DEFAULT => -84
	},
	{#State 268
		DEFAULT => -75
	},
	{#State 269
		DEFAULT => -65
	},
	{#State 270
		DEFAULT => -79
	},
	{#State 271
		DEFAULT => -63
	},
	{#State 272
		DEFAULT => -82
	},
	{#State 273
		DEFAULT => -76
	},
	{#State 274
		DEFAULT => -78
	},
	{#State 275
		DEFAULT => -74
	},
	{#State 276
		DEFAULT => -61
	},
	{#State 277
		ACTIONS => {
			'variable_verbatim' => 15,
			'string' => 8,
			'tag_else' => 9,
			"<#" => 10,
			"whitespace" => 19,
			"<\@" => -19,
			"\${" => 21
		},
		DEFAULT => -3,
		GOTOS => {
			'tag_assign' => 3,
			'tag_ftl' => 2,
			'whitespace' => 1,
			'content_item' => 5,
			'variable' => 4,
			'tmp_tag_condition' => 16,
			'tag_list' => 6,
			'tag_if' => 17,
			'tag_dump' => 18,
			'content' => 315,
			'tag_macro' => 11,
			'tag_open_start' => 20,
			'tag_macro_call' => 12,
			'tag' => 13,
			'tag_comment' => 14
		}
	},
	{#State 278
		ACTIONS => {
			"!" => 163,
			"&&" => 165,
			"||" => 164
		},
		DEFAULT => -46
	},
	{#State 279
		DEFAULT => -44
	},
	{#State 280
		ACTIONS => {
			"||" => 164
		},
		DEFAULT => -43
	},
	{#State 281
		DEFAULT => -47
	},
	{#State 282
		DEFAULT => -145
	},
	{#State 283
		DEFAULT => -102,
		GOTOS => {
			'@3-1' => 316
		}
	},
	{#State 284
		ACTIONS => {
			"+" => 126,
			"==" => 128,
			"lte" => 127,
			"!" => 129,
			"*" => 130,
			"[" => 131,
			"lt" => 132,
			"!=" => 133,
			"?" => 134,
			"gte" => 135,
			"??" => 136,
			"gt" => 137,
			"." => 138
		},
		DEFAULT => -143
	},
	{#State 285
		DEFAULT => -140
	},
	{#State 286
		ACTIONS => {
			'string' => 317
		}
	},
	{#State 287
		DEFAULT => -99,
		GOTOS => {
			'@2-2' => 318
		}
	},
	{#State 288
		ACTIONS => {
			'string' => 319
		}
	},
	{#State 289
		DEFAULT => -112,
		GOTOS => {
			'@8-6' => 320
		}
	},
	{#State 290
		DEFAULT => -219
	},
	{#State 291
		ACTIONS => {
			"[" => 109
		},
		GOTOS => {
			'array_str' => 321
		}
	},
	{#State 292
		DEFAULT => -89
	},
	{#State 293
		ACTIONS => {
			"+" => 121
		},
		DEFAULT => -207
	},
	{#State 294
		DEFAULT => -22
	},
	{#State 295
		ACTIONS => {
			"-" => 115,
			"+" => 116,
			"/" => 120,
			"%" => 117,
			"^" => 118,
			"*" => 119
		},
		DEFAULT => -21
	},
	{#State 296
		DEFAULT => -210
	},
	{#State 297
		DEFAULT => -20
	},
	{#State 298
		DEFAULT => -212
	},
	{#State 299
		ACTIONS => {
			"]" => 322
		}
	},
	{#State 300
		ACTIONS => {
			'DATA_KEY' => 99,
			"]" => 324,
			'NUMBER' => 100
		},
		GOTOS => {
			'array_pos' => 323
		}
	},
	{#State 301
		DEFAULT => -169
	},
	{#State 302
		DEFAULT => -168
	},
	{#State 303
		DEFAULT => -164
	},
	{#State 304
		ACTIONS => {
			'string' => 325
		}
	},
	{#State 305
		ACTIONS => {
			'string' => 326
		}
	},
	{#State 306
		ACTIONS => {
			"-" => 50,
			".." => 48,
			"+" => 53,
			'DATA_KEY' => 99,
			'string' => 294,
			'VAR' => 70,
			"false" => 71,
			"true" => 55,
			"[" => 56,
			'NUMBER' => 57
		},
		GOTOS => {
			'array_op' => 297,
			'exp' => 295,
			'array_str' => 49,
			'array_pos' => 51,
			'value' => 327
		}
	},
	{#State 307
		ACTIONS => {
			'NUMBER' => 328
		}
	},
	{#State 308
		ACTIONS => {
			'string' => 329
		}
	},
	{#State 309
		ACTIONS => {
			"-" => 50,
			".." => 48,
			"+" => 53,
			'DATA_KEY' => 99,
			'string' => 294,
			'VAR' => 70,
			"false" => 71,
			"true" => 55,
			"[" => 56,
			'NUMBER' => 57
		},
		GOTOS => {
			'array_op' => 297,
			'exp' => 295,
			'array_str' => 49,
			'array_pos' => 51,
			'value' => 330
		}
	},
	{#State 310
		ACTIONS => {
			"-" => 50,
			".." => 48,
			"+" => 53,
			'DATA_KEY' => 99,
			'string' => 294,
			'VAR' => 70,
			"false" => 71,
			"true" => 55,
			"[" => 56,
			'NUMBER' => 57
		},
		GOTOS => {
			'array_op' => 297,
			'exp' => 295,
			'array_str' => 49,
			'array_pos' => 51,
			'value' => 331
		}
	},
	{#State 311
		ACTIONS => {
			"-" => 50,
			".." => 48,
			".vars" => 60,
			"+" => 53,
			'DATA_KEY' => 52,
			"{" => 61,
			'string' => 54,
			"(" => 67,
			'VAR' => 70,
			"r" => 69,
			"false" => 71,
			"true" => 55,
			"[" => 56,
			'NUMBER' => 57
		},
		GOTOS => {
			'exp' => 58,
			'array_str' => 49,
			'hash_op' => 59,
			'array_pos' => 51,
			'type_op' => 62,
			'data' => 332,
			'func_op' => 64,
			'array_op' => 66,
			'hash' => 65,
			'string_op' => 68
		}
	},
	{#State 312
		ACTIONS => {
			"/" => 333
		}
	},
	{#State 313
		DEFAULT => -121
	},
	{#State 314
		ACTIONS => {
			">" => 334
		}
	},
	{#State 315
		ACTIONS => {
			"</#" => 335
		},
		GOTOS => {
			'tag_close_start' => 336
		}
	},
	{#State 316
		ACTIONS => {
			"whitespace" => 19
		},
		DEFAULT => -19,
		GOTOS => {
			'whitespace' => 337
		}
	},
	{#State 317
		ACTIONS => {
			"</#" => 335
		},
		GOTOS => {
			'tag_close_start' => 338
		}
	},
	{#State 318
		ACTIONS => {
			"whitespace" => 19
		},
		DEFAULT => -19,
		GOTOS => {
			'whitespace' => 339
		}
	},
	{#State 319
		ACTIONS => {
			">" => 173
		},
		GOTOS => {
			'tag_open_end' => 340
		}
	},
	{#State 320
		ACTIONS => {
			'variable_verbatim' => 15,
			'string' => 8,
			'tag_else' => 9,
			"<#" => 10,
			"whitespace" => 19,
			"<\@" => -19,
			"\${" => 21
		},
		DEFAULT => -3,
		GOTOS => {
			'tag_assign' => 3,
			'tag_ftl' => 2,
			'whitespace' => 1,
			'content_item' => 5,
			'variable' => 4,
			'tmp_tag_condition' => 16,
			'tag_list' => 6,
			'tag_if' => 17,
			'tag_dump' => 18,
			'content' => 341,
			'tag_macro' => 11,
			'tag_open_start' => 20,
			'tag_macro_call' => 12,
			'tag' => 13,
			'tag_comment' => 14
		}
	},
	{#State 321
		DEFAULT => -92
	},
	{#State 322
		DEFAULT => -167
	},
	{#State 323
		ACTIONS => {
			"]" => 342
		}
	},
	{#State 324
		DEFAULT => -166
	},
	{#State 325
		ACTIONS => {
			"," => 343
		}
	},
	{#State 326
		ACTIONS => {
			"," => 344
		}
	},
	{#State 327
		ACTIONS => {
			")" => 345
		}
	},
	{#State 328
		ACTIONS => {
			"," => 346,
			")" => 347
		}
	},
	{#State 329
		ACTIONS => {
			")" => 348
		}
	},
	{#State 330
		ACTIONS => {
			")" => 349
		}
	},
	{#State 331
		ACTIONS => {
			")" => 350
		}
	},
	{#State 332
		ACTIONS => {
			"+" => 126,
			"==" => 128,
			"lte" => 127,
			"!" => 129,
			"*" => 130,
			"[" => 131,
			"lt" => 132,
			"!=" => 133,
			"?" => 134,
			"gte" => 135,
			"??" => 136,
			"gt" => 137,
			"." => 138
		},
		DEFAULT => -122
	},
	{#State 333
		ACTIONS => {
			">" => 173
		},
		GOTOS => {
			'tag_open_end' => 351
		}
	},
	{#State 334
		DEFAULT => -148
	},
	{#State 335
		DEFAULT => -101
	},
	{#State 336
		ACTIONS => {
			"if" => 352
		}
	},
	{#State 337
		DEFAULT => -103
	},
	{#State 338
		ACTIONS => {
			"assign" => 354
		},
		GOTOS => {
			'directive_assign_end' => 353
		}
	},
	{#State 339
		DEFAULT => -100
	},
	{#State 340
		DEFAULT => -130,
		GOTOS => {
			'@14-8' => 355
		}
	},
	{#State 341
		ACTIONS => {
			"</#" => 335
		},
		GOTOS => {
			'tag_close_start' => 356
		}
	},
	{#State 342
		DEFAULT => -165
	},
	{#State 343
		ACTIONS => {
			'string' => 357
		}
	},
	{#State 344
		ACTIONS => {
			'string' => 358
		}
	},
	{#State 345
		DEFAULT => -175
	},
	{#State 346
		ACTIONS => {
			'NUMBER' => 359
		}
	},
	{#State 347
		DEFAULT => -189
	},
	{#State 348
		DEFAULT => -170
	},
	{#State 349
		DEFAULT => -174
	},
	{#State 350
		DEFAULT => -173
	},
	{#State 351
		DEFAULT => -127
	},
	{#State 352
		ACTIONS => {
			">" => 283
		},
		GOTOS => {
			'tag_close_end' => 360
		}
	},
	{#State 353
		ACTIONS => {
			">" => 283
		},
		GOTOS => {
			'tag_close_end' => 361
		}
	},
	{#State 354
		DEFAULT => -110
	},
	{#State 355
		ACTIONS => {
			'variable_verbatim' => 15,
			'string' => 8,
			'tag_else' => 9,
			"<#" => 10,
			"whitespace" => 19,
			"<\@" => -19,
			"\${" => 21
		},
		DEFAULT => -3,
		GOTOS => {
			'tag_assign' => 3,
			'tag_ftl' => 2,
			'whitespace' => 1,
			'content_item' => 5,
			'variable' => 4,
			'tmp_tag_condition' => 16,
			'tag_list' => 6,
			'tag_if' => 17,
			'tag_dump' => 18,
			'content' => 362,
			'tag_macro' => 11,
			'tag_open_start' => 20,
			'tag_macro_call' => 12,
			'tag' => 13,
			'tag_comment' => 14
		}
	},
	{#State 356
		ACTIONS => {
			"macro" => 364
		},
		GOTOS => {
			'directive_macro_end' => 363
		}
	},
	{#State 357
		ACTIONS => {
			")" => 365
		}
	},
	{#State 358
		ACTIONS => {
			")" => 366
		}
	},
	{#State 359
		ACTIONS => {
			")" => 367
		}
	},
	{#State 360
		DEFAULT => -134
	},
	{#State 361
		DEFAULT => -108
	},
	{#State 362
		ACTIONS => {
			"</#" => 335
		},
		GOTOS => {
			'tag_close_start' => 368
		}
	},
	{#State 363
		ACTIONS => {
			">" => 283
		},
		GOTOS => {
			'tag_close_end' => 369
		}
	},
	{#State 364
		DEFAULT => -115
	},
	{#State 365
		DEFAULT => -188
	},
	{#State 366
		DEFAULT => -186
	},
	{#State 367
		DEFAULT => -190
	},
	{#State 368
		ACTIONS => {
			"list" => 370
		}
	},
	{#State 369
		DEFAULT => -113
	},
	{#State 370
		ACTIONS => {
			">" => 283
		},
		GOTOS => {
			'tag_close_end' => 371
		}
	},
	{#State 371
		DEFAULT => -131
	}
],
                                  yyrules  =>
[
	[#Rule 0
		 '$start', 2, undef
	],
	[#Rule 1
		 'content', 1, undef
	],
	[#Rule 2
		 'content', 2,
sub
#line 45 "FreeMarkerGrammar.yp"
{
								$_[1] = '' if !defined $_[1];
								$_[2] = '' if !defined $_[2];
								return "$_[1]$_[2]";
							}
	],
	[#Rule 3
		 'content', 0, undef
	],
	[#Rule 4
		 'content_item', 1, undef
	],
	[#Rule 5
		 'content_item', 1, undef
	],
	[#Rule 6
		 'content_item', 1, undef
	],
	[#Rule 7
		 'content_item', 1, undef
	],
	[#Rule 8
		 'tag', 1,
sub
#line 64 "FreeMarkerGrammar.yp"
{ '' }
	],
	[#Rule 9
		 'tag', 1,
sub
#line 67 "FreeMarkerGrammar.yp"
{ '' }
	],
	[#Rule 10
		 'tag', 1, undef
	],
	[#Rule 11
		 'tag', 1, undef
	],
	[#Rule 12
		 'tag', 1, undef
	],
	[#Rule 13
		 'tag', 1, undef
	],
	[#Rule 14
		 'tag', 1, undef
	],
	[#Rule 15
		 'tag', 1, undef
	],
	[#Rule 16
		 'tag', 1, undef
	],
	[#Rule 17
		 'tag', 1, undef
	],
	[#Rule 18
		 'whitespace', 1, undef
	],
	[#Rule 19
		 'whitespace', 0, undef
	],
	[#Rule 20
		 'value', 1,
sub
#line 92 "FreeMarkerGrammar.yp"
{ $_[1] }
	],
	[#Rule 21
		 'value', 1, undef
	],
	[#Rule 22
		 'value', 1,
sub
#line 97 "FreeMarkerGrammar.yp"
{ $_[1] }
	],
	[#Rule 23
		 'exp', 1, undef
	],
	[#Rule 24
		 'exp', 1,
sub
#line 103 "FreeMarkerGrammar.yp"
{ $_[0]->data( $_[1] ) }
	],
	[#Rule 25
		 'exp', 3,
sub
#line 106 "FreeMarkerGrammar.yp"
{
								$_[0]->_storeData( $_[1], $_[3] );
							}
	],
	[#Rule 26
		 'exp', 1,
sub
#line 111 "FreeMarkerGrammar.yp"
{ 1 }
	],
	[#Rule 27
		 'exp', 1,
sub
#line 114 "FreeMarkerGrammar.yp"
{ 0 }
	],
	[#Rule 28
		 'exp', 3,
sub
#line 116 "FreeMarkerGrammar.yp"
{ $_[1] + $_[3] }
	],
	[#Rule 29
		 'exp', 3,
sub
#line 118 "FreeMarkerGrammar.yp"
{ $_[1] - $_[3] }
	],
	[#Rule 30
		 'exp', 3,
sub
#line 120 "FreeMarkerGrammar.yp"
{ $_[1] * $_[3] }
	],
	[#Rule 31
		 'exp', 3,
sub
#line 122 "FreeMarkerGrammar.yp"
{ $_[1] / $_[3] }
	],
	[#Rule 32
		 'exp', 2,
sub
#line 124 "FreeMarkerGrammar.yp"
{ -$_[2] }
	],
	[#Rule 33
		 'exp', 2,
sub
#line 126 "FreeMarkerGrammar.yp"
{ $_[2] }
	],
	[#Rule 34
		 'exp', 3,
sub
#line 128 "FreeMarkerGrammar.yp"
{ $_[1] ** $_[3] }
	],
	[#Rule 35
		 'exp', 3,
sub
#line 132 "FreeMarkerGrammar.yp"
{ $_[1] % $_[3] }
	],
	[#Rule 36
		 'exp_logic', 1, undef
	],
	[#Rule 37
		 'exp_logic', 3,
sub
#line 138 "FreeMarkerGrammar.yp"
{ $_[1] && $_[3] }
	],
	[#Rule 38
		 'exp_logic', 3,
sub
#line 141 "FreeMarkerGrammar.yp"
{ $_[1] || $_[3] }
	],
	[#Rule 39
		 'exp_logic', 3,
sub
#line 144 "FreeMarkerGrammar.yp"
{ $_[1] && !$_[3] }
	],
	[#Rule 40
		 'exp_logic', 2,
sub
#line 147 "FreeMarkerGrammar.yp"
{ !$_[2] }
	],
	[#Rule 41
		 'exp_logic', 3,
sub
#line 150 "FreeMarkerGrammar.yp"
{ $_[2] }
	],
	[#Rule 42
		 'exp_logic_unexpanded', 1, undef
	],
	[#Rule 43
		 'exp_logic_unexpanded', 3,
sub
#line 156 "FreeMarkerGrammar.yp"
{ "$_[1] && $_[3]" }
	],
	[#Rule 44
		 'exp_logic_unexpanded', 3,
sub
#line 159 "FreeMarkerGrammar.yp"
{ "$_[1] || $_[3]" }
	],
	[#Rule 45
		 'exp_logic_unexpanded', 2,
sub
#line 162 "FreeMarkerGrammar.yp"
{ "!$_[2]" }
	],
	[#Rule 46
		 'exp_logic_unexpanded', 3,
sub
#line 165 "FreeMarkerGrammar.yp"
{ "$_[1] && !$_[3]" }
	],
	[#Rule 47
		 'exp_logic_unexpanded', 3,
sub
#line 168 "FreeMarkerGrammar.yp"
{ "($_[2])" }
	],
	[#Rule 48
		 'exp_condition_unexpanded', 1, undef
	],
	[#Rule 49
		 'exp_condition_unexpanded', 3,
sub
#line 174 "FreeMarkerGrammar.yp"
{ "$_[1] == $_[3]" }
	],
	[#Rule 50
		 'exp_condition_unexpanded', 3,
sub
#line 177 "FreeMarkerGrammar.yp"
{ "$_[1] == $_[3]" }
	],
	[#Rule 51
		 'exp_condition_unexpanded', 3,
sub
#line 180 "FreeMarkerGrammar.yp"
{ "$_[1] = $_[3]" }
	],
	[#Rule 52
		 'exp_condition_unexpanded', 3,
sub
#line 183 "FreeMarkerGrammar.yp"
{ "$_[1] == $_[3]" }
	],
	[#Rule 53
		 'exp_condition_unexpanded', 3,
sub
#line 186 "FreeMarkerGrammar.yp"
{ "$_[1] gte $_[3]" }
	],
	[#Rule 54
		 'exp_condition_unexpanded', 3,
sub
#line 189 "FreeMarkerGrammar.yp"
{ "$_[1] lte $_[3]" }
	],
	[#Rule 55
		 'exp_condition_unexpanded', 3,
sub
#line 192 "FreeMarkerGrammar.yp"
{ "$_[1] gt $_[3]" }
	],
	[#Rule 56
		 'exp_condition_unexpanded', 3,
sub
#line 195 "FreeMarkerGrammar.yp"
{ "$_[1] lt $_[3]" }
	],
	[#Rule 57
		 'exp_condition_unexpanded', 3,
sub
#line 198 "FreeMarkerGrammar.yp"
{ "$_[1] != $_[3]" }
	],
	[#Rule 58
		 'exp_condition_unexpanded', 3,
sub
#line 201 "FreeMarkerGrammar.yp"
{ "$_[1] != $_[3]" }
	],
	[#Rule 59
		 'exp_condition_unexpanded', 2,
sub
#line 204 "FreeMarkerGrammar.yp"
{ "$_[1]??" }
	],
	[#Rule 60
		 'exp_condition_var_unexpanded', 1,
sub
#line 208 "FreeMarkerGrammar.yp"
{ "$_[1]" }
	],
	[#Rule 61
		 'exp_condition_var_unexpanded', 3,
sub
#line 211 "FreeMarkerGrammar.yp"
{ "$_[1]?$_[3]" }
	],
	[#Rule 62
		 'exp_condition_var_unexpanded', 1, undef
	],
	[#Rule 63
		 'op', 1, undef
	],
	[#Rule 64
		 'op', 1, undef
	],
	[#Rule 65
		 'op', 1, undef
	],
	[#Rule 66
		 'op', 1, undef
	],
	[#Rule 67
		 'op', 1, undef
	],
	[#Rule 68
		 'op', 1, undef
	],
	[#Rule 69
		 'op', 1, undef
	],
	[#Rule 70
		 'op', 1, undef
	],
	[#Rule 71
		 'op', 1, undef
	],
	[#Rule 72
		 'op', 1, undef
	],
	[#Rule 73
		 'op', 1, undef
	],
	[#Rule 74
		 'op', 1, undef
	],
	[#Rule 75
		 'op', 1, undef
	],
	[#Rule 76
		 'op', 1, undef
	],
	[#Rule 77
		 'op', 1, undef
	],
	[#Rule 78
		 'op', 1, undef
	],
	[#Rule 79
		 'op', 1, undef
	],
	[#Rule 80
		 'op', 1, undef
	],
	[#Rule 81
		 'op', 1, undef
	],
	[#Rule 82
		 'op', 1, undef
	],
	[#Rule 83
		 'op', 1, undef
	],
	[#Rule 84
		 'op', 1, undef
	],
	[#Rule 85
		 'sequence_item', 1, undef
	],
	[#Rule 86
		 'sequence_item', 1, undef
	],
	[#Rule 87
		 'sequence_item', 1, undef
	],
	[#Rule 88
		 'sequence', 1, undef
	],
	[#Rule 89
		 'sequence', 3,
sub
#line 233 "FreeMarkerGrammar.yp"
{
								my $seq = '';
								$seq .= $_[1] if defined $_[1];
								$seq .= ', ' if defined $_[1] && defined $_[3];
								$seq .= $_[3] if defined $_[3];
								return $seq;
							}
	],
	[#Rule 90
		 'array_str', 2,
sub
#line 242 "FreeMarkerGrammar.yp"
{ '' }
	],
	[#Rule 91
		 'array_str', 3,
sub
#line 245 "FreeMarkerGrammar.yp"
{ "[$_[2]]" }
	],
	[#Rule 92
		 'array_str', 5,
sub
#line 248 "FreeMarkerGrammar.yp"
{
								(my $items = $_[5]) =~ s/^\[(.*)\]$/$1/;
								return "[$_[2], $items]";
							}
	],
	[#Rule 93
		 'expr_assignments', 1, undef
	],
	[#Rule 94
		 'expr_assignments', 2, undef
	],
	[#Rule 95
		 'expr_assignment', 3,
sub
#line 260 "FreeMarkerGrammar.yp"
{
								$_[0]->_storeData( $_[1], $_[3] );
							}
	],
	[#Rule 96
		 'tag_open_start', 1,
sub
#line 267 "FreeMarkerGrammar.yp"
{ $_[0]->_pushContext('tagParams') }
	],
	[#Rule 97
		 'tag_macro_open_start', 1,
sub
#line 271 "FreeMarkerGrammar.yp"
{ $_[0]->_pushContext('tagParams') }
	],
	[#Rule 98
		 '@1-1', 0,
sub
#line 276 "FreeMarkerGrammar.yp"
{ $_[0]->_popContext('tagParams') }
	],
	[#Rule 99
		 '@2-2', 0,
sub
#line 277 "FreeMarkerGrammar.yp"
{ $_[0]->_pushContext('whitespace') }
	],
	[#Rule 100
		 'tag_open_end', 4,
sub
#line 279 "FreeMarkerGrammar.yp"
{ $_[0]->_popContext('whitespace') }
	],
	[#Rule 101
		 'tag_close_start', 1, undef
	],
	[#Rule 102
		 '@3-1', 0,
sub
#line 287 "FreeMarkerGrammar.yp"
{ $_[0]->_pushContext('whitespace') }
	],
	[#Rule 103
		 'tag_close_end', 3,
sub
#line 289 "FreeMarkerGrammar.yp"
{ $_[0]->_popContext('whitespace') }
	],
	[#Rule 104
		 '@4-3', 0,
sub
#line 297 "FreeMarkerGrammar.yp"
{ $_[0]->_popContext('assignment') }
	],
	[#Rule 105
		 'tag_assign', 5, undef
	],
	[#Rule 106
		 '@5-3', 0,
sub
#line 303 "FreeMarkerGrammar.yp"
{ $_[0]->_popContext('assignment') }
	],
	[#Rule 107
		 '@6-5', 0,
sub
#line 305 "FreeMarkerGrammar.yp"
{ $_[0]->_pushContext( 'assign' ); }
	],
	[#Rule 108
		 'tag_assign', 10,
sub
#line 310 "FreeMarkerGrammar.yp"
{
								$_[0]->_storeData( _unquote($_[3]), $_[7] );
								$_[0]->_popContext( 'assign' );
							}
	],
	[#Rule 109
		 'directive_assign', 1,
sub
#line 316 "FreeMarkerGrammar.yp"
{ $_[0]->_pushContext('assignment') }
	],
	[#Rule 110
		 'directive_assign_end', 1, undef
	],
	[#Rule 111
		 '@7-4', 0,
sub
#line 324 "FreeMarkerGrammar.yp"
{ $_[0]->_popContext('assignment') }
	],
	[#Rule 112
		 '@8-6', 0,
sub
#line 326 "FreeMarkerGrammar.yp"
{ $_[0]->_pushContext( 'macrocontents' ); }
	],
	[#Rule 113
		 'tag_macro', 11,
sub
#line 331 "FreeMarkerGrammar.yp"
{
								my $content = $_[8] || '';
								$_[0]->{_data}->{_fmMacros}->{$_[3]}->{contents} = $content;
								
								my @params;
								@params = split(/ /, $_[4]) if $_[4];
								my %paramsHash = map { $_ => 1 } @params;
								$_[0]->{_data}->{_fmMacros}->{$_[3]}->{params} = \%paramsHash;
																
								$_[0]->_popContext( 'macrocontents' );
								return '';
							}
	],
	[#Rule 114
		 'directive_macro', 1,
sub
#line 346 "FreeMarkerGrammar.yp"
{ $_[0]->_pushContext('assignment') }
	],
	[#Rule 115
		 'directive_macro_end', 1, undef
	],
	[#Rule 116
		 'macroparams', 1, undef
	],
	[#Rule 117
		 'macroparams', 2,
sub
#line 353 "FreeMarkerGrammar.yp"
{
								$_[1] = '' if !defined $_[1];
								$_[2] = '' if !defined $_[2];
								return "$_[1] $_[2]";
							}
	],
	[#Rule 118
		 'macroparam', 1, undef
	],
	[#Rule 119
		 'macroparam', 0, undef
	],
	[#Rule 120
		 'macro_assignments', 1, undef
	],
	[#Rule 121
		 'macro_assignments', 2, undef
	],
	[#Rule 122
		 'macro_assignment', 3,
sub
#line 369 "FreeMarkerGrammar.yp"
{
								print "Invalid macro parameter:$_[1]\n" if (!$_[0]->{_workingData}->{validMacroParams}->{$_[1]});
								if (_isString($_[3])) {
									$_[0]->_storeData( $_[1], $_[0]->_parse($_[3]) );
								} else {
									$_[0]->_storeData( $_[1], $_[3] );
								}
							}
	],
	[#Rule 123
		 'macro_assignment', 0, undef
	],
	[#Rule 124
		 '@9-2', 0,
sub
#line 382 "FreeMarkerGrammar.yp"
{ $_[0]->_pushContext('assignment') }
	],
	[#Rule 125
		 '@10-4', 0,
sub
#line 384 "FreeMarkerGrammar.yp"
{
								$_[0]->{_workingData}->{validMacroParams} = $_[0]->{_data}->{_fmMacros}->{$_[4]}->{params};
							}
	],
	[#Rule 126
		 '@11-6', 0,
sub
#line 388 "FreeMarkerGrammar.yp"
{ $_[0]->_popContext('assignment') }
	],
	[#Rule 127
		 'tag_macro_call', 9,
sub
#line 391 "FreeMarkerGrammar.yp"
{
								my $parsed = $_[0]->_parse( $_[0]->{_data}->{_fmMacros}->{$_[4]}->{contents} );
								undef $_[0]->{_workingData}->{validMacroParams};
								return $parsed;
							}
	],
	[#Rule 128
		 '@12-2', 0,
sub
#line 400 "FreeMarkerGrammar.yp"
{
								$_[0]->{_workingData}->{nestedLevel}++;
								$_[0]->_pushContext('listParams');
							}
	],
	[#Rule 129
		 '@13-5', 0,
sub
#line 406 "FreeMarkerGrammar.yp"
{ $_[0]->_popContext('listParams') }
	],
	[#Rule 130
		 '@14-8', 0,
sub
#line 409 "FreeMarkerGrammar.yp"
{ $_[0]->_pushContext( 'list' ) }
	],
	[#Rule 131
		 'tag_list', 13,
sub
#line 414 "FreeMarkerGrammar.yp"
{
								$_[0]->_popContext( 'list' );
								$_[0]->{_workingData}->{nestedLevel}--;
								my $key = $_[7];
								my $format = $_[10];
								my $listData = $_[4];

								my $result = '';
#FIXME: this seems to get called with empty format

								if ($format) {
									$result = $_[0]->_renderList( $key, $listData, $format ) if $listData;
								}
								return $result;
							}
	],
	[#Rule 132
		 '@15-2', 0,
sub
#line 433 "FreeMarkerGrammar.yp"
{
								$_[0]->{_workingData}->{ifLevel}++;
								$_[0]->_pushContext('condition');
							}
	],
	[#Rule 133
		 '@16-4', 0,
sub
#line 438 "FreeMarkerGrammar.yp"
{
								$_[0]->_popContext('condition');
							}
	],
	[#Rule 134
		 'tag_if', 10,
sub
#line 446 "FreeMarkerGrammar.yp"
{
								$_[0]->{_workingData}->{ifLevel}--;
								my $content = $_[7] || '';
								$content =~ s/[[:space:]]+$//s;
								my $block = "<#_if_ $_[4]>$content";
								if ( $_[0]->{_workingData}->{ifLevel} == 0 ) {
									# to prevent parsing of nested if blocks first, first parse level 0, and after that nested if blocks
									return $_[0]->_parseIfBlock( $block );
								} else {
									my $ifBlock = '<#if ' . $_[4] . '>' . $content . '</#if>';
									
									push (@{$_[0]->{_workingData}->{ifBlocks}}, $ifBlock); 
									my $ifBlockId = scalar @{$_[0]->{_workingData}->{ifBlocks}} - 1;
									return '___ifblock' . $ifBlockId . '___';
								}
								$_[0]->{_workingData}->{ifBlocks} = () if $_[0]->{_workingData}->{ifLevel} == 0;
							}
	],
	[#Rule 135
		 '@17-2', 0,
sub
#line 467 "FreeMarkerGrammar.yp"
{ $_[0]->_pushContext('evalcondition') }
	],
	[#Rule 136
		 '@18-4', 0,
sub
#line 469 "FreeMarkerGrammar.yp"
{ $_[0]->_popContext('evalcondition') }
	],
	[#Rule 137
		 'tmp_tag_condition', 6,
sub
#line 471 "FreeMarkerGrammar.yp"
{
								return $_[4] == 1 ? 1 : 0;
							}
	],
	[#Rule 138
		 '@19-2', 0,
sub
#line 478 "FreeMarkerGrammar.yp"
{ $_[0]->_pushContext('assignment') }
	],
	[#Rule 139
		 '@20-4', 0,
sub
#line 480 "FreeMarkerGrammar.yp"
{ $_[0]->_popContext('assignment') }
	],
	[#Rule 140
		 'tag_ftl', 6,
sub
#line 482 "FreeMarkerGrammar.yp"
{ '' }
	],
	[#Rule 141
		 'expr_ftl_assignments', 1, undef
	],
	[#Rule 142
		 'expr_ftl_assignments', 2, undef
	],
	[#Rule 143
		 'expr_ftl_assignment', 3,
sub
#line 489 "FreeMarkerGrammar.yp"
{ $_[0]->{_data}->{_ftlData}->{$_[1]} = $_[3] }
	],
	[#Rule 144
		 '@21-2', 0,
sub
#line 494 "FreeMarkerGrammar.yp"
{ $_[0]->_pushContext( 'comment' ) }
	],
	[#Rule 145
		 'tag_comment', 6,
sub
#line 498 "FreeMarkerGrammar.yp"
{
								$_[0]->_popContext( 'comment' );
								$_[0]->_popContext('tagParams');
								return '';
							}
	],
	[#Rule 146
		 '@22-2', 0,
sub
#line 507 "FreeMarkerGrammar.yp"
{ $_[0]->_pushContext('assignment') }
	],
	[#Rule 147
		 '@23-4', 0,
sub
#line 509 "FreeMarkerGrammar.yp"
{ $_[0]->_popContext('assignment') }
	],
	[#Rule 148
		 'tag_dump', 8,
sub
#line 513 "FreeMarkerGrammar.yp"
{
								use Data::Dumper;
								return Dumper($_[4]);
							}
	],
	[#Rule 149
		 '@24-1', 0,
sub
#line 520 "FreeMarkerGrammar.yp"
{ $_[0]->_pushContext('variableParams') }
	],
	[#Rule 150
		 'variable', 4,
sub
#line 523 "FreeMarkerGrammar.yp"
{
								$_[0]->_popContext('variableParams');
								undef $_[0]->{_workingData}->{tmpData};
								return $_[0]->_parse( $_[3] );
							}
	],
	[#Rule 151
		 'data', 1,
sub
#line 531 "FreeMarkerGrammar.yp"
{
								$_[0]->_value($_[1])
							}
	],
	[#Rule 152
		 'data', 1,
sub
#line 536 "FreeMarkerGrammar.yp"
{ $_[0]->data() }
	],
	[#Rule 153
		 'data', 1, undef
	],
	[#Rule 154
		 'data', 1, undef
	],
	[#Rule 155
		 'data', 1, undef
	],
	[#Rule 156
		 'data', 1, undef
	],
	[#Rule 157
		 'data', 1, undef
	],
	[#Rule 158
		 'data', 1, undef
	],
	[#Rule 159
		 'type_op', 3,
sub
#line 553 "FreeMarkerGrammar.yp"
{
								my $d = $_[0]->{_workingData}->{tmpData};
								$d = $_[0]->data() if !defined $d;
								my $value;
								if ( UNIVERSAL::isa( $d, "HASH" ) ) {
									$value = $d->{ _unquote( $_[3] ) };
									$_[0]->{_workingData}->{tmpData} = $value;
								}
								return $value;
							}
	],
	[#Rule 160
		 'type_op', 3,
sub
#line 565 "FreeMarkerGrammar.yp"
{ $_[2] }
	],
	[#Rule 161
		 'type_op', 3,
sub
#line 568 "FreeMarkerGrammar.yp"
{ $_[1] * $_[3] }
	],
	[#Rule 162
		 'type_op', 3,
sub
#line 572 "FreeMarkerGrammar.yp"
{
								if ( UNIVERSAL::isa( $_[1], "ARRAY" ) && UNIVERSAL::isa( $_[3], "ARRAY" ) ) {
									my @list = ( @{$_[1]}, @{$_[3]} );
									return \@list;
								} else {
								    # not an array
									return $_[1] + $_[3];
								}
							}
	],
	[#Rule 163
		 'type_op', 3,
sub
#line 583 "FreeMarkerGrammar.yp"
{ undef }
	],
	[#Rule 164
		 'type_op', 4,
sub
#line 586 "FreeMarkerGrammar.yp"
{
								if ( $_[0]->_context() eq 'listParams' ) {
									my $value = $_[1]->[$_[3]];
									my @list = ($value);
									return \@list;
								} else {
									my $value = $_[1][$_[3]];
									$_[0]->{_workingData}->{tmpData} = $value;
									return $value;
								}
							}
	],
	[#Rule 165
		 'type_op', 6,
sub
#line 599 "FreeMarkerGrammar.yp"
{
								my @list;
								if ( $_[3] > $_[5] ) {
									@list = @{$_[1]}[$_[5]..$_[3]];
									@list = reverse(@list);
								} else {
									@list = @{$_[1]}[$_[3]..$_[5]];
								}
								return \@list;
							}
	],
	[#Rule 166
		 'type_op', 5,
sub
#line 611 "FreeMarkerGrammar.yp"
{
								my $maxlength = scalar @{$_[1]} - 1;
								my @list = @{$_[1]}[$_[3]..$maxlength];
								return \@list;
							}
	],
	[#Rule 167
		 'type_op', 5,
sub
#line 618 "FreeMarkerGrammar.yp"
{
								my @list = @{$_[1]}[0..$_[4]];
								return \@list;
							}
	],
	[#Rule 168
		 'type_op', 4,
sub
#line 624 "FreeMarkerGrammar.yp"
{
								my $d = $_[0]->{_workingData}->{tmpData};
								$d = $_[0]->data() if !defined $d;
								my $value = $d->{ _unquote( $_[3] ) };
								$_[0]->{_workingData}->{tmpData} = $value;
								my @list = ($value);
								return \@list;
							}
	],
	[#Rule 169
		 'type_op', 4,
sub
#line 634 "FreeMarkerGrammar.yp"
{
								my $d = $_[0]->{_workingData}->{tmpData};
								$d = $_[0]->data() if !defined $d;
								my $value = $d->{ _unquote( $_[3] ) };
								$_[0]->{_workingData}->{tmpData} = $value;
								return $value;
							}
	],
	[#Rule 170
		 'type_op', 6,
sub
#line 643 "FreeMarkerGrammar.yp"
{ join ( _unquote($_[5]), @{$_[1]} ) }
	],
	[#Rule 171
		 'type_op', 3,
sub
#line 646 "FreeMarkerGrammar.yp"
{
								my $sorted = _sort( $_[1] );
								return $sorted;
							}
	],
	[#Rule 172
		 'type_op', 3,
sub
#line 652 "FreeMarkerGrammar.yp"
{ scalar @{$_[1]} }
	],
	[#Rule 173
		 'type_op', 6,
sub
#line 655 "FreeMarkerGrammar.yp"
{
								my $key = _unquote($_[5]);								
								my $isStringSort = 1;
								for (@{$_[1]}) {
									if ( _isNumber($_->{$key}) ) {
										$isStringSort = 0;
										last;
									}
								}
								my @sorted;
								if ($isStringSort) {
									@sorted = sort { lc $$a{$key} cmp lc $$b{$key} } @{$_[1]};
								} else {
									@sorted = sort { $$a{$key} <=> $$b{$key} } @{$_[1]};
								}
								return \@sorted;
							}
	],
	[#Rule 174
		 'type_op', 6,
sub
#line 674 "FreeMarkerGrammar.yp"
{
								# differentiate between numbers and strings
								# this is not fast
								$_[0]->{_workingData}->{$_[1]}->{'seqData'} ||=
								_arrayAsHash($_[1], 1);
    							my $index =  $_[0]->{_workingData}->{$_[1]}->{'seqData'}->{ $_[5] };
    							return -1 if !defined $index;
    							return $index;
							}
	],
	[#Rule 175
		 'type_op', 6,
sub
#line 685 "FreeMarkerGrammar.yp"
{
								# differentiate between numbers and strings
								# this is not fast
								$_[0]->{_workingData}->{$_[1]}->{'seqData'} ||=
								_arrayAsHash($_[1], 1);
    							return 1 if defined $_[0]->{_workingData}->{$_[1]}->{'seqData'}->{ $_[5] };
    							return 0;
							}
	],
	[#Rule 176
		 'type_op', 3,
sub
#line 695 "FreeMarkerGrammar.yp"
{
								my @reversed = reverse @{$_[1]};
								return \@reversed;
							}
	],
	[#Rule 177
		 'type_op', 3,
sub
#line 701 "FreeMarkerGrammar.yp"
{ @{$_[1]}[-1] }
	],
	[#Rule 178
		 'type_op', 3,
sub
#line 704 "FreeMarkerGrammar.yp"
{ @{$_[1]}[0] }
	],
	[#Rule 179
		 'type_op', 3,
sub
#line 708 "FreeMarkerGrammar.yp"
{ _capfirst( $_[1] ) }
	],
	[#Rule 180
		 'type_op', 3,
sub
#line 711 "FreeMarkerGrammar.yp"
{ _capitalize( $_[1] ) }
	],
	[#Rule 181
		 'type_op', 3,
sub
#line 714 "FreeMarkerGrammar.yp"
{ $_[0]->_parse('${' . $_[1] . '}') }
	],
	[#Rule 182
		 'type_op', 3,
sub
#line 717 "FreeMarkerGrammar.yp"
{ _html($_[1]) }
	],
	[#Rule 183
		 'type_op', 3,
sub
#line 720 "FreeMarkerGrammar.yp"
{ _xhtml($_[1]) }
	],
	[#Rule 184
		 'type_op', 3,
sub
#line 723 "FreeMarkerGrammar.yp"
{ return defined $_[1] ? length( $_[1] ) : 0 }
	],
	[#Rule 185
		 'type_op', 3,
sub
#line 726 "FreeMarkerGrammar.yp"
{ lc $_[1] }
	],
	[#Rule 186
		 'type_op', 8,
sub
#line 729 "FreeMarkerGrammar.yp"
{ _replace( $_[1], _unquote($_[5]), _unquote($_[7]) ) }
	],
	[#Rule 187
		 'type_op', 3,
sub
#line 732 "FreeMarkerGrammar.yp"
{ $_[1] }
	],
	[#Rule 188
		 'type_op', 8,
sub
#line 735 "FreeMarkerGrammar.yp"
{ $_[1] ? _unquote($_[5]) : _unquote($_[7]) }
	],
	[#Rule 189
		 'type_op', 6,
sub
#line 738 "FreeMarkerGrammar.yp"
{ _substring( $_[1], $_[5] ) }
	],
	[#Rule 190
		 'type_op', 8,
sub
#line 741 "FreeMarkerGrammar.yp"
{ _substring( $_[1], $_[5], $_[7] ) }
	],
	[#Rule 191
		 'type_op', 3,
sub
#line 744 "FreeMarkerGrammar.yp"
{ _uncapfirst( $_[1] ) }
	],
	[#Rule 192
		 'type_op', 3,
sub
#line 747 "FreeMarkerGrammar.yp"
{ uc $_[1] }
	],
	[#Rule 193
		 'type_op', 3,
sub
#line 750 "FreeMarkerGrammar.yp"
{
								my @list = _wordlist( $_[1] );
								return \@list;
							}
	],
	[#Rule 194
		 'type_op', 3,
sub
#line 756 "FreeMarkerGrammar.yp"
{ _unquote($_[3]) }
	],
	[#Rule 195
		 'type_op', 3,
sub
#line 759 "FreeMarkerGrammar.yp"
{ 
								return 0 if !defined $_[1];
								if ($_[1] && _isString($_[3])) {
									return $_[1] eq $_[3];
								} else {
									return $_[1] == $_[3];
								}
							}
	],
	[#Rule 196
		 'type_op', 3,
sub
#line 769 "FreeMarkerGrammar.yp"
{ 
								if (_isString($_[3])) {
									return $_[1] ne $_[3];
								} else {
									return $_[1] != $_[3];
								}
							}
	],
	[#Rule 197
		 'type_op', 2,
sub
#line 778 "FreeMarkerGrammar.yp"
{ 
								return defined $_[1];
							}
	],
	[#Rule 198
		 'type_op', 3,
sub
#line 783 "FreeMarkerGrammar.yp"
{ return 0 if !defined $_[1]; $_[1] > $_[3] }
	],
	[#Rule 199
		 'type_op', 3,
sub
#line 786 "FreeMarkerGrammar.yp"
{ return 0 if !defined $_[1]; $_[1] >= $_[3] }
	],
	[#Rule 200
		 'type_op', 3,
sub
#line 789 "FreeMarkerGrammar.yp"
{ return 0 if !defined $_[1]; $_[1] < $_[3] }
	],
	[#Rule 201
		 'type_op', 3,
sub
#line 792 "FreeMarkerGrammar.yp"
{ return 0 if !defined $_[1]; $_[1] <= $_[3] }
	],
	[#Rule 202
		 'string_op', 1,
sub
#line 796 "FreeMarkerGrammar.yp"
{ _unquote( $_[1] ) }
	],
	[#Rule 203
		 'string_op', 3,
sub
#line 799 "FreeMarkerGrammar.yp"
{
								if (defined $_[3]) {
									return $_[1] . $_[3];
								} else {
									return $_[1];
								}
							}
	],
	[#Rule 204
		 'string_op', 2,
sub
#line 808 "FreeMarkerGrammar.yp"
{ _protect(_unquote( $_[2] )) }
	],
	[#Rule 205
		 'hash', 3,
sub
#line 812 "FreeMarkerGrammar.yp"
{ $_[2] }
	],
	[#Rule 206
		 'hashes', 1,
sub
#line 815 "FreeMarkerGrammar.yp"
{
								$_[0]->{_workingData}->{'hashes'} ||= ();
								push @{$_[0]->{_workingData}->{'hashes'}}, $_[1];
							}
	],
	[#Rule 207
		 'hashes', 3,
sub
#line 821 "FreeMarkerGrammar.yp"
{	
								$_[0]->{_workingData}->{'hashes'} ||= ();
								push @{$_[0]->{_workingData}->{'hashes'}}, $_[3];
							}
	],
	[#Rule 208
		 'hash_op', 1, undef
	],
	[#Rule 209
		 'hash_op', 3,
sub
#line 829 "FreeMarkerGrammar.yp"
{
								my %merged = (%{$_[1]}, %{$_[3]});
								return \%merged;
							}
	],
	[#Rule 210
		 'hashvalue', 3,
sub
#line 835 "FreeMarkerGrammar.yp"
{
								my $local = {
									_unquote($_[1]) => _unquote($_[3])
								};
								return $local;
							}
	],
	[#Rule 211
		 'hashvalues', 1, undef
	],
	[#Rule 212
		 'hashvalues', 3,
sub
#line 845 "FreeMarkerGrammar.yp"
{
								my %merged = (%{$_[1]}, %{$_[3]});
								return \%merged;
							}
	],
	[#Rule 213
		 'array_op', 3,
sub
#line 852 "FreeMarkerGrammar.yp"
{
								my @list = @{$_[0]->{_workingData}->{'hashes'}};
								undef $_[0]->{_workingData}->{'hashes'};
								return \@list;
							}
	],
	[#Rule 214
		 'array_op', 1,
sub
#line 859 "FreeMarkerGrammar.yp"
{ _toList($_[1]) }
	],
	[#Rule 215
		 'array_op', 3,
sub
#line 862 "FreeMarkerGrammar.yp"
{
								my @list;
								if ( $_[1] > $_[3] ) {
									@list = ($_[3]..$_[1]);
									@list = reverse(@list);
								} else {
									@list = ($_[1]..$_[3]);
								}
								return \@list;
							}
	],
	[#Rule 216
		 'array_op', 2,
sub
#line 874 "FreeMarkerGrammar.yp"
{
								my @list = (0..$_[2]);
								return \@list;
							}
	],
	[#Rule 217
		 'array_pos', 1, undef
	],
	[#Rule 218
		 'array_pos', 1,
sub
#line 883 "FreeMarkerGrammar.yp"
{ $_[0]->_value($_[1]) }
	],
	[#Rule 219
		 'func_op', 4,
sub
#line 887 "FreeMarkerGrammar.yp"
{
								my $function = $_[0]->_value($_[1]);
								return undef if !$function;
								my $parameters = $_[0]->_parse( $_[3] );
								
								my @params = ();
								while ($parameters =~ s/(([']+)([^']*)([']+))|((["]+)([^"]*)(["]+))/push @params,_unquote($3||$5)/ge) {}
								
								return &$function(@params);
							}
	]
],
                                  @_);
    bless($self,$class);
}

#line 898 "FreeMarkerGrammar.yp"




use strict;
use warnings;

use Text::Balanced qw (
  gen_delimited_pat
);
my $p_quotes                = gen_delimited_pat(q{'"});    # generates regex
my $PATTERN_PRESERVE_QUOTES = qr/($p_quotes)/;
my $p_number =
'(?:(?i)(?:[+-]?)(?:(?=[0123456789]|[.])(?:[0123456789]*)(?:(?:[.])(?:[0123456789]{0,}))?)(?:(?:[E])(?:(?:[+-]?)(?:[0123456789]+))|))'
  ; #created with: use Regexp::Common 'RE_ALL'; $PATTERN_NUMBER = $RE{num}{real};
my $PATTERN_NUMBER = qr/($p_number)/;

my $PATTERN_STRING_OP =
qr/\b(word_list|upper_case|uncap_first|substring|string|replace|lower_case|length|xhtml|html|eval|capitalize|cap_first)\b/;
my $PATTERN_SEQUENCE_OP =
  qr/\b(sort_by|sort|size|seq_index_of|seq_contains|reverse|last|join|first)\b/;

my $recursiveLevel      = 0;
my $MAX_RECURSIVE_LEVEL = 100;
my $dataKeyId           = 0;

=pod

Initialization of instance variables - not in sub 'new' as this is defined by the parser compiler.

=cut

sub _init {
    my ( $this, $dataRef ) = @_;

    $this->{_context} ||= undef;
    @{ $this->{_context} } = () if !defined $this->{_context};
    $this->{_data} ||= $dataRef;
    $this->{_data}->{_fmKeys} ||= [];

    # values set in template directive 'ftl'
    $this->{_data}->{_ftlData}                     ||= {};
    $this->{_data}->{_ftlData}->{encoding}         ||= undef;
    $this->{_data}->{_ftlData}->{strip_whitespace} ||= 1;
    $this->{_data}->{_ftlData}->{attributes}       ||= {};

    $this->{_workingData}                  ||= {};
    $this->{_workingData}->{tmpData}       ||= undef;
    $this->{_workingData}->{ifBlocks}      ||= ();   # array with block contents
    $this->{_workingData}->{ifLevel}       ||= 0;
    $this->{_workingData}->{nestedLevel}   ||= 0;
    $this->{_workingData}->{inTagBrackets} ||= 0;
}

sub _increaseDataScope {
    my ($this) = @_;

    push( @{ $this->{_data}->{_fmKeys} }, $dataKeyId++ );
}

sub _decreaseDataScope {
    my ($this) = @_;

    my $scopeKey = pop( @{ $this->{_data}->{_fmKeys} } );
    delete $this->{_data}->{$scopeKey} if defined $this->{_data}->{$scopeKey};
}

sub _storeData {
    my ( $this, $key, $value ) = @_;

    my $scopeKey = $this->{_data}->{_fmKeys}[-1];
    if ( $scopeKey == 0 ) {

        # root
        $this->{_data}->{$key} = $value;
    }
    else {
        $this->{_data}->{$scopeKey}->{$key} = $value;
    }
}

sub data {
    my ( $this, $dataKey ) = @_;

    if ( !defined $dataKey ) {
        return $this->{_data};
    }

    my $data;
    foreach my $key ( reverse @{ $this->{_data}->{_fmKeys} } ) {
        $data = $this->{_data}->{$key}->{$dataKey}
          if defined $this->{_data}->{$key};
        last if defined $data;
    }
    if ( !defined $data ) {

        # look in root
        $data = $this->{_data}->{$dataKey};
    }

    return $data;
}

sub _parseIfBlock {
    my ( $this, $text ) = @_;

    if ( $this->{debug} || $this->{debugLevel} ) {
        print STDERR "_parseIfBlock; text=$text\n";
    }

    my @items = split( /(<#_if_|<#elseif|<#else)(.*?)>(.*?)/, $text );

    # remove first item
    splice @items, 0, 1;

    my $result = '';
    while ( scalar @items ) {

        my ( $tag, $condition, $tmp, $content ) = @items[ 0, 1, 2, 3 ];
        splice @items, 0, 4;

        if ( $this->{_data}->{_ftlData}->{strip_whitespace} == 1 ) {
            _stripWhitespaceAfterTag($content);
            _stripWhitespaceBeforeTag($content);
        }

        my $resultCondition = 0;
        if ( $tag eq '<#else' ) {
            $resultCondition = 1;
        }
        elsif ( defined $condition ) {

            if ( $this->{debug} || $this->{debugLevel} ) {
                print STDERR "\t condition=$condition\n";
            }

            # remove leading and trailing spaces
            _trimSpaces($condition);

            # create a dummy tag so we can use this same parser
            # and parse the conditon - it may contain variables
            $resultCondition = $this->_parse("<#_if_ $condition>");

        }
        if ( $this->{debug} || $this->{debugLevel} ) {
            print STDERR "\t resultCondition=$resultCondition\n";
        }

        if ($resultCondition) {    # so we may proceed
            if ( $this->{debug} || $this->{debugLevel} ) {
                print STDERR "\t content=$content\n";
            }

            $content =~
s/___ifblock(\d+)___/$this->{_workingData}->{ifBlocks}[$1] || ''/ge
              if $content;

            if ( $this->{debug} || $this->{debugLevel} ) {
                print STDERR "\t content after=$content\n";
            }

            $result = $this->_parse($content);

            last;
        }
    }

    return $result;
}

sub _value {
    my ( $this, $key, $storeValue ) = @_;

    $storeValue = 1 if !defined $storeValue;

    my $value = $this->data($key);

    if ( defined $value ) {
        if ( UNIVERSAL::isa( $value, "ARRAY" ) ) {
            $this->{_workingData}->{tmpData} = \@{$value} if $storeValue;
            return \@{$value};
        }
        else {
            $this->{_workingData}->{tmpData} = $value if $storeValue;
            return $value;
        }
    }
    my $d = $this->{_workingData}->{tmpData};
    $d = $this->data() if !defined $d;

    if ( UNIVERSAL::isa( $d, "HASH" ) ) {
        $value = $d->{$key};
    }
    $this->{_workingData}->{tmpData} = $value if $storeValue;
    return $value;
}

=pod

Protects string from expansion: adds '<fmg_nop>' string before '{'.

=cut

sub _protect {
    my ($string) = @_;

    return '' if !defined $string;

    $string =~ s/\{/<fmg_nop>{/go;
    return $string;
}

=pod

_renderList( $key, \@list, $format ) -> $renderedList

=cut

sub _renderList {
    my ( $this, $key, $listData, $format ) = @_;

    return $format if $_[0]->{_workingData}->{nestedLevel} > 0;

    if ( $this->{debug} || $this->{debugLevel} ) {
        print STDERR "_renderList; key=$key\n";
        print STDERR "nestedLevel=$_[0]->{_workingData}->{nestedLevel}\n";
        print STDERR "listData=" . Dumper($listData);
        print STDERR "format=$format\n";
    }

    my ( $spaceBeforeItems, $trimmedFormat, $spaceAfterEachItem ) =
      ( '', $format, '' );

    if ( $format && $this->{_data}->{_ftlData}->{strip_whitespace} == 1 ) {
        ( $spaceBeforeItems, $trimmedFormat, $spaceAfterEachItem ) =
          $format =~ m/^(\s*?)(.*?)(\s*)$/s;
    }

    $trimmedFormat = _unquote($trimmedFormat);

    my $rendered = $spaceBeforeItems;

    my $counter = 0;
    foreach my $item ( @{$listData} ) {

        $this->_storeData( $key, $item );
        my $parsedItem = $this->_parse($trimmedFormat);

        $rendered .= $parsedItem . $spaceAfterEachItem;
        $counter++;
    }

    return $rendered;
}

sub _isInsideTag {
    my ($this) = @_;

    return scalar @{ $this->{_context} } > 0;
}

=pod

Takes a string and returns an array ref.

For example:
	my $str = '["whale", "Barbara", "zeppelin", "aardvark", "beetroot"]';
	my $listref = _toList($str);
	
=cut

sub _toList {
    my ($listString) = @_;

    my @list = @{ eval $listString };
    return \@list;
}

sub _pushContext {
    my ( $this, $context ) = @_;

    print STDERR "\t _pushContext:$context\n"
      if ( $this->{debug} || $this->{debugLevel} );

    push @{ $this->{_context} }, $context;
}

sub _popContext {
    my ( $this, $context ) = @_;

    print STDERR "\t _popContext:$context\n"
      if ( $this->{debug} || $this->{debugLevel} );

    if ( defined @{ $this->{_context} }[-1]
        && @{ $this->{_context} }[ $#{ $this->{_context} } ] eq $context )
    {
        pop @{ $this->{_context} };
    }
}

sub _context {
    my ($this) = @_;

    return '' if !defined $this->{_context} || !scalar @{ $this->{_context} };
    return $this->{_context}[-1];
}

# UTIL FUNCTIONS

sub _unquote {
    my ($string) = @_;

    return '' if !defined $string;

    $string =~ s/^(\"|\')(.*)(\1)$/$2/s;
    return $string;
}

# STRING OPERATIONS

sub _substring {
    my ( $str, $from, $to ) = @_;

    my $length = defined $to ? $to - $from : ( length $str ) - $from;
    return substr( $str, $from, $length );
}

sub _capfirst {
    my ($str) = @_;

    $str =~ s/^([[:space:]]*)(\w+)/$1\u$2/;
    return $str;
}

sub _capitalize {
    my ($str) = @_;

    $str =~ s/\b(\w+)\b/\u$1/g;
    return $str;
}

sub _html {
    my ($str) = @_;

    $str =~ s/&/&amp;/go;
    $str =~ s/</&lt;/go;
    $str =~ s/>/&gt;/go;
    $str =~ s/"/&quot;/go;
    return $str;
}

sub _xhtml {
    my ($str) = @_;

    $str =~ s/&/&amp;/go;
    $str =~ s/</&lt;/go;
    $str =~ s/>/&gt;/go;
    $str =~ s/"/&quot;/go;
    $str =~ s/'/&#39;/go;
    return $str;
}

sub _replace {
    my ( $str, $from, $to ) = @_;

    $str =~ s/$from/$to/g;
    return $str;
}

sub _uncapfirst {
    my ($str) = @_;

    $str =~ s/^([[:space:]]*)(\w+)/$1\l$2/;
    return $str;
}

sub _wordlist {
    my ($str) = @_;

    $str =~ s/^[[:space:]]+//so;    # trim at start
    return split( /[[:space:]]+/, $str );
}

# END STRING OPERATIONS

# LIST OPERATIONS

sub _sort {
    my ($listRef) = @_;

    my @sorted = sort { lc($a) cmp lc($b) } @{$listRef};
    return \@sorted;
}

=pod

=cut

sub _interpolateEscapes {
    my ($string) = @_;

    # escaped string: \"
    $string =~ s/\\"/"/go;

    # escaped string: \'
    $string =~ s/\\'/'/go;

    # escaped newline: \n
    $string =~ s/\\n/\n/go;

    # escaped carriage return: \r
    $string =~ s/\\r/\n/go;

    # escaped tab: \t
    $string =~ s/\\t/\t/go;

    # backspace at end of string: \b
    $string =~ s/\\b$/\b /go;

    # backspace: \b
    $string =~ s/\\b/\b/go;

    # form feed: \f
    $string =~ s/\\f/\f/go;

    # less than: \l
    $string =~ s/\\l/</go;

    # greater than: \g
    $string =~ s/\\g/>/go;

    # ampersand: \a
    $string =~ s/\\a/&/go;

    # unicode - not yet supported
    $string =~ s/\\x([0-9a-fA-FX]+)/\\x{$1}/go;

    # escaped backslash: \\
    $string =~ s/\\\\/\\/go;

    return $string;
}

=pod

=cut

sub _trimSpaces {

    #my $text = $_[0]

    $_[0] =~ s/^[[:space:]]+//so;    # trim at start
    $_[0] =~ s/[[:space:]]+$//so;    # trim at end
}

sub _isNumber {

    #my ($input) = @_;

    return ( $_[0] =~ m/^$PATTERN_NUMBER/ );
}

sub _isString {

    # my ($input) = @_;
    return 0 if !$_[0];
    return 0 if ( UNIVERSAL::isa( $_[0], "ARRAY" ) );
    return 0 if ( UNIVERSAL::isa( $_[0], "HASH" ) );

    #	return 0 if _isNumber($_[0]);
    return ( $_[0] & ~$_[0] ) ? 1 : 0;
}

=pod

_arrayAsHash( \@array, $quoteStrings ) -> \%hash

Stores an array as hash with the array indices as values.

If $quoteStrings is set to 1, strings are quoted to tell them apart from numbers.

=cut

sub _arrayAsHash {
    my ( $list, $quoteStrings ) = @_;

    my $data  = {};
    my $index = 0;
    if ($quoteStrings) {
        for ( @{$list} ) {
            $data->{ _isString($_) ? "\"$_\"" : $_ } = $index;
            $index++;
        }
    }
    else {
        for ( @{$list} ) {
            $data->{$_} = $index;
            $index++;
        }
    }
    return $data;
}

=pod

Removes whitespace after tags.
Only if the line contains whitespace (spaces or newline).
Only strips the first newline.

=cut

sub _stripWhitespaceAfterTag {

    #my $text = $_[0]
    return if !$_[0];
    return ( $_[0] =~ s/^([ \t]+\r|[ \t]+\n|[ \t]+$|[\r\n]{1})//s );
}

sub _stripWhitespaceBeforeTag {

    #my $text = $_[0]
    return if !$_[0];
    return ( $_[0] =~ s/([ \t]+\r|[ \t]+\n|[ \t]+$|[\r\n]{1})$//s );
}

# PARSING

=pod

=cut

sub _lexer {

    #	my ( $parser ) = shift;

    return ( '', undef )
      if !defined $_[0]->YYData->{DATA} || $_[0]->YYData->{DATA} eq '';

    for ( $_[0]->YYData->{DATA} ) {

        my $isInsideTag = $_[0]->_isInsideTag();

        print STDERR "_lexer input=$_.\n"
          if ( $_[0]->{debug} || $_[0]->{debugLevel} );
        print STDERR "\t context=" . $_[0]->_context() . "\n"
          if ( $_[0]->{debug} || $_[0]->{debugLevel} );
        print STDERR "\t is inside tag=" . $isInsideTag . "\n"
          if ( $_[0]->{debug} || $_[0]->{debugLevel} );
        print STDERR "\t if level=" . $_[0]->{_workingData}->{ifLevel} . "\n"
          if ( $_[0]->{debug} || $_[0]->{debugLevel} );
        print STDERR "\t list level="
          . $_[0]->{_workingData}->{nestedLevel} . "\n"
          if ( $_[0]->{debug} || $_[0]->{debugLevel} );
        print STDERR "\t inTagBrackets="
          . $_[0]->{_workingData}->{inTagBrackets} . "\n"
          if ( $_[0]->{debug} || $_[0]->{debugLevel} );

        if ( $_[0]->_context() eq 'whitespace' ) {
            if ( $_[0]->{_data}->{_ftlData}->{strip_whitespace} == 1 ) {
                _stripWhitespaceAfterTag($_);
            }
            return ( 'whitespace', '' );
        }

        if (   $_[0]->_context() eq 'condition'
            || $_[0]->_context() eq 'evalcondition' )
        {
            $_ =~ s/^[ \t]*//o;

            if (s/^(\()\s*//o) {

                # make rest of condition safe: convert '>' to 'gt'
                $_ =~ s/^(.*?)\>(.*?)\)/$1gt$2)/o;
                return ( '(', $1 );
            }
            return ( ')', $1 ) if (s/^(\))\s*//o);

            return ( '.',      $1 ) if (s/^(\.)\s*//o);
            return ( 'NUMBER', $1 ) if (s/^$PATTERN_NUMBER//o);
            return ( '==',     $1 ) if (s/^(\=\=)\s*//o);
            return ( '==',     $1 ) if (s/^\b(eq)\b\s*//o);
            return ( '&&',     $1 ) if (s/^(&&)\s*//o);
            return ( '||',     $1 ) if (s/^(\|\|)\s*//o);
            return ( 'gte',    $1 ) if (s/^(\>\=)\s*//o);
            return ( 'gte',    $1 ) if (s/^\b(gte)\b\s*//o);
            return ( 'gte',    $1 ) if (s/^(&gte;)\s*//o);
            return ( 'lte',    $1 ) if (s/^(\<\=)\s*//o);
            return ( 'lte',    $1 ) if (s/^\b(lte)\b\s*//o);
            return ( 'lte',    $1 ) if (s/^(&lte;)\s*//o);
            return ( 'gt',     $1 ) if (s/^\b(gt)\b\s*//o);
            return ( 'gt',     $1 ) if (s/^(&gt;)\s*//o);
            return ( 'lt',     $1 ) if (s/^(\<)\s*//o);
            return ( 'lt',     $1 ) if (s/^\b(lt)\b\s*//o);
            return ( 'lt',     $1 ) if (s/^(&lt;)\s*//o);
            return ( '!=',     $1 ) if (s/^(\!\=)\s*//o);
            return ( '!=',     $1 ) if (s/^\b(ne)\b\s*//o);
            return ( '!',      $1 ) if (s/^(\!)\s*//o);
            return ( '==',     $1 ) if (s/^(\=)\s*//o);
            return ( '??',     $1 ) if (s/^(\?\?)\s*//o);
            return ( '?',      $1 ) if (s/^(\?)\s*//o);
            return ( '[',      $1 ) if (s/^(\[)\s*//o);
            return ( ']',      $1 ) if (s/^(\])\s*//o);

            if ( $_[0]->_context() eq 'condition' ) {
                return ( 'string', $1 ) if (s/^([\w\.\[\]\"]+)//o);
            }

            return ( 'string', _interpolateEscapes($1) )
              if (s/^$PATTERN_PRESERVE_QUOTES//o);

            # string operations
            return ( $1, $1 )
              if ( s/^$PATTERN_STRING_OP\s*//o );

            # sequence operations
            return ( $1, $1 )
              if ( s/^$PATTERN_SEQUENCE_OP\s*//o );

            return ( 'DATA_KEY', $1 ) if (s/^(\w+)//);

           #return ( 'gt', $1 ) if (s/^(\>)\s*//); # not supported by FreeMarker
        }

        # when inside an if block:
        # go deeper with <#if...
        # go up one level with </#if>
        # ignore all other tags, these will be parsed in _parseIfBlock
        if ( $_[0]->{_workingData}->{ifLevel} != 0 ) {
            return ( '>', '' ) if (s/^\s*>//o);
            if (s/^<\#\b(if)\b/$1/) {
                $_[0]->{_workingData}->{inTagBrackets} = 1;
                return ( '<#', '' );
            }
            return ( '</#',    '' ) if (s/^\s*<\/\#\b(if)\b/$1/o);
            return ( 'if',     $1 ) if s/^\b(if)\b//o;
            return ( 'string', $1 ) if (s/^(.*?)(<(\/?\#\bif\b))/$2/so);
        }

        # delay parsing of list contents
        if ( $_[0]->{_workingData}->{nestedLevel} != 0 ) {
            return ( 'string', $1 )
              if (s/^\s*(<#\blist\b.*)(<\/\#\blist\b>)/$2/so);
        }

        if ( $_[0]->_context() eq 'list' ) {

            #if ( $_[0]->{_workingData}->{nestedLevel} != 0 ) {
            return ( '>', '' ) if (s/^\s*>//o);
            if (s/^<\#\b(list)\b/$1/o) {
                $_[0]->{_workingData}->{inTagBrackets} = 1;
                return ( '<#', '' );
            }
            return ( '</#',    '' ) if (s/^\s*<\/\#\b(list)\b/$1/o);
            return ( 'list',   $1 ) if s/^\b(list)\b//o;
            return ( 'string', $1 ) if (s/^(.*?)(<(\/?\#\blist\b))/$2/so);
        }

        # delay parsing of macro contents
        if ( $_[0]->_context() eq 'macrocontents' ) {
            return ( '>', '' ) if (s/^\s*>//o);
            if (s/^<\#\b(macro)\b/$1/o) {
                $_[0]->{_workingData}->{inTagBrackets} = 1;
                return ( '<#', '' );
            }
            return ( '</#',    '' ) if (s/^\s*<\/\#\b(macro)\b/$1/o);
            return ( 'macro',  $1 ) if s/^\b(macro)\b//o;
            return ( 'string', $1 ) if (s/^(.*?)(<(\/?\#\bmacro\b))/$2/so);
        }

        # delay parsing of assign contents
        if ( $_[0]->_context() eq 'assign' ) {
            return ( '>', '' ) if (s/^\s*>//o);
            if (s/^<\#\b(assign)\b/$1/o) {
                $_[0]->{_workingData}->{inTagBrackets} = 1;
                return ( '<#', '' );
            }
            return ( '</#',    '' ) if (s/^\s*<\/\#\b(assign)\b/$1/o);
            return ( 'assign', $1 ) if s/^\b(assign)\b//o;
            return ( 'string', $1 ) if (s/^(.*?)(<(\/?\#\bassign\b))/$2/so);
        }

        # tags

        if ( $_[0]->{_workingData}->{inTagBrackets} ) {
            return ( '--',     $1 ) if s/^(--)//o;
            return ( 'assign', $1 ) if s/^\b(assign)\b//o;
            return ( 'macro',  $1 ) if s/^\b(macro)\b//o;
            return ( 'list',   $1 ) if s/^\b(list)\b//o;
            return ( 'if',     $1 ) if s/^\b(if)\b//o;
            return ( '_if_',   $1 ) if (s/^\b(_if_)\b//o);
            return ( 'ftl',    $1 ) if (s/^\b(ftl)\b//o);
            return ( 'dump',   $1 ) if (s/^\b(dump)\b//o);
        }

        if ( $_[0]->{_workingData}->{inTagBrackets} && s/^\s*>//o ) {
            $_[0]->{_workingData}->{inTagBrackets} = 0;
            return ( '>', '' );
        }
        if (s/^(<(?:#|@))//o) {
            $_[0]->{_workingData}->{inTagBrackets} = 1;
            return ( $1, '' );
        }
        if (s/^(<\/(?:#|@))//o) {
            $_[0]->{_workingData}->{inTagBrackets} = 1;
            return ( $1, '' );
        }

        return ( 'as', $1 ) if s/^\s*\b(as)\b//o;

        # variables
        if ( !$isInsideTag ) {
            return ( '${', '' ) if (s/^\$\{//o);
            return ( '}',  '' ) if (s/^\}//o);
        }

        if (   $_[0]->_context() eq 'tagParams'
            || $_[0]->_context() eq 'variableParams'
            || $_[0]->_context() eq 'listParams'
            || $_[0]->_context() eq 'assignment' )
        {
            $_ =~ s/^[[:space:]]*//o;
            return ( 'NUMBER', $1 )
              if (s/^(\d+)(\.\.)\s*/$2/o)
              ;   # with array access - prevent that first dot is seen as number
            return ( '.vars',  $1 ) if (s/^(\.vars)\s*//o);
            return ( '..',     $1 ) if (s/^(\.\.)\s*//o);
            return ( '.',      $1 ) if (s/^(\.)\s*//o);
            return ( '+',      $1 ) if (s/^(\+)\s*//o);
            return ( '-',      $1 ) if (s/^(\-)\s*//o);
            return ( '*',      $1 ) if (s/^(\*)\s*//o);
            return ( '/',      $1 ) if (s/^(\/)\s*//o);
            return ( '%',      $1 ) if (s/^(%)\s*//o);
            return ( '?',      $1 ) if (s/^(\?)\s*//o);
            return ( 'true',   $1 ) if (s/^(\"*true\"*)\s*//o);
            return ( 'false',  $1 ) if (s/^(\"*false\"*)\s*//o);
            return ( 'NUMBER', $1 ) if (s/^$PATTERN_NUMBER//o);

            # string operations
            return ( $1, $1 )
              if ( s/^$PATTERN_STRING_OP\s*//o );

            # sequence operations
            return ( $1, $1 )
              if ( s/^$PATTERN_SEQUENCE_OP\s*//o );

            # other strings
            return ( 'string', _interpolateEscapes($1) )
              if (s/^$PATTERN_PRESERVE_QUOTES//o);

            if (   $_[0]->_context() eq 'variableParams'
                || $_[0]->_context() eq 'listParams' )
            {
                return ( 'r',        $1 ) if (s/^\b(r)\b//o);
                return ( '!',        $1 ) if (s/^(!)\s*//o);
                return ( 'DATA_KEY', $1 ) if (s/^(\w+)//o);
            }
            if ( $_[0]->_context() eq 'assignment' ) {
                return ( 'DATA_KEY', $1 ) if (s/^(\w+)//o);
                return ( '=',        $1 ) if (s/^(\=)\s*//o);
            }
            if ( $_[0]->_context() eq 'tagParams' ) {
                return ( 'string', $1 ) if (s/^(\w+)\s*//o);
            }
            return ( '=', $1 ) if (s/^(\=)\s*//o);
            return ( '[', $1 ) if (s/^(\[)\s*//o);
            return ( ']', $1 ) if (s/^(\])\s*//o);
            return ( '(', $1 ) if (s/^(\()\s*//o);
            return ( ')', $1 ) if (s/^(\))\s*//o);
            return ( '{', $1 ) if (s/^(\{)\s*//o);
            return ( '}', $1 ) if (s/^(\})//o);
            return ( ':', $1 ) if (s/^(:)\s*//o);
            return ( ',', $1 ) if (s/^(,)\s*//o);
        }

        if ($isInsideTag) {
            return ( 'string', $1 ) if (s/^(.*?)(-->|<\#|<\/\#)/$2/so);
        }
        else {
            return ( 'string', $1 )
              if (s/^(.*?)(<\#|<\@|\$\{)/$2/so);

            return ( 'string', $1 )
              if (s/^(\w+)(\>)/$2/so);

            return ( 'string', $1 )
              if (s/^(.*)$//so);
        }
    }
}

sub _error {
    exists $_[0]->YYData->{ERRMSG}
      and do {
        print STDERR $_[0]->YYData->{ERRMSG};
        delete $_[0]->YYData->{ERRMSG};
        return;
      };
    print STDERR "Syntax error\n";
}

sub _parse {

    #my ( $this, $input, $dataRef ) = @_;

    return '' if !defined $_[1] || $_[1] eq '';

    print STDERR "_parse:input=$_[1]\n"
      if ( $_[0]->{debug} || $_[0]->{debugLevel} );

    my $parser = new Foswiki::Plugins::FreeMarkerPlugin::FreeMarkerParser();

    $parser->{debugLevel} = $_[0]->{debugLevel};
    $parser->{debug}      = $_[0]->{debug};
    $parser->{_data}      = $_[0]->{_data};
    if ( keys %{ $_[2] } ) {
        my %data = ( %{ $_[2] }, %{ $parser->{_data} } );
        $parser->{_data} = \%data;
    }
    $parser->{_workingData} = $_[0]->{_workingData};

    return $parser->_nestedParse( $_[1] );
}

sub _nestedParse {

    #my ( $this, $input, $dataRef ) = @_;

    return '' if !defined $_[1] || $_[1] eq '';

    $_[0]->_init( $_[2] );

    $recursiveLevel++;
    return $_[1] if ( $recursiveLevel > $MAX_RECURSIVE_LEVEL );

    $_[0]->_increaseDataScope();

    $_[0]->YYData->{DATA} = $_[1];
    my $result = $_[0]->YYParse(
        yylex   => \&_lexer,
        yyerror => \&_error,
        yydebug => $_[0]->{debugLevel}
    );
    $result = '' if !defined $result;

    $recursiveLevel--;
    $_[0]->_decreaseDataScope();

    return $result;
}

=pod

parse ($input, \%data)  -> $result

Takes an input string and returns the parsed result.

param $input: string
param \%data: optional hash of variables that are used with variable substitution


1.	Build data model from <#...></#...> directives (tags).
	All non-scalar data is stored as references.
2.	Invoke function calls (text substitution)
3.	Substitute ${...} variables based on data model

Lingo:

With the example:
	<#assign x>hello</#assign>

assign:		directive
x:			expression (a variable)
hello:		tag content

With the example:
	<#assign x="10">

assign:		operator
x="10":		expression (assignment)


Order of variable substitution is from top to bottom, as illustrated with this example:

	${mouse!"No mouse."}
	<#assign mouse="Jerry">
	${mouse!"No mouse."}  

The output will be:

	No mouse.
	Jerry  

=cut

sub parse {

    #my ( $this, $input, $dataRef ) = @_;

    return '' if !defined $_[1] || $_[1] eq '';

    $recursiveLevel++;
    return $_[1] if ( $recursiveLevel > $MAX_RECURSIVE_LEVEL );

    $_[0]->_init( $_[2] );
    $_[0]->_increaseDataScope();
    $_[0]->{debug}      ||= 0;
    $_[0]->{debugLevel} ||= 0;

    use Data::Dumper;

#print STDERR "parse -- input data=" . Dumper($_[0]->{_data}) . "\n" if ( $_[0]->{debug} || $_[0]->{debugLevel} );

    print STDERR "parse:input=$_[1]\n"
      if ( $_[0]->{debug} || $_[0]->{debugLevel} );

    $_[0]->YYData->{DATA} = $_[1];
    my $result = $_[0]->YYParse(
        yylex   => \&_lexer,
        yyerror => \&_error,
        yydebug => $_[0]->{debugLevel}
    );
    $result = '' if !defined $result;

    # remove expansion protection
    $result =~ s/<fmg_nop>//go;

    print STDERR "parse:result=$result\n"
      if ( $_[0]->{debug} || $_[0]->{debugLevel} );

    undef $_[0]->{_workingData};

    # pass data to Parse::Yapp parser
    $_[0]->{data} = $_[0]->{_data};

    $recursiveLevel--;
    $_[0]->_decreaseDataScope();

    #delete $_[0]->{_data};
    delete $_[0]->{_workingData};
    $dataKeyId = 0;

    return $result;
}

=pod

setDebugLevel( $debug, $debugLevel )

=debug=: number
=debugLevel=: number

Set debugging state and the level of debug messages.

Bit Value    Outputs
0x01         Token reading (useful for Lexer debugging)
0x02         States information
0x04         Driver actions (shifts, reduces, accept...)
0x08         Parse Stack dump
0x10         Error Recovery tracing

=cut

sub setDebugLevel {
    my ( $this, $debug, $debugLevel ) = @_;

    $this->{debug}      = $debug;
    $this->{debugLevel} = $debugLevel;
}




1;
