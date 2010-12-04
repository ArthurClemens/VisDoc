# See bottom of file for license and copyright information

package VisDoc::ParserJava;

use base 'VisDoc::ParserBase';
use strict;
use warnings;

our $ID = 'java';

### CLASS METHODS ###

=pod

StaticMethod getLanguageId ($filePath) -> $text

Returns the language id if the filepath ends on '.java'.

=cut

sub getLanguageId {
    my ($inFilePath) = @_;

    return undef if !$inFilePath;
    return $ID if $inFilePath =~ m/^.*\.java$/;
}

### INSTANCE METHODS ###

sub new {
    my ( $class, $inFileParser ) = @_;
    my VisDoc::ParserJava $this = $class->SUPER::new($inFileParser);

    $this->{PATTERN_PACKAGE} = '
  [[:space:]]*						    # any space
  (%VISDOC_STUB_JAVADOC_COMMENT_[0-9]+%)* # i1: javadoc comment
  [[:space:];]*						    # any space or semi-colon
  \bpackage\b		# word "package"
  [[:space:]]+      # any space
  (					# i2: total group of package attributes
  ([^;^\n]+)		# i3: any char except for a newline or a ;
  (\.\*)*			# i4: to catch .*, like in: package treemap.*;
  )                 # /i2
  ';

    $this->{PATTERN_CLASS_NAME} = '[[:alnum:]_\$\.,\<\>]+';

    my $PATTERN_CLASS_ACCESS =
'private|public|protected|static|final|transient|volatile|native|synchronized|abstract|strictfp';

    $this->{PATTERN_CLASS_LINE_WITH_JAVADOC} = '
  [[:space:]]*						     # any space
  (%VISDOC_STUB_JAVADOC_COMMENT_[0-9]+%)*	 # i1: javadoc comment contents
  [[:space:];]*						     # any space or semi-colon
  (								         # i2: group total access
  (' . $PATTERN_CLASS_ACCESS . ')*	     # i3: sub-access
  [[:space:]]*					         # any space
  (' . $PATTERN_CLASS_ACCESS . ')*	     # i4: sub-access
  )								         # /i2
  [[:space:]]*					         # any space
  \b(class|interface)+\b                 # i5: type: "class" or "interface"
  [[:space:]]*						     # any space
  (' . $this->{PATTERN_CLASS_NAME} . ')   # i6: class name
  [[:space:]]*						     # any space
  ([[:alnum:][:space:]_\$\.,\<\>]+)      # i7: superclasses, interfaces: group words in "extends" or "implements"
  {									     # opening brace
  ';

    $this->{MAP_CLASS_LINE_WITH_JAVADOC} = {
        javadoc      => 1,
        access       => 2,
        type         => 5,
        name         => 6,
        superclasses => 7,
        interfaces   => 7,
    };

    my $PATTERN_MEMBER_ACCESS = 'public|private|protected|static|final';

    use Regexp::Common qw( RE_balanced );
    my $balanced_braces = RE_balanced( -parens => '{}', -keep );

    $this->{PATTERN_METHOD_NAME} = '[[:alnum:]_\$,\<\>\[\] ]+';

    $this->{PATTERN_METHOD_WITH_JAVADOC} = '
  [[:space:]]*					# any space
  (%VISDOC_STUB_JAVADOC_COMMENT_[0-9]+%)*  # i1: javadoc comment
  [[:space:];]*					# any space or semi-colon
  (								# i2: group total access
  (' . $PATTERN_MEMBER_ACCESS . ')*	# i3: sub-access
  [[:space:]]*					# any space
  (' . $PATTERN_MEMBER_ACCESS . ')*	# i4: sub-access
  [[:space:]]*					# any space
  (' . $PATTERN_MEMBER_ACCESS . ')*	# i5: sub-access
  )								# /i2
  [[:space:]]*					# any space
  (                             # i6: type and name
  ([[:alnum:]_\$,\<\>\?\[\] ]+) # i7: type
  [[:space:]]					# space
  (' . $this->{PATTERN_METHOD_NAME} . ')  # i8: name
  )                             # /i6
  [[:space:]]*					# any space
  \(							# start of parameter list
  (								# i9: group parameters
  [^\)]*						# parameter chars: any char that is not ")"
  )								# end parameters
  \)							# /i9
  [[:space:]]*					# any space
  (throws[[:space:]]*[[:alnum:]_\$,\<\>\?\[\] ]+)* # i10: throws
  [[:space:]]*					# any space
  (                             # i11: end of method options...
  ;                             # semi-colon
  |                             # or
  ' . $balanced_braces . '      # i12: end of method: braces
  )
';

    $this->{PATTERN_PARAMETER} = '
  ^                             # start of string
  ([[:alnum:]_\$,\<\>\?\[\] ]+)   # i1: type
  [[:space:]]					# any space
  ([[:alnum:]_\$,\<\>\[\] ]+)   # i2: name
  $				                # end of string
  ';

    $this->{MAP_METHOD_WITH_JAVADOC} = {
        javadoc       => 1,
        access        => 2,
        returnType    => 7,
        name          => 8,
        parameters    => 9,
        exceptionType => 10,
        end           => 12,
    };

    $this->{PATTERN_PROPERTY_WITH_JAVADOC} = '
  [[:space:]]*					# any space
  (%VISDOC_STUB_JAVADOC_COMMENT_[0-9]+%)*  # i1: javadoc comment
  [[:space:];]*					# any space or semi-colon
  (								# i2: group total access
  (' . $PATTERN_MEMBER_ACCESS . ')*	# i3: sub-access
  [[:space:]]*					# any space
  (' . $PATTERN_MEMBER_ACCESS . ')*	# i4: sub-access
  [[:space:]]*					# any space
  (' . $PATTERN_MEMBER_ACCESS . ')*	# i5: sub-access
  )								# 
  [[:space:]]*					# any space
  (                             # i6: type and name
  ([[:alnum:]_\$,\<\>\?\[\] ]+) # i7: dataType
  [[:space:]]					# space
  ([[:alnum:]_\$,\<\>\[\] ]+)   # i8: name
  )                             # /i6
  [[:space:]]*					# any space
  \=*                           # =
  [[:space:]]*					# any space
  ([^;]*)                       # i9: value
  ;                             # end semi-colon
  [[:space:]]*					# any space
  (%{VISDOC_STUB_JAVADOC_SIDE[0-9]+}%)* # i10: javadoc side comment
  ';

    $this->{MAP_PROPERTY_WITH_JAVADOC} = {
        javadoc     => 1,
        access      => 2,
        dataType    => 7,
        name        => 8,
        value       => 9,
        javadocSide => 10,
    };

    $this->{PATTERN_ARRAY} = '
	\=\s*       # do only convert property values, not meta tags
	(\[.*?\])     # array content
	';

    bless $this, $class;
    return $this;
}

