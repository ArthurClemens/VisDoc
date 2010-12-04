# See bottom of file for license and copyright information

package VisDoc::ParserBase;

use strict;
use warnings;
use VisDoc::StringUtils;
use VisDoc::ClassData;
use VisDoc::MemberData;
use VisDoc::MethodData;
use VisDoc::PropertyData;
use VisDoc::PackageData;
use VisDoc::ParameterData;

#use Scalar::Util qw(refaddr);    # for testing object equality

# implemented by subclasses:
our $ID = '';

=pod

=cut

sub getLanguageId {
    my ($inText) = @_;

    return $VisDoc::Defaults::NOT_IMPLEMENTED;
}

### INSTANCE MEMBERS ###

=pod

=cut

sub new {
    my ( $class, $inFileParser ) = @_;
    my $this = {};
    $this->{fileParser} =
      $inFileParser;    # ref to FileParser object (that owns all string stubs)

    $this->{PATTERN_PACKAGE}                   = '';
    $this->{PATTERN_CLASS_NAME}                = '';
    $this->{PATTERN_METHOD_NAME}               = '';
    $this->{PATTERN_CLASS_LINE_WITH_JAVADOC}   = '';
    $this->{MAP_CLASS_LINE_WITH_JAVADOC}       = '';
    $this->{PATTERN_METADATA_CONTENTS}         = '';
    $this->{PATTERN_KEY_IS_VALUE}              = '';
    $this->{PATTERN_METHOD_WITH_JAVADOC}       = '';
    $this->{MAP_METHOD_WITH_JAVADOC}           = undef;
    $this->{PATTERN_PARAMETER}                 = '';
    $this->{PATTERN_PROPERTY_WITH_JAVADOC}     = '';
    $this->{MAP_PROPERTY_WITH_JAVADOC}         = undef;
    $this->{PATTERN_MULTILINE_PROPERTY_OBJECT} = '';
    $this->{PATTERN_NAME_TYPE_VALUE}           = '';
    $this->{PATTERN_ARRAY}                     = '';
    $this->{PATTERN_INCLUDE}                   = '';

    bless $this, $class;
    return $this;
}

=pod

parseClasses($text) -> (\@classData, $text)

=cut

sub parseClasses {
    my ( $this, $inText ) = @_;

    my ( $classes, $text ) = $this->_parseClasses($inText);
    $this->{classes} = $classes;
    return ( $classes, $text );
}

=pod

resolveIncludes( $text ) -> $text

Adds included files to the text.
 
To be implemented by subclasses.

=cut

sub resolveIncludes {
    my ( $this, $inText ) = @_;
    return $inText;
}

=pod

retrievePackageName( $text ) -> $name

Reads the package name from the text. Text must be clean from comments.
 
To be implemented by subclasses.

=cut

sub retrievePackageName {
    my ( $this, $inText ) = @_;

    return $VisDoc::Defaults::NOT_IMPLEMENTED;
}

sub composeClasspath {
    my ( $this, $inPackage, $inClassName ) = @_;

    my @components = ();
    push( @components, $inPackage )   if $inPackage;
    push( @components, $inClassName ) if $inClassName;
    return '' if !scalar @components;
    return join( ".", @components );
}

=pod

parsePackage($fileData, $text, $languageId, \@classes) -> $packageData

=cut

sub parsePackage {
    my ( $this, $inFileData, $inText, $inLanguageId, $inClasses ) = @_;

    # create storage object
    my VisDoc::PackageData $packageData = VisDoc::PackageData->new();
    $packageData->{classes} = $inClasses;

    my $javadocStub = $this->_getPackageJavadocString($inText);
    if ($javadocStub) {
        my $javadoc = $this->{fileParser}->parseJavadoc($javadocStub);
        $packageData->{javadoc} = $javadoc;
    }

    my $packageName = $this->retrievePackageName($inText);
	if (!$packageName) {
		$packageName = $packageData->{classes}->[0]->{classpath};
		# remove class name from classpath
		$packageName = VisDoc::StringUtils::deletePathExtension($packageName);
	}
    $packageData->{name} = $packageName;

    my ( $functions, $properties, $text ) = $this->_parseMembers($inText);
    $packageData->{functions} = $functions;

    $this->_postProcessPackageData( $packageData, $inFileData );

    return $packageData;
}

