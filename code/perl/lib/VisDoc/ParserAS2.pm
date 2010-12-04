# See bottom of file for license and copyright information

package VisDoc::ParserAS2;

use base 'VisDoc::ParserBase';
use strict;
use warnings;
use VisDoc::ClassData;
use VisDoc::FileData;
use VisDoc::MemberData;
use VisDoc::MethodData;
use VisDoc::PropertyData;
use VisDoc::MetadataData;

our $ID = 'as2';

### CLASS METHODS ###

=pod

StaticMethod getLanguageId ($fileText) -> $text

Returns the language id if a valid key can be found in the text.

=cut

sub getLanguageId {
    my ($inText) = @_;

    my $text = $inText;
    VisDoc::StringUtils::stripToPrepareReadingLanguageId($text);

    my VisDoc::ParserAS2 $tmp_parser = VisDoc::ParserAS2->new();
    my $pattern = VisDoc::StringUtils::stripCommentsFromRegex(
        $tmp_parser->{PATTERN_PACKAGE} );

    my $result = $text =~ m/$pattern/x;

    # $2 contains the class or interface name
    return $ID if $result && $2;
}

### INSTANCE METHODS ###

sub new {
    my ( $class, $inFileParser ) = @_;

    my VisDoc::ParserAS2 $this = $class->SUPER::new($inFileParser);

    $this->{PATTERN_CLASS_NAME} = '[[:alnum:]_\$\.]+';

    my $PATTERN_METADATA = '
  ((?:\[[^\]]*\][[:space:]]*)*)     # everything between [...] brackets
  ';
  
    $this->{PATTERN_PACKAGE} = '
    \b(class|interface)+\b            # i3: type: "class" or "interface"
    [[:space:]]*						# any space
    (' . $this->{PATTERN_CLASS_NAME} . ')   # i4: class name
    [[:space:]]*						# any space
    ([^{]*)								# i5: superclasses, interfaces: group words in "extends" or "implements"
    [[:space:]]*						# any space
    {									# opening brace
    ';

    $this->{PATTERN_CLASS_LINE_WITH_JAVADOC} = '
  [[:space:]]*						      # any space
  (									      # i1: javadoc comment
  %VISDOC_STUB_JAVADOC_COMMENT_[0-9]+%    # javadoc comment contents
  )*
  [[:space:];]*						      # any space or semi-colon
  ' . $PATTERN_METADATA . '               # i2: metadata
  [[:space:];]*						      # any space or semi-colon
  (dynamic|intrinsic)*	  			      # i3: access
  [[:space:]]*						      # any space
  \b(class|interface)+\b                  # i4: type: "class" or "interface"
  [[:space:]]*						      # any space
  (' . $this->{PATTERN_CLASS_NAME} . ')   # i5: class name
  [[:space:]]*						      # any space
  ([^{]*)							      # i6: superclasses, interfaces: group words in "extends" or "implements"
  [[:space:]]*						      # any space
  {									      # opening brace
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

    my $PATTERN_MEMBER_ACCESS = 'public|private|protected|static';

    $this->{PATTERN_METHOD_NAME} = '[[:alnum:]_\$]+';

    $this->{PATTERN_METHOD_WITH_JAVADOC} = '
  [[:space:]]*						# any space
  (%VISDOC_STUB_JAVADOC_COMMENT_[0-9]+%)*  # i1: javadoc comment
  [[:space:];]*					# any space or semi-colon
  ' . $PATTERN_METADATA . '     # i2: metadata
  [[:space:];]*					# any space or semi-colon  
  (								# i3: group total access
  (' . $PATTERN_MEMBER_ACCESS . ')*	# sub-access
  [[:space:]]*					# any space
  (' . $PATTERN_MEMBER_ACCESS . ')*	# sub-access
  )								# 
  [[:space:]]*					# any space
  \bfunction\b
  [[:space:]]*					# any space
  (								# i6: group getset and name
  (get|set)*					# i7: get or set accessor
  [[:space:]]*					# any space
  (' . $this->{PATTERN_METHOD_NAME} . ')  # name at index 8
  )
  [[:space:]]*					# any space
  \(							# start of parameter list
  (								# i9: group parameters
  [^\)]*						# parameter chars: any char that is not ")"
  )								# end parameters
  \)							# end of parameter list
  [[:space:]\:]*				# spaces or a colon
  ([[:alnum:]\.\*]*)			# i10: return value
  [[:space:]]*					# any space
  ({|;)							# end of method: opening brace or semi-colon in interfaces at index 10
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
  \b(var)\b                     # i6: type (var)
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
  \b(var)\b                     # i5: type (var)
  [[:space:]]*					# any space
  (.*?)					        # i6: any char
  )                             # /i1
  (;)*
  (%VISDOC_STUB_JAVADOC_SIDE{[0-9]+}%|;|\n)+						# i8: end of property string
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
     \b(var)\b                     # i6: var
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
	 (.*?)						    # i2: type
	 (                              # i3: group optional value
	 \s*\=\s*			    		# =
	 (.*?)					    	# i4: value
	 )*                             # /i3
	 $
	';

    $this->{PATTERN_ARRAY} = '
	\=\s*       # do only convert property values, not meta tags
	(\[.*?\])     # array content
	';

    $this->{PATTERN_INCLUDE} =
      '#include[[:space:]]+(%VISDOC_STUB_QUOTED_STRING_[0-9]+%)';

    bless $this, $class;
    return $this;
}

=pod

retrievePackageName($text) -> $name

Reads the package name from the text. Assumes the text is clean from comments.

ActionScript 2.0 does not have explicit packages; package names are written in the class name.
 
=cut

sub retrievePackageName {
    my ( $this, $inText ) = @_;

    my $name = '';
    local $_ = $inText;
    if (/$this->{PATTERN_CLASS_LINE_WITH_JAVADOC}/gx) {

        # name
        my $i = $this->{MAP_CLASS_LINE_WITH_JAVADOC}->{name};
        if ( $-[$i] ) {
            $name = substr( $_, $-[$i], $+[$i] - $-[$i] );
        }
    }
    ( my $classpath = $name ) =~ s/^(.*?)\.\w+$/$1/x;
    $classpath = '' if $classpath eq $name;
    return $classpath;
}

=pod

resolveIncludes( $text ) -> $text

Adds included files to the text.

=cut

sub resolveIncludes {
    my ( $this, $inText ) = @_;

    my $text = $inText;

    $text =~ s/$this->{PATTERN_INCLUDE}/$this->_includeFile($1)/ge;

    return $text;
}

sub _parseMembers {
    my ( $this, $inText ) = @_;

    my $text = $inText;

    ( $text, my $methods ) =
      $this->_parseMethods($text);    # objects of type MethodData
    $text = $this->_preparePropertyParsing($text);
    ( $text, my $properties ) =
      $this->_parseProperties($text);    # objects of type PropertyData

    @{$methods}    = () if !$methods;
    @{$properties} = () if !$properties;

    $this->_combineGetSetters($methods);
    $this->_setMemberOrder( $text, $methods, $properties );
    $this->_swapPropertyGetSetters( $methods, $properties );
    $this->_setReadWriteForProperties($properties);

    return ( $methods, $properties, $text );
}

=pod

_combineGetSetters( \@methods )

Combines get and set methods.

=cut

sub _combineGetSetters {
    my ( $this, $inMethods ) = @_;

    my $getters;
    my $setters;

    foreach my $method ( @{$inMethods} ) {

        $getters->{ $method->{name} } = $method
          if ( $method->{type}
            && $method->{type} == $VisDoc::MemberData::TYPE->{'READ'} );

        $setters->{ $method->{name} } = $method
          if ( $method->{type}
            && $method->{type} == $VisDoc::MemberData::TYPE->{'WRITE'} );

    }

    while ( my ( $name, $method ) = each %{$getters} ) {

        # check if corresponding setter exists
        my $setter = $setters->{$name};
        if ($setter) {
            my $setterParams = $setter->{parameters};
            if (   $setterParams
                && $setterParams->[0]->{dataType} eq $method->{returnType} )
            {

                # change type to both read and write
                $method->{type} =
                  $VisDoc::MemberData::TYPE->{'READ'} |
                  $VisDoc::MemberData::TYPE->{'WRITE'};

                # copy return type
                $method->{dataType} = $setterParams->[0]->{dataType};

                # merge javadoc
                if ( $setter->{javadoc} ) {
					if ( $method->{javadoc} ) {
	                    $method->{javadoc}->merge( $setter->{javadoc} );
	                } else {
	                    $method->{javadoc} = $setter->{javadoc};
	                }
                }

                # delete setter
                undef $setters->{$name};

                # delete setter in original list
                @{$inMethods} =
                  grep { $_->{_id} != $setter->{_id} } @{$inMethods};
            }
        }
    }
}

=pod

_swapPropertyGetSetters( \@methods, \@properties)

Moves property getters and setters from the methods list to the property list.

=cut

sub _swapPropertyGetSetters {
    my ( $this, $inMethods, $inProperties ) = @_;

    my $count = 0;
    foreach my $method ( @{$inMethods} ) {
        if ( $method->{type} && (
            $method->{type} & $VisDoc::MemberData::TYPE->{'READ'}
                || $method->{type} & $VisDoc::MemberData::TYPE->{'WRITE'} )
          )
        {

            # create new property
            my $propertyData = VisDoc::PropertyData->new();
            $propertyData->{type}           = $method->{type};
            $propertyData->{memberOrder}    = $method->{memberOrder};
            $propertyData->{name}           = $method->{name};
            $propertyData->{qualifiedName}  = $method->{qualifiedName};
            $propertyData->{access}         = $method->{access};            
            $propertyData->{isAccessPublic} = $method->{isAccessPublic};
            $propertyData->{javadoc}        = $method->{javadoc};
            $propertyData->{metadata}       = $method->{metadata};
            $propertyData->{parameters}     = $method->{parameters};

            $propertyData->{dataType} ||= $method->{returnType}
              if ( $method->{type} & $VisDoc::MemberData::TYPE->{'READ'} );
            $propertyData->{dataType} ||= $method->{parameters}->[0]->{dataType}
              if ( $method->{type} & $VisDoc::MemberData::TYPE->{'WRITE'} );
            $propertyData->{dataType} ||= $method->{dataType};

            push @{$inProperties}, $propertyData;
            $method->{_delete} = 1;
        }
        $count++;
    }

	# delete setter in original list
    @{$inMethods} = grep { !$_->{_delete} } @{$inMethods};

    # sort properties
    if ( $inProperties && scalar @{$inProperties} ) {
        @{$inProperties} =
          sort { $a->{memberOrder} <=> $b->{memberOrder} } @{$inProperties};
    }
}

sub _setReadWriteForProperties {
    my ( $this, $inProperties ) = @_;

    foreach my $property ( @{$inProperties} ) {
        $property->{type} ||=
          $VisDoc::MemberData::TYPE->{'READ'} |
          $VisDoc::MemberData::TYPE->{'WRITE'};
    }
}

sub _includeFile {
    my ( $this, $inFileStub ) = @_;

    my $includeFileName = $this->{fileParser}->getContents($inFileStub);

    $includeFileName =~ s/^\"(.*?)\"$/$1/;

    my $baseFilePath = $this->{fileParser}->{data}->{path};

    # append the filename to the path
    use File::Spec;
    my ( $volume, $directories, $file ) = File::Spec->splitpath($baseFilePath);
    my $includePath =
      File::Spec->catpath( $volume, $directories, $includeFileName );

    my $text = VisDoc::readFile( $includePath, 'Trying to include file.' );
    return $text;
}

=pod

_isPublic( \@access ) -> $bool

Checks access list if class or member is public.

=cut

sub _isPublic {
    my ( $this, $inAccess ) = @_;

    my %access = map { $_ => 1 } @{$inAccess};
    my $isPublic = 1;    # default

    $isPublic = 0 if ( $access{private} || $access{protected} );

    return $isPublic;
}

=pod

_handleMethodMatches (@matches, \@methods, $patternMap) -> (\@methodData, $lastChar)

=cut

sub _handleMethodMatches {
    my ( $this, $inMatches, $inMethods, $inPatternMap ) = @_;

    my $i;    # match index

    my VisDoc::MethodData $data = VisDoc::MethodData->new();
    push @{$inMethods}, $data;

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

    # metadata
    $i = $inPatternMap->{metadata} - 1;
    if ( $inMatches->[$i] && $inMatches->[$i] ) {
        my $metadata = $inMatches->[$i];
        $data->{metadata} = $this->_parseMetadataData($metadata);
    }

    # access
    $i = $inPatternMap->{access} - 1;
    if ( $inMatches->[$i] && $inMatches->[$i] ) {
        my $accessStr = $inMatches->[$i];
        if ($accessStr) {
            my @access = $this->_parseMemberAccess($accessStr);
            $data->{access}         = \@access;
        }
    }
	$data->{isAccessPublic} = $this->_isPublic( $data->{access} );

    # type: read or write
    $i = $inPatternMap->{name} - 1;    # beware: type is parsed from name
    if ( $inMatches->[$i] && $inMatches->[$i] ) {
        my $typeStr = $inMatches->[$i];
        $data->{type} = $this->_parseMethodType($typeStr);
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

    # return type
    $i = $inPatternMap->{returnType} - 1;
    if ( $inMatches->[$i] && $inMatches->[$i] ) {
        my $returnTypeStr = $inMatches->[$i];
        $data->{returnType} = $this->_parseMethodReturnType($returnTypeStr);
    }

    # last char
    my $lastChar = '';
    $i = $inPatternMap->{end} - 1;
    if ( $inMatches->[$i] && $inMatches->[$i] ) {
        $lastChar = $inMatches->[$i];
    }

    return ( $inMethods, $lastChar );
}

=pod

_parseMethodType($text) -> $type

ActionScript only: property can be defined as 'read' or 'write' method. For instance: 

	public function get a () : Number {
		return mA;
	}

... defines a property 'a' that can be read.

=cut

sub _parseMethodType {
    my ( $this, $inText ) = @_;

    # trim spaces
    my $rawType = $inText;
    VisDoc::StringUtils::trimSpaces($rawType);

    my $getset = $rawType =~ m/^(get|set)+[[:space:]]+(\w+)$/x;
    if ( $getset && $1 ) {
        return $VisDoc::MemberData::TYPE->{'READ'}  if ( $1 eq 'get' );
        return $VisDoc::MemberData::TYPE->{'WRITE'} if ( $1 eq 'set' );
    }
    return undef;
}

=pod

_parseMethodName($text) -> $name

=cut

sub _parseMethodName {
    my ( $this, $inText ) = @_;

    # trim spaces
    my $rawName = $inText;
    VisDoc::StringUtils::trimSpaces($rawName);

    my $getset = $rawName =~ m/^(get|set)+[[:space:]]+(\w+)$/x;
    return $2 if $getset;
    return $rawName;
}

=pod

_parseMethodParameterData( \@list ) -> \@parameterData

Creates a list of ParameterData objects, read from a list of parameter strings.

=cut

sub _parseMethodParameterData {
    my ( $this, $inList ) = @_;

    my @parameterDataList;

    foreach my $paramString ( @{$inList} ) {
        my ( $varArgs, $name, $dataType, $defaultValue ) =
          $paramString =~ m/$this->{PATTERN_PARAMETER}/x;
        my VisDoc::ParameterData $paramData =
          VisDoc::ParameterData->new( $varArgs, $name, $dataType,
            $defaultValue );
        push( @parameterDataList, $paramData );
    }
    return \@parameterDataList;
}

=pod

_parseMetadataData( $text ) -> \@metadataList

=cut

sub _parseMetadataData {
    my ( $this, $inText ) = @_;

    my @metadataList = ();
    my $text         = $this->{fileParser}->getContents($inText);

    local $_ = $text;

    while (/$this->{PATTERN_METADATA_CONTENTS}/gsx) {
        my ( $noContentName, $name, $contents ) = ( $1, $2, $3 );
        
        my @items;
        @items =
          VisDoc::StringUtils::commaSeparatedListFromCommaSeparatedString(
            $contents) if $contents;

        my @metaContent = ();
        foreach my $item (@items) {
            $item =~ m/$this->{PATTERN_KEY_IS_VALUE}/x;
            my $key = $2;
            $key ||= $VisDoc::MetadataData::NO_KEY;
            my $value = $3;
            push( @metaContent, { $key => $value } );
        }
        my VisDoc::MetadataData $metadata =
          VisDoc::MetadataData->new( $name || $noContentName, \@metaContent );
        push( @metadataList, $metadata );
    }
    return \@metadataList;
}

=pod

=cut

sub _preparePropertyParsing {
    my ( $this, $inText ) = @_;

    my $pattern = $this->{PATTERN_MULTILINE_PROPERTY_OBJECT};

    my $text = $inText;
    $text =~ s/$pattern/$this->_stubObjectProperties($1,$9,$10)/gsex;

    $text = $this->{fileParser}->stubArrays( $text, $this->{PATTERN_ARRAY}, 1 );
    $text = $this->_putSemicolonsAfterPropertyLines($text);
    $text = $this->_splitOutCombinedAssignments($text);
    $text =~ s/$VisDoc::StringUtils::STUB_SPACE/ /go;
    return $text;
}

=pod

_splitOutCombinedAssignments( $text ) -> $text

Takes the entire text and finds properties that have combined assignments, like:

	private var chimpansee:Number = 10, elephant:Number = 20, tiger:Number = 30;
	
to create separate Property objects.

=cut

sub _splitOutCombinedAssignments {
    my ( $this, $inText ) = @_;
	
    my $pattern    = $this->{PATTERN_PROPERTY_WITH_JAVADOC};
    my $patternMap = $this->{MAP_PROPERTY_WITH_JAVADOC};

    my $text = $inText;
    local $_ = $text;
    my @matches = m/($pattern)/sox;

    if ( scalar @matches ) {
        my $stub =
          $this->_copyAttributesOfCombinedAssignments( \@matches, $patternMap );

        # prepare the fetching and removal of property string
        my $startLoc = $-[0] || 0;
        my $endLoc = $+[0] || $-[0] || 0;

        # remove method declaration plus contents from text

        my $stripped =
          substr( $text, $startLoc, $endLoc - $startLoc, "$stub\n" );

        $text = $this->_splitOutCombinedAssignments($text);
    }
    return $text;
}

=pod

=cut

sub _copyAttributesOfCombinedAssignments {
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

    # type
    my $typeStr = '';
    $i = $inPatternMap->{type};
    if ( $inMatches->[$i] && $inMatches->[$i] ) {
        $typeStr = $inMatches->[$i];
    }

    # access
    my $accessStr = '';
    $i = $inPatternMap->{access};
    if ( $inMatches->[$i] && $inMatches->[$i] ) {
        $accessStr = $inMatches->[$i];
    }

    # nameAndDataType
        $i = $inPatternMap->{nameAndDataType};
    if ( $inMatches->[$i] && $inMatches->[$i] ) {
        my $valueStr = $inMatches->[$i];
        if ( $valueStr ne '' ) {

        	# protect method params
        	my $paramStubs;
        	my $paramStubCounter = 0;
        	my $substituteParamStub = sub {
        		my ($orgString) = @_;
        		$paramStubs->{$paramStubCounter} = $orgString;
        		return '%TMP_VISDOC_PARAM_STUB_' . $paramStubCounter++ . '%';
        	};
        	while ( $valueStr =~ s/(\=\s*new\s(.*?)\s*(\(.*?\)))/&$substituteParamStub($1)/ge ) {};
        
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
                    $text .= $typeStr        ? " $typeStr "         : '';
                    $text .= $otherValue;
                    $text .= ';';
                    $text .= $javadocSideStr ? " $javadocSideStr\n" : '';
                    $text .= "\n\n";
                }
            }
            
            if ($paramStubs) {
            	$text =~ s/%TMP_VISDOC_PARAM_STUB_([0-9]+)%/$paramStubs->{$1}/g;
            }
        }
    }

    # prevent infinite recursion:
    $text =~ s/( |\t)/$VisDoc::StringUtils::STUB_SPACE/go;
    return $text;
}

=pod

_putSemicolonsAfterPropertyLines( $text ) -> $text

'Repairs' property statements by adding a ; char at the end of the line.

=cut

sub _putSemicolonsAfterPropertyLines {
    my ( $this, $inText ) = @_;

    my $text = $inText;

    my $pattern = $this->{PATTERN_PROPERTY_SIMPLE_SEMICOLON};

    # use a stub to easy remove double semi-colons
    $text =~ s/$pattern/$1VISDOC_STUB_SEMI_COLON$8/gsx;
    $text =~ s/;*VISDOC_STUB_SEMI_COLON;*/;/gsx;

    return $text;
}

=pod

=cut

sub _handlePropertyMatches {
    my ( $this, $inMatches, $inProperties, $inPatternMap ) = @_;

    my VisDoc::PropertyData $data = VisDoc::PropertyData->new();
    push @{$inProperties}, $data;

    # set properties
    my $i;    # match index

    # property nameAndDataType
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
        my $javadocSideStub = $inMatches->[$i];
        my $javadoc = $this->{fileParser}->parseJavadoc($javadocSideStub);
        $data->setJavadoc($javadoc);
    }

    # metadata
    $i = $inPatternMap->{metadata} - 1;
    if ( $inMatches->[$i] && $inMatches->[$i] ) {
        my $metadataStr = $inMatches->[$i];
        $data->{metadata} = $this->_parseMetadataData($metadataStr);
    }

    # access
    $i = $inPatternMap->{access} - 1;
    if ( $inMatches->[$i] && $inMatches->[$i] ) {
        my $accessStr = $inMatches->[$i];
        if ($accessStr) {
            my @access = $this->_parseMemberAccess($accessStr);
            $data->{access}         = \@access;
        }
    }
	$data->{isAccessPublic} = $this->_isPublic( $data->{access} );

    # type
    $i = $inPatternMap->{type} - 1;
    if ( $inMatches->[$i] && $inMatches->[$i] ) {
        my $typeStr = $inMatches->[$i];
        $data->{type} = $this->_parsePropertyType($typeStr);
    }

    # name
    $i = $inPatternMap->{nameAndDataType} - 1;
    if ( $inMatches->[$i] && $inMatches->[$i] ) {
        my $nameStr = $inMatches->[$i];
        $data->{name} = $this->_parsePropertyName($nameStr);
    }

    # data type
    $i = $inPatternMap->{nameAndDataType} - 1;
    if ( $inMatches->[$i] && $inMatches->[$i] ) {
        my $dataTypeStr = $inMatches->[$i];
        $data->{dataType} = $this->_parsePropertyDataType($dataTypeStr);
    }

    # value
    $i = $inPatternMap->{nameAndDataType} - 1;
    if ( $inMatches->[$i] && $inMatches->[$i] ) {
        my $valueStr = $inMatches->[$i];
        $data->{value} = $this->_parsePropertyValue($valueStr);
    }

    return $inProperties;
}

=pod

_parsePropertyName($text) -> $name

=cut

sub _parsePropertyName {
    my ( $this, $inText ) = @_;

    my $pattern = $this->{PATTERN_NAME_TYPE_VALUE};
    if ( $inText =~ m/$pattern/x ) {
        return $this->{fileParser}->getContents($1);
    }
    return '';
}

=pod

_parsePropertyDataType($text) -> $type

=cut

sub _parsePropertyDataType {
    my ( $this, $inText ) = @_;

    my $pattern = $this->{PATTERN_NAME_TYPE_VALUE};
    if ( $inText =~ m/$pattern/x ) {
        return $this->{fileParser}->getContents($2);
    }
    return '';
}

=pod

_parsePropertyValue($text) -> $text

=cut

sub _parsePropertyValue {
    my ( $this, $inText ) = @_;

    my $pattern = $this->{PATTERN_NAME_TYPE_VALUE};
    if ( $inText =~ m/$pattern/x ) {
        return $this->{fileParser}->getContents($4);
    }
    return '';
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