=pod

retrievePackageName($text) -> $name

Reads the package name from the text. Text must be clean from comments.
 
=cut

sub retrievePackageName {
    my ( $this, $inText ) = @_;

    my $result = $inText =~ m/$this->{PATTERN_PACKAGE}/x;
    return ( $result && $2 )
      ? $2
      : '';
}

=pod

_isPublic( \@access ) -> $bool

Checks access list if class or member is public.

=cut

sub _isPublic {
    my ( $this, $inAccess ) = @_;

    my %access = map { $_ => 1 } ( @{$inAccess} );
    my $isPublic = 0;    # default
    $isPublic = 1 if $access{public};
    return $isPublic;
}

=pod

_handleMethodMatches (@matches, \@methods, $patternMap) -> (\@methodData, $lastChar)

=cut

sub _handleMethodMatches {
    my ( $this, $inMatches, $inMethods, $inPatternMap ) = @_;

    my $i;    # match index

    my VisDoc::MethodData $methodData = VisDoc::MethodData->new();
    push @{$inMethods}, $methodData;

    my $data = $methodData;

    # set properties

    # method id
    $data->{_id} = scalar @{$inMethods} - 1;

    # javadoc
    $i = $inPatternMap->{javadoc} - 1;
    if ( $inMatches->[$i] && $inMatches->[$i] ) {

        #$data->{javadocStub} = $inMatches->[$i];
        my $javadoc = $this->{fileParser}->parseJavadoc( $inMatches->[$i] );
        $data->setJavadoc($javadoc);
    }

    # access
    $i = $inPatternMap->{access} - 1;
    if ( $inMatches->[$i] && $inMatches->[$i] ) {
        my $accessStr = $inMatches->[$i];
        if ($accessStr) {
            my @access = $this->_parseMemberAccess($accessStr);
            $data->{access} = \@access;
        }
    }
    $data->{isAccessPublic} = $this->_isPublic( $data->{access} );

    # returnType
    $i = $inPatternMap->{returnType} - 1;
    if ( $inMatches->[$i] && $inMatches->[$i] ) {
        my $returnTypeStr = $inMatches->[$i];
        $data->{returnType} = $this->_parseMethodType($returnTypeStr);
    }

    # name
    $i = $inPatternMap->{name} - 1;
    if ( $inMatches->[$i] && $inMatches->[$i] ) {
        my $nameStr = $inMatches->[$i];
        $data->{name} = $this->_parseMethodName($nameStr);
    }

    # parameters
    $i = $inPatternMap->{parameters} - 1;
    if ( $inMatches->[$i] && $inMatches->[$i] ) {
        my $parametersStr = $inMatches->[$i];
        $data->{parameters} = $this->_parseMethodParameters($parametersStr);

        $data->{qualifiedName} = $data->{name} . '(' . $parametersStr . ')';
        $data->{qualifiedName} =~ s/ //go;
    }

    # exception type
    $i = $inPatternMap->{exceptionType} - 1;
    if ( $inMatches->[$i] && $inMatches->[$i] ) {
        my $exceptionTypeStr = $inMatches->[$i];
        $data->{exceptionType} =
          $this->_parseMethodExceptionType($exceptionTypeStr);
    }

    # last char
    my $lastChar = '';
    $i = $inPatternMap->{end} - 1;
    if ( $inMatches->[$i] && $inMatches->[$i] ) {
        $lastChar = $inMatches->[$i];
    }

    return ( $inMethods, $lastChar );
}