=pod

_getPackageJavadocString( $text ) -> $javadocStub

=cut

sub _getPackageJavadocString {
    my ( $this, $inText ) = @_;

    my $javadocStub    = '';
    my $packagePattern = $this->{PATTERN_PACKAGE};

    return '' if !$packagePattern;
    my $result = $inText =~ m/$packagePattern/x;
    $javadocStub = $1 if $result && $1;

    return $javadocStub;
}

=pod

_isPublic( \@access ) -> $bool

Checks access list if class or member is public.
To be implemented by subclasses.

=cut

sub _isPublic {
    my ( $this, $inAccess ) = @_;

    return 0;
}

=pod

_parseClasses() -> \@classData

=cut

sub _parseClasses {
    my ( $this, $inText ) = @_;

    my ( $text, $classes ) = $this->_parseClassData($inText);

    foreach my $classData (@$classes) {

        $this->_postProcessClassData($classData);

        my $classText = $classData->{working_contents};

        # dispose of temporary class text
        delete $classData->{working_contents};
        my ( $methods, $properties, $text ) = $this->_parseMembers($classText);

        $this->_postProcessMethodData( $classData, $methods );
        $this->_postProcessPropertyData( $classData, $properties );

        $classData->{methods}    = $methods;
        $classData->{properties} = $properties;
    }
    return ( $classes, $text );
}

=pod

_parseClassData($text, \$outerClassData, \@classes) -> ($text, \@classData)

=cut

sub _parseClassData {
    my ( $this, $inText, $inOuterClass, $inClasses ) = @_;

    # pass classes if called recursively
    my $classes = $inClasses;

    my ( $pattern, $patternMap ) = $this->_getParseClassRegexData();

    my $text = $inText;
    local $_ = $text;
    my @matches = /$pattern/x;

    if ( scalar @matches ) {
        my $lastChar = '';
        ( $classes, my $data ) =
          $this->_handleClassMatches( \@matches, $classes, $patternMap );

        # enclosingClass
        if ($inOuterClass) {
            $data->{enclosingClass} = $inOuterClass;
            $data->{isInnerClass}   = 1;

            # also set inner class
            push @{ $inOuterClass->{innerClasses} }, $data;

            # set classpath
            $data->{classpath} =
              $this->composeClasspath( $inOuterClass->{packageName},
                $data->{name} );
        }
        else {

            # set class package
            my $package = $this->retrievePackageName($text);
            $data->{packageName} = $package;
            $data->{classpath} =
              $this->_createClasspath( $package, $data->{name} );
        }

        # super classpaths
        if ( $data->{superclasses} ) {
            map {
                $_->{classpath} =
                  $this->_getClasspathFromImports( $_->{name}, $inText );
            } @{ $data->{superclasses} };
        }

        # interfaces classpaths
        if ( $data->{interfaces} ) {
            map {
                if ( !( $_->{classpath} ) )
                {
                    $_->{classpath} =
                      $this->_getClasspathFromImports( $_->{name}, $inText );
                }
            } @{ $data->{interfaces} };
        }

        # prepare the fetching and removal of class contents
        my $startLoc = $-[0];
        my $endLoc =
             $+[0]
          || $-[0]
          || 0;    # default, in case the method string does not have braces
        pos = $startLoc;    # start from beginning of match

        use Regexp::Common qw( RE_balanced );
        my $balanced = RE_balanced( -parens => '{}', -keep );
        if (/$balanced/gcosx) {
            my $contents = $1;

            # clean up
            $contents =~ s/^{[[:space:]]*(.*?)[[:space:]]*}$/$1/s;

            $data->{working_contents} = $contents;

            # remove class contents from text
            my $stripped = substr( $text, $startLoc, pos() - $startLoc,
                "\nVISDOC_STRIPPED_CLASS" );

            # parse class contents
            my ( $text, $classes ) =
              $this->_parseClassData( $contents, $data, $classes );
        }

        # repeat parsing in case there is next class at the same level
        ( $text, $classes ) =
          $this->_parseClassData( $text, $inOuterClass, $classes );
    }
    return ( $text, $classes );
}

=pod

=cut

