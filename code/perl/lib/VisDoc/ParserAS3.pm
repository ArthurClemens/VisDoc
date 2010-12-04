# See bottom of file for license and copyright information

package VisDoc::ParserAS3;

use base 'VisDoc::ParserAS2';
use strict;
use warnings;
use VisDoc::ClassData;
use VisDoc::MemberData;
use VisDoc::MethodData;
use VisDoc::MetadataData;

our $ID = 'as3';

### CLASS METHODS ###

=pod

StaticMethod getLanguageId ($fileText) -> $text

Returns the language id if a valid key can be found in the text.

=cut

sub getLanguageId {
    my ($inText) = @_;

    my $text = $inText;
    VisDoc::StringUtils::stripToPrepareReadingLanguageId($text);

    my VisDoc::ParserAS3 $tmp_parser = VisDoc::ParserAS3->new();
    my $result = $inText =~ m/$tmp_parser->{PATTERN_PACKAGE}/x;
    return $ID if $result && $2;
}

### INSTANCE METHODS ###

sub new {
    my ( $class, $inFileParser ) = @_;

    my VisDoc::ParserAS3 $this = $class->SUPER::new($inFileParser);

    my $PATTERN_METADATA = '
  ((?:\[[^\]]*\][[:space:]]*)*)     # everything between [...] brackets
  ';
  
    $this->{PATTERN_PACKAGE} = '
  [[:space:]]*						    # any space
  (%VISDOC_STUB_JAVADOC_COMMENT_[0-9]+%)* # i1: javadoc comment
  [[:space:];]*						    # any space or semi-colon
  (					                    # i2: group word "package" so even with an anonymous package name we can find a match
  \bpackage\b		                    # word "package"
  )
  [[:space:]]+		# a space
  (					# i3: package name group
  [[:alnum:]_$.]*	# the package name, including _$. chars
  )					#
  [[:space:]]*		# any space
  {				    # opening brace
  ';

    $this->{PATTERN_CLASS_NAME} = '[[:alnum:]_\$\.]+';

    $this->{PATTERN_CLASS_LINE_WITH_JAVADOC} = '
  [[:space:]]*						        # any space
  (									        # i1: javadoc comment
  %VISDOC_STUB_JAVADOC_COMMENT_[0-9]+%		# javadoc comment contents
  )*
  [[:space:];]*						        # any space or semi-colon
  ' . $PATTERN_METADATA . '                 # i2: metadata
  [[:space:];]*						        # any space or semi-colon
  (public|static|private|final|dynamic|intrinsic|internal|protected)*	  						 # i3: access
  [[:space:]]*						        # any space
  \b(class|interface)+\b                    # i4: type: "class" or "interface"
  [[:space:]]*						        # any space
  (' . $this->{PATTERN_CLASS_NAME} . ')     # i5: class name
  [[:space:]]*						        # any space
  ([^{]*)							        # i6: superclasses, interfaces: group words in "extends" or "implements"
  [[:space:]]*						        # any space
  {									        # opening brace
  ';
    $this->{MAP_CLASS_LINE_WITH_JAVADOC} = {
        javadoc      => 1,
        metadata     => 2,
        access       => 3,
        type         => 4,
        name         => 5,
        superclasses => 6,
        interfaces   => 6,
    };
    
    $this->{PATTERN_METADATA_CONTENTS} = '
  \[								# opening bracket [
  ([[:alnum:]\"\']*)				# i1: metadata identifier
  \]
  |
  \[								# opening bracket [
  ([[:alnum:]\"\']*)				# i2: metadata identifier
  [[:space:]]*						# any space
  \(*								# optional opening bracket of contents
  [[:space:]]*						# any space
  ([^\)]*)							# i3: contents (any char except closing bracket)
  [[:space:]]*						# any space
  \)*								# optional closing bracket of contents
  [[:space:]]*						# any space
  \]								# closing bracket ]
  ';

    $this->{PATTERN_KEY_IS_VALUE} = '
  ^									# start of string
  (									#
  (\w*)								# i2: key
  \s*=\s*							# =
  )*								#
  ([[:alnum:][:punct:]]*)           # i3: value
  $									# end of string
  ';

    my $PATTERN_MEMBER_ACCESS =
'public|private|protected|static|virtual|final|override\s*\(true\)|override\s*\(false\)|override\s*\(undefined\)|override';

    $this->{PATTERN_METHOD_NAME} = '[[:alnum:]_\$]+';

    $this->{PATTERN_METHOD_WITH_JAVADOC} = '
  [[:space:]]*						# any space
  (%VISDOC_STUB_JAVADOC_COMMENT_[0-9]+%)*  # i1: javadoc comment
  [[:space:];]*					# any space or semi-colon
  ' . $PATTERN_METADATA . '     # i2: metadata
  [[:space:];]*					# any space or semi-colon  
  (								# i3: group total access
  (' . $PATTERN_MEMBER_ACCESS . ')*	# i4: sub-access
  [[:space:]]*					# any space
  (' . $PATTERN_MEMBER_ACCESS . ')*	# i5: sub-access
  )								# 
  [[:space:]]*					# any space
  \bfunction\b
  [[:space:]]*					# any space
  (								# i6: group getset and name
  (get|set)*					# i7: get or set accessor
  [[:space:]]*					# any space
  (' . $this->{PATTERN_METHOD_NAME} . ')   # i8: name
  )
  [[:space:]]*					# any space
  \(							# start of parameter list
  (								# i9: group parameters
  [^\)]*						# parameter chars: any char that is not ")"
  )								# end parameters
  \)							# /i9
  [[:space:]\:]*				# spaces or a colon
  ([[:alnum:]\.\*]*)			# i10: return value
  [[:space:]]*					# any space
  ({|;)							# i11: end of method: opening brace or semi-colon
';

    $this->{MAP_METHOD_WITH_JAVADOC} = {
        javadoc    => 1,
        metadata   => 2,
        access     => 3,
        name       => 6,
        parameters => 9,
        returnType => 10,
        end        => 11,
    };

    $this->{PATTERN_PARAMETER} = '
  (^|...)       # i1: start of string, or rest identifier
  [[:space:]]*  # any space
  (\w+)			# i2: name
  [\s\:]*		# :
  (\w*)			# i3: type
  [\s=]*		# =
  (.*)			# i4: default value
  $				# end of string
  ';

    $this->{PATTERN_PROPERTY_WITH_JAVADOC} = '
  [[:space:]]*					# any space
  (%VISDOC_STUB_JAVADOC_COMMENT_[0-9]+%)*  # i1: javadoc comment
  [[:space:];]*					# any space or semi-colon
  ' . $PATTERN_METADATA . '     # i2: metadata
  [[:space:];]*					# any space or semi-colon
  (								# i3: group total access
  (' . $PATTERN_MEMBER_ACCESS . ')*	# i4: sub-access
  [[:space:]]*					# any space
  (' . $PATTERN_MEMBER_ACCESS . ')*	# i5: sub-access
  )								# /i3
  [[:space:]]*					# any space
  \b(namespace|var|const)\b     # i6: type (namespace/var/const)
  [[:space:]]*					# any space
  ([^\n;]*)                     # i7: name, space, =, value
  ;                             # obligatory semi-colon
  [[:space:]]*					# any space
  (%VISDOC_STUB_JAVADOC_SIDE_[0-9]+%)* # i8: javadoc side comment
  ';

    $this->{MAP_PROPERTY_WITH_JAVADOC} = {
        javadoc         => 1,
        metadata        => 2,
        access          => 3,
        type            => 6,
        nameAndDataType => 7,
        javadocSide     => 8,
    };

    # to help property parsing
    $this->{PATTERN_PROPERTY_SIMPLE_SEMICOLON} = '
  (								# i1: group all up to optional semi-colon
  (								# i2: group total access
  (' . $PATTERN_MEMBER_ACCESS . ')*	# i3: sub-access
  [[:space:]]*					# any space
  (' . $PATTERN_MEMBER_ACCESS . ')*	# i4: sub-access
  )								# /i2
  [[:space:]]*					# any space
  \b(namespace|var|const)\b     # i5: type (namespace/var/const)
  [[:space:]]*					# any space
  (.*?)					        # i6: any char
  )                             # /i1
  (;)*
  (%{VISDOC_STUB_JAVADOC_SIDE[0-9]+}%|;|\n)+						# i8: end of property string
    ';

    $this->{PATTERN_MULTILINE_PROPERTY_OBJECT} = '
    (								# i1: group all up to optional semi-colon
    ' . $PATTERN_METADATA . '      # i2: metadata
    [[:space:];]*				   # any space or semi-colon
    (							   # i3: group total access
    (' . $PATTERN_MEMBER_ACCESS . ')*	   # i4: sub-access
    [[:space:]]*                   # any space
    (' . $PATTERN_MEMBER_ACCESS . ')*     # i5: sub-access
    )							   # /i3
    [[:space:]]*				   # any space
     \b(var|namespace|const)\b  # i6: var or namespace or const
     ([^\n;]+)					# i7: any char except newline or semi-colon
     (;)*						# i8: optional semi-colon
     \s*\=\s*                   # = 
     )                          # /i1
     (                          # i9
     {.*?}		                # {...}
     )                          # /i9
     (;)*						# i10: optional semi-colon
  ';

    $this->{PATTERN_NAME_TYPE_VALUE} = '
     ^
	 ([[:alnum:]_$.]*)              # i1: name
	 [[:space:]]*\:*[[:space:]]*	# :
	 (.*?)				    		# i2: type
	 (                              # i3: group optional value
	 \s*\=\s*					    # =
	 (.*?)	    					# i4: value
	 )*                             # /i3
	 $
	';

    $this->{PATTERN_ARRAY} = '
	\=\s*       # do only convert property values, not meta tags
	(\[.*?\])     # array content
	';

    $this->{PATTERN_INCLUDE} =
      'include[[:space:]]+(%VISDOC_STUB_QUOTED_STRING_[0-9]+%)';

    bless $this, $class;
    return $this;
}

=pod

retrievePackageName( $text ) -> $name

Reads the package name from the text. Text must be clean from comments.
 
=cut

sub retrievePackageName {
    my ( $this, $inText ) = @_;

    my $result = $inText =~ m/$this->{PATTERN_PACKAGE}/x;
    my $name =
      ( $result && $3 )
      ? $3
      : '';

    return $name;
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

=cut

=pod

Defines if a property is a normal var, const, or namespace

=cut

sub _parsePropertyType {
    my ( $this, $inText ) = @_;

    my $type = 0;
    $type |= $VisDoc::MemberData::TYPE->{'CONST'}
      if ( $inText eq 'const' );
    $type |= $VisDoc::MemberData::TYPE->{'NAMESPACE'}
      if ( $inText eq 'namespace' );
    return $type;
}

=pod

_postProcessPackageData( $packageData, $fileData )

Creates an anonymous name if the name has not been set.

=cut

sub _postProcessPackageData {
    my ( $this, $inPackageData, $inFileData ) = @_;

    if ( !$inPackageData->{name} ) {
        $inPackageData->{anonymous} = 1;
        $inPackageData->{name} =
          $this->_getAnonymousPackageName( $inFileData->{path} );
    }
}

=pod

_getAnonymousPackageName( $path ) -> $text

Creates the package name from the path the package is defined in.

=cut

sub _getAnonymousPackageName {
    my ( $this, $inPath ) = @_;

    return undef if !$inPath;

    use File::Spec();
    my ( $volume, $directories, $file ) = File::Spec->splitpath($inPath);
    my $name = VisDoc::StringUtils::deletePathExtension($file);

    return $name;
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