sub _parseMethodExceptionType {
    my ( $this, $inText ) = @_;

    ( my $exception = $inText ) =~
      s/^[[:space:]]*throws[[:space:]](.*?)[[:space:]]*$/$1/;
    return $exception;
}

=pod

=cut

sub _preparePropertyParsing {
    my ( $this, $inText ) = @_;

    my $pattern = $this->{PATTERN_MULTILINE_PROPERTY_OBJECT};

    my $text = $inText;

    #    $text =~ s/$pattern/$this->_stubObjectProperties($1,$9,$10)/gsex;

    $text = $this->{fileParser}->stubArrays( $text, $this->{PATTERN_ARRAY}, 1 );

    #	$text = $this->_splitOutOneLineProperties($text);
    $text =~ s/$VisDoc::StringUtils::STUB_SPACE/ /go;
    return $text;
}

=pod

=cut

sub _splitOutOneLineProperty {
    my ( $this, $inMatches, $inPatternMap ) = @_;

    # set properties
    my $i;    # match index

    my $text;

    # complete match
    if ( $inMatches->[0] && $inMatches->[0] ) {
        $text = $inMatches->[0];
    }

    # javadoc
    my $javadocStr = '';
    $i = $inPatternMap->{javadoc};
    if ( $inMatches->[$i] && $inMatches->[$i] ) {
        $javadocStr = $inMatches->[$i];
    }

    # javadoc side
    my $javadocSideStr = '';
    $i = $inPatternMap->{javadocSide};
    if ( $inMatches->[$i] && $inMatches->[$i] ) {
        $javadocSideStr = $inMatches->[$i];
    }

    # access
    my $accessStr = '';
    $i = $inPatternMap->{access};
    if ( $inMatches->[$i] && $inMatches->[$i] ) {
        $accessStr = $inMatches->[$i];
    }

    # nameAndDataType
    my $nameAndDataType = '';
    $i = $inPatternMap->{nameAndDataType};
    if ( $inMatches->[$i] && $inMatches->[$i] ) {
        $nameAndDataType = $inMatches->[$i];
    }

    # property id
    $i = $inPatternMap->{nameAndDataType};
    if ( $inMatches->[$i] && $inMatches->[$i] ) {
        my $valueStr = $inMatches->[$i];
        if ( $valueStr ne '' ) {
            my @values =
              VisDoc::StringUtils::commaSeparatedListFromCommaSeparatedString(
                $valueStr);
            if ( ( scalar @values ) > 1 ) {
                $text = '';
                foreach my $otherValue (@values) {
                    $text .= $javadocStr ? "\n$javadocStr\n" : '';
                    $text .= $accessStr  ? "$accessStr"      : '';

                    # prevent concatenation of properties
                    $text .= ";\n" . $VisDoc::StringUtils::STUB_SPACE if !$text;
                    $text .= $nameAndDataType ? " $nameAndDataType " : '';
                    $text .= $otherValue;
                    $text .= ';';
                    $text .= $javadocSideStr  ? " $javadocSideStr\n" : '';
                    $text .= "\n\n";
                }
            }
        }
    }

    # prevent infinite recursion:
    $text =~ s/ /$VisDoc::StringUtils::STUB_SPACE/go;
    return $text;
}