sub _createClasspath {
    my ( $this, $inPackageName, $inClassName ) = @_;

    my @components = ();
    push( @components, $inPackageName ) if $inPackageName;
    push( @components, $inClassName )   if $inClassName;

    return join( '.', @components );
}

=pod

_handleClassMatches (@matches, \@classes, $patternMap) -> (\@classData, $classData)

=cut

sub _handleClassMatches {
    my ( $this, $inMatches, $inClasses, $inPatternMap ) = @_;

    my VisDoc::ClassData $classData = VisDoc::ClassData->new();
    push @{$inClasses}, $classData;

    my $data = $classData;

    # set properties

    my $i;    # match index

    # javadoc
    $i = $inPatternMap->{javadoc} - 1;
    if ( $inMatches->[$i] ) {

        $data->{javadoc} =
          $this->{fileParser}->parseJavadoc( $inMatches->[$i] );
    }

    # metadata
    if ($inPatternMap->{metadata}) {
		$i = $inPatternMap->{metadata} - 1;
		if ( $inMatches->[$i] && $inMatches->[$i] ) {
			my $metadata = $inMatches->[$i];
			$data->{metadata} = $this->_parseMetadataData($metadata);
		}
	}
	
    # access
    $i = $inPatternMap->{access} - 1;
    if ( $inMatches->[$i] ) {
        my $accessStr = $inMatches->[$i];
        if ($accessStr) {
            my @access = $this->_parseClassAccess($accessStr);
            $data->{access} = \@access if scalar @access;
        }
    }
    $data->{isAccessPublic} = $this->_isPublic( $data->{access} );

    # type
    $i = $inPatternMap->{type} - 1;
    if ( $inMatches->[$i] ) {
        my $typeStr = $inMatches->[$i];
        $data->{type} = $VisDoc::ClassData::TYPE->{'CLASS'}
          if $typeStr eq 'class';
        $data->{type} = $VisDoc::ClassData::TYPE->{'INTERFACE'}
          if $typeStr eq 'interface';
    }

    # name
    $i = $inPatternMap->{name} - 1;
    if ( $inMatches->[$i] ) {
        my $nameStr = $inMatches->[$i];
        $data->{name} = $this->_parseClassName($nameStr);
    }

    # superclasses
    $i = $inPatternMap->{superclasses} - 1;
    if ( $inMatches->[$i] ) {
        my $superclassesStr = $inMatches->[$i];
        my $superclassNames = $this->_parseSuperclassNames($superclassesStr);
        $data->setSuperclassNames($superclassNames);
    }

    # interfaces
    $i = $inPatternMap->{interfaces} - 1;
    if ( $inMatches->[$i] ) {
        my $interfacesStr  = $inMatches->[$i];
        my $interfaceNames = $this->_parseInterfaceNames($interfacesStr);
        $data->setInterfaceNames($interfaceNames);
    }

    return ( $inClasses, $data );
}

=pod

To be implemented by subclasses.

_getParseClassRegexData() -> ($pattern, \%patternMap)

Returns a tuple with
	- class pattern
	- reference to hash with keys/values:
		class_definition_part => pattern_index

=cut

sub _getParseClassRegexData {
    my ($this) = @_;

    return (
        $this->{PATTERN_CLASS_LINE_WITH_JAVADOC},
        $this->{MAP_CLASS_LINE_WITH_JAVADOC}
    );
}

=pod

_parseSuperclassNames($text) -> \@names

Returns a list of superclass names from a string with (optionally) multiple values separated by commas.

=cut

sub _parseSuperclassNames {
    my ( $this, $inText ) = @_;

    my @names =
      VisDoc::StringUtils::listFromKeywordWithCommaDelimitedString( $inText,
        'extends' );
    return \@names;
}

=pod

_getClasspathFromImports( $className, $text ) -> $text

Returns the classpath for the class $className as written after 'import'.
Happens to be the same for as2, as3 and java.

=cut

sub _getClasspathFromImports {
    my ( $this, $inClassName, $inText ) = @_;

    my $pattern = "import[[:space:]]+([^;]*\\b$inClassName\\b)";
    if ( $inText =~ m/$pattern/ ) {
        return $1;
    }
    return undef;
}

=pod

_parseInterfaceNames($text) -> \@names