=pod

_parseMethodParameterData(\@list) -> \@parameterData

Creates a list of ParameterData objects, read from a list of parameter strings.

=cut

sub _parseMethodParameterData {
    my ( $this, $inList ) = @_;

    my @parameterDataList;

    foreach my $paramString ( @{$inList} ) {
        my ( $dataType, $name, $defaultValue ) =
          $paramString =~ m/$this->{PATTERN_PARAMETER}/x;

        my VisDoc::ParameterData $paramData =
          VisDoc::ParameterData->new( undef, $name, $dataType, $defaultValue );
        push( @parameterDataList, $paramData );
    }
    return \@parameterDataList;
}

sub _handlePropertyMatches {
    my ( $this, $inMatches, $inProperties, $inPatternMap ) = @_;

    my VisDoc::PropertyData $propertyData = VisDoc::PropertyData->new();
    push @{$inProperties}, $propertyData;

    my $data = $propertyData;

    # set properties
    my $i;    # match index

    # data type
    $i = $inPatternMap->{dataType} - 1;
    if ( $inMatches->[$i] && $inMatches->[$i] ) {
        my $dataTypeStr = $inMatches->[$i];
        $data->{dataType} = $this->_parsePropertyDataType($dataTypeStr);
    }

    # property id
    $data->{_id} = scalar @{$inProperties} - 1;

    # javadoc
    $i = $inPatternMap->{javadoc} - 1;
    if ( $inMatches->[$i] && $inMatches->[$i] ) {
        my $javadocStub = $inMatches->[$i];
        my $javadoc     = $this->{fileParser}->parseJavadoc($javadocStub);
        $data->setJavadoc($javadoc);
    }

    # javadoc side
    $i = $inPatternMap->{javadocSide} - 1;
    if ( $inMatches->[$i] && $inMatches->[$i] ) {
        my $javadocStub = $inMatches->[$i];
        my $javadoc     = $this->{fileParser}->parseJavadoc($javadocStub);
        $data->setJavadoc($javadoc);
    }

    # access
    $i = $inPatternMap->{access} - 1;
    if ( $inMatches->[$i] && $inMatches->[$i] ) {
        my $accessStr = $inMatches->[$i];
        if ($accessStr) {
            my @access = $this->_parseMemberAccess($accessStr);
            $data->{access} = \@access;
        }
    }
    $data->{isAccessPublic} = $this->_isPublic( $data->{access} );

    # name
    $i = $inPatternMap->{name} - 1;
    if ( $inMatches->[$i] && $inMatches->[$i] ) {
        my $nameStr = $inMatches->[$i];
        $data->{name} = $data->{qualifiedName} =
          $this->_parsePropertyName($nameStr);
    }

    # value
    $i = $inPatternMap->{value} - 1;
    if ( $inMatches->[$i] && $inMatches->[$i] ) {
        my $valueStr = $inMatches->[$i];
        $data->{value} = $this->_parsePropertyValue($valueStr);
    }

    return $inProperties;
}

1;

# VisDoc - Code documentation generator, http://visdoc.org
# This software is licensed under the MIT License
#
# The MIT License
#
# Copyright (c) 2010 Arthur Clemens, VisDoc contributors
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