Returns a list of interfaces from a string with (optionally) multiple values separated by commas.

=cut

sub _parseInterfaceNames {
    my ( $this, $inText ) = @_;

    my @names =
      VisDoc::StringUtils::listFromKeywordWithCommaDelimitedString( $inText,
        'implements' );
    return \@names;
}

=pod

_parseClassAccess($text) -> @list

Returns a list of access keywords from a string with (optionally) multiple values separated by commas.

=cut

sub _parseClassAccess {
    my ( $this, $inText ) = @_;

    # strip spaces
    my $text = $inText;
    VisDoc::StringUtils::trimSpaces($text);

    my @list =
      VisDoc::StringUtils::commaSeparatedListFromSpaceSeparatedString($text);

    return @list;
}

=pod

_parseClassName($text) -> $name

=cut

sub _parseClassName {
    my ( $this, $inText ) = @_;

    # strip spaces
    my $text = $inText;
    VisDoc::StringUtils::trimSpaces($text);

    my @components = split( /\./, $text );
    my $name = $components[ scalar @components - 1 ] || $text;

    return $name;
}

sub _parseMembers {
    my ( $this, $inText ) = @_;

    my $text = $inText;

    ( $text, my $methods ) =
      $this->_parseMethods($text);    # objects of type MethodData
    $text = $this->_preparePropertyParsing($text);
    ( $text, my $properties ) =
      $this->_parseProperties($text);    # objects of type PropertyData

    $this->_setMemberOrder( $text, $methods, $properties );

    return ( $methods, $properties, $text );
}

=pod

_setMemberOrder( $text, \@methods, \@properties)

Assigns a unique and incrementing 'memberOrder' id to each member, based on the order of the remainging text stubs STRIPPED_PROPERTY_0 and STRIPPED_METHOD_0.
The member order will later be used in output listings.

=cut

sub _setMemberOrder {
    my ( $this, $inText, $inMethods, $inProperties ) = @_;

    my $pattern = 'STRIPPED_(PROPERTY|METHOD)_([0-9]+)';

    local $_ = $inText;
    my $memberOrder = 0;
    while ( $inText =~ m/$pattern/xg ) {
        my $type = $1;
        my $id   = $2;
        my $member;
        if ( $type eq 'PROPERTY' ) {
            $member = $this->_getMemberWithId( $inProperties, $id );
        }
        elsif ( $type eq 'METHOD' ) {
            $member = $this->_getMemberWithId( $inMethods, $id );
        }
        if ($member) {
            $member->{memberOrder} = $memberOrder++;
        }
    }
}

=pod

_getMemberWithId( \@collection, $id ) -> $methodData or $propertyData

=cut

sub _getMemberWithId {
    my ( $this, $inCollection, $inId ) = @_;

    foreach my $member ( @{$inCollection} ) {
        if ( $member->{_id} eq $inId ) {
            return $member;
        }
    }
}

=pod

_parseMethods($text, \@methods) -> ($text, \@memberData)

=cut

sub _parseMethods {
    my ( $this, $inText, $inMethods ) = @_;

    my $pattern    = $this->{PATTERN_METHOD_WITH_JAVADOC};
    my $patternMap = $this->{MAP_METHOD_WITH_JAVADOC};

    my $text = $inText;

    use re 'eval';    # to be able to use Eval-group in pattern

	while ($text =~ m/$pattern/sx) {
		local $_ = $text;

		my @matches = $text =~ /$pattern/sx;
		
		if ( scalar @matches ) {

			my $lastChar = '';
			( $inMethods, $lastChar ) =
			  $this->_handleMethodMatches( \@matches, $inMethods, $patternMap );
	
			# prepare the fetching and removal of method string
			my $startLoc = $-[0];
			my $endLoc =
				 $+[0]
			  || $-[0]
			  || 0;    # default, in case the method string does not have braces
			pos = $startLoc;    # start from beginning of match
			
			# method declaration or definition?
			# method declaration strings end on '{'
			if ( $lastChar eq '{' ) {
				use Regexp::Common qw( RE_balanced );
				my $balanced = RE_balanced( -parens => '{}', -keep );
				if (/$balanced/gcosx) {
					$endLoc = pos();
				}
			}
	
			# remove method declaration plus contents from text
			# add semi-colon because this is eaten by regex
			my $order    = scalar @{$inMethods} - 1;
			my $stripped = substr(
				$text, $startLoc,
				$endLoc - $startLoc,
				"; STRIPPED_METHOD_$order\n"
			);
	
			die(
	"Infinite recursion while parsing:$inText\nPlease check the syntax of this code."
			) if ( $text eq $inText );
	
		}
    }
    return ( $text, $inMethods );
}

=pod

_handleMethodMatches (@matches, \@methods, $patternMap) -> (\@methodData, $lastChar)

To be implemented by subclasses

=cut

sub _handleMethodMatches {
    my ( $this, $inMatches, $inMethods, $inPatternMap ) = @_;

    return ( undef, undef );
}

=pod

_parseMemberAccess($text) -> @list

Returns a list of access keywords from a string with (optionally) multiple values separated by commas.

=cut

sub _parseMemberAccess {
    my ( $this, $inText ) = @_;

    # strip spaces
    my $text = $inText;
    VisDoc::StringUtils::trimSpaces($text);

    my @list =
      VisDoc::StringUtils::commaSeparatedListFromSpaceSeparatedString($text);
    return @list;
}

=pod

_parseMethodName($text) -> $name

=cut

sub _parseMethodName {
    my ( $this, $inText ) = @_;

    # strip spaces
    my $text = $inText;
    VisDoc::StringUtils::trimSpaces($text);

    return $text;
}

=pod

_parseMethodType($text) -> $type

=cut

sub _parseMethodType {
    my ( $this, $inText ) = @_;

    # strip spaces
    my $rawType = $inText;
    VisDoc::StringUtils::trimSpaces($rawType);

    return $rawType;
}

=pod

_parseMethodParameters($text) -> \@list

=cut

sub _parseMethodParameters {
    my ( $this, $inText ) = @_;

    # strip spaces
    my $text = $inText;
    VisDoc::StringUtils::trimSpaces($text);

    $text = $this->{fileParser}->getContents($text);
    my @list =
      VisDoc::StringUtils::commaSeparatedListFromCommaSeparatedString($text);

    my $parameterDataList = $this->_parseMethodParameterData( \@list );
    return $parameterDataList;
}

=pod

_parseMethodParameterData(\@list) -> \@parameterData

Creates a list of ParameterData objects, read from a list of parameter strings.

To be implemented by subclass

=cut

sub _parseMethodParameterData {

    #    my ( $this, $inList ) = @_;

    return undef;
}

=pod

_parseMethodReturnType($text) -> \@list

=cut

sub _parseMethodReturnType {
    my ( $this, $inText ) = @_;

    # strip spaces
    my $text = $inText;
    VisDoc::StringUtils::trimSpaces($text);

    return $text;
}

=pod

Prepare formatting of text.
Optionally to be implemented by subclasses.

=cut

sub _preparePropertyParsing {
    my ( $this, $inText ) = @_;

    return $inText;
}

=pod

To be implemented by subclasses.

=cut

sub _splitOutOneLineProperty {
    my ( $this, $inMatches, $inPatternMap ) = @_;

    return undef;
}

=pod

_parseProperties( $text, \@properties ) -> ($text, \@propertyData)

=cut

sub _parseProperties {
    my ( $this, $inText, $inProperties ) = @_;

    my $properties = $inProperties;
    my $pattern    = $this->{PATTERN_PROPERTY_WITH_JAVADOC};
    my $patternMap = $this->{MAP_PROPERTY_WITH_JAVADOC};

    my $text = $inText;

	while ($text =~ m/$pattern/sx) {
		local $_ = $text;

		my @matches = $text =~ /$pattern/sx;
		
		if ( scalar @matches ) {
		
			$properties =
			  $this->_handlePropertyMatches( \@matches, $properties, $patternMap );
	
			# prepare the fetching and removal of property string
			my $startLoc = $-[0] || 0;
			my $endLoc = $+[0] || $-[0] || 0;
	
			# remove method declaration plus contents from text
			# add semi-colon because this is eaten by regex
			my $order    = scalar @{$properties} - 1;
			my $stripped = substr(
				$text, $startLoc,
				$endLoc - $startLoc,
				"; STRIPPED_PROPERTY_$order;\n"
			);
		}
	}
    return ( $text, $properties );
}

=pod

_handlePropertyMatches (@matches, $properties, $patternMap) -> \@properties

To be implemented by subclasses.

=cut

sub _handlePropertyMatches {
    my ( $this, $inMatches, $inProperties, $inPatternMap ) = @_;

    return undef;
}

=pod

_parsePropertyName($text) -> $name

To be implemented by subclasses.

=cut

sub _parsePropertyName {
    my ( $this, $inText ) = @_;

    return $inText;
}

=pod

To be implemented by subclasses.

=cut

sub _parsePropertyType {
    my ( $this, $inText ) = @_;

    return 0;
}

=pod

_parsePropertyDataType($text) -> $type

To be implemented by subclasses.

=cut

sub _parsePropertyDataType {
    my ( $this, $inText ) = @_;

    return $inText;
}

=pod

_parsePropertyValue($text) -> $text

To be implemented by subclasses.

=cut

sub _parsePropertyValue {
    my ( $this, $inText ) = @_;

    return $inText;
}

=pod

_postProcessPackageData( $packageData, $fileData )

To be implemented by subclasses.

=cut

sub _postProcessPackageData {
    my ( $this, $inPackageData, $inFileData ) = @_;

    # ...
}

=pod

_postProcessClassData( $classData )

To be implemented by subclasses.

=cut

sub _postProcessClassData {
    my ( $this, $inClassData ) = @_;

    # ...
}

=pod

_postProcessMethodData( $classData, \@methodData )

Type: interprets whether methods are:
- constructor
- class method
- instance method
and sets these values in property 'type'.

=cut

sub _postProcessMethodData {
    my ( $this, $inClassData, $inMethods ) = @_;

    foreach my $methodData (@$inMethods) {

        my $type = $methodData->{type};

        # is constructor?
        $type |= $VisDoc::MemberData::TYPE->{'CONSTRUCTOR_MEMBER'}
          if $methodData->{name} eq $inClassData->{name};

        # is class method?
        if ( grep { $_ eq 'static' } @{ $methodData->{access} } ) {
            $type |= $VisDoc::MemberData::TYPE->{'CLASS_MEMBER'};
        }
        else {
            $type |= $VisDoc::MemberData::TYPE->{'INSTANCE_MEMBER'};
        }
        $methodData->{type} = $type;
    }
}

=pod

_postProcessPropertyData( $classData, \@propertyData )

Type: interprets whether properties are:
- class property
- instance property
and sets these values in property 'type'.

=cut

sub _postProcessPropertyData {
    my ( $this, $inClassData, $inProperties ) = @_;

    foreach my $propertyData (@$inProperties) {

        my $type = $propertyData->{type};

        # is class method?
        if ( grep { $_ eq 'static' } @{ $propertyData->{access} } ) {
            $type |= $VisDoc::MemberData::TYPE->{'CLASS_MEMBER'};
        }
        else {
            $type |= $VisDoc::MemberData::TYPE->{'INSTANCE_MEMBER'};
        }
        $propertyData->{type} = $type;

    }
}

sub _stubObjectProperties {
    my ( $this, $inPre, $inText, $inPost ) = @_;

    #return '' if !$inText;

    $inPre  |= '';
    $inPost |= '';

    my $pattern = '^({.*?})$';
    my ( $newText, $blocks ) = VisDoc::StringUtils::replacePatternMatchWithStub(
        \$inText, $pattern, 0, 1,
        $VisDoc::StringUtils::VERBATIM_STUB_PROPERTY_OBJECT,
        $_[0]->{fileParser}->{data}->getStubCounterRef()
    );

    return "$inPre$inText$inPost" if !$newText;

    my $merged = $_[0]->{fileParser}->{data}->mergeData(
        VisDoc::FileData::getDataKey(
            $VisDoc::StringUtils::VERBATIM_STUB_PROPERTY_OBJECT),
        $blocks
    );
    $_[0]->{fileParser}->{data}->{objectProperties} = $merged;

    return "$inPre$newText;$inPost";
}

=pod

_parseMetadataData( $text ) -> \@metadataList

To be implemented by subclasses.

=cut

sub _parseMetadataData {
#    my ( $this, $inText ) = @_;

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
