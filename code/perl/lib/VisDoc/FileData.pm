package VisDoc::FileData;

use base 'VisDoc::Event::Dispatcher';
use strict;
use warnings;
use VisDoc::HashUtils;
use VisDoc::StringUtils;
use VisDoc::FindLinksEvent;
use VisDoc::LinkData;

my $DATA_KEYS = {
    $VisDoc::StringUtils::STUB_CODE_BLOCK               => 'codeBlocks',
    $VisDoc::StringUtils::VERBATIM_STUB_QUOTED_STRING   => 'quotedStrings',
    $VisDoc::StringUtils::VERBATIM_STUB_PROPERTY_OBJECT => 'objectProperties',
    $VisDoc::StringUtils::VERBATIM_STUB_ARRAY           => 'arrays',
    $VisDoc::StringUtils::STUB_TAG_CODE                 => 'codeBlocks',
    $VisDoc::StringUtils::STUB_JAVADOC_COMMENT          => 'javadocComments',
    $VisDoc::StringUtils::STUB_JAVADOC_SIDE             => 'javadocComments',
    $VisDoc::StringUtils::STUB_INLINE_LINK              => 'links',
    $VisDoc::StringUtils::STUB_TAG_LITERAL              => 'literalTags',
    $VisDoc::StringUtils::STUB_TAG_INHERITDOC           => 'inheritDocs',
};
my %functionTags;
my $macrosPattern;
my $stubCounter = 0;
my $linkDataRefs
  ; # hash of references to LinkData objects, with key: STUB_INLINE_LINK and value: LinkData ref

sub getStubCounterRef { return \$VisDoc::FileData::stubCounter; }

sub getLinkDataRefs { return $VisDoc::FileData::linkDataRefs; }

sub initLinkDataRefs {
    $VisDoc::FileData::linkDataRefs = {};
    $VisDoc::FileData::stubCounter  = 0;
}

BEGIN {

    # Default handlers for different %TAGS%
    %functionTags = (
        $VisDoc::StringUtils::STUB_CODE_BLOCK => { fn => \&_parseCodeStub, },
        $VisDoc::StringUtils::STUB_TAG_CODE   => { fn => \&_parseCodeStub, },
        $VisDoc::StringUtils::STUB_TAG_LITERAL =>
          { fn => \&_parseLiteralText, },
        $VisDoc::StringUtils::STUB_INLINE_LINK =>
          { fn => \&_parseStubInlineLink, },
    );

    $macrosPattern = '(' . VisDoc::StringUtils::getStubKeyPatternForTagNames(
        $VisDoc::StringUtils::STUB_CODE_BLOCK,
        $VisDoc::StringUtils::STUB_TAG_CODE,
        $VisDoc::StringUtils::STUB_TAG_LITERAL,

        # $VisDoc::StringUtils::STUB_INLINE_LINK, ### done by PostParser
    ) . ')';
}

=pod

StaticMethod getDataKey($stubKey) -> $dataKey

=cut

sub getDataKey {
    my ($inStubKey) = @_;

    return $DATA_KEYS->{$inStubKey};
}

sub new {
    my ($class) = @_;
    my $this = {
        path             => undef,
        language         => undef,
        modificationDate => undef,
        codeBlocks       => undef,    # hash with numbered key
        quotedStrings    => undef,    # hash with numbered key
        javadocComments  => undef,
        links            => undef,
        literalTags      => undef,
        images           => undef,
        arrays           => undef,
        objectProperties => undef,
        packages         => undef,    # ref of list of PackageData objects
    };
    bless $this, $class;

    return $this;
}

=pod

=cut

sub getStubValue {
    my ( $this, $inTagString, $inTagName ) = @_;

    my $dataKey = getDataKey($inTagName);
    return $this->{$dataKey}->{$inTagString};
}

=pod

mergeData( $key, \%data ) -> \%merged

Merges FileData's hash ref (for key $key) with passed data ref.

=cut

sub mergeData {
    my ( $this, $inDataKey, $inData ) = @_;

    return VisDoc::HashUtils::mergeHashes( $this->{$inDataKey}, $inData );
}

=pod

---++ registerTagHandler( $tag, $owner, $fnref )

STATIC Add a tag handler to the function tag handlers.
   * =$tag= name of the tag e.g. MYTAG
   * =$owner= function owner
   * =$fnref= function to execute. Will be passed ( $tagString, $tagName, $number )

=cut

sub registerTagHandler {
    my ( $this, $tag, $owner, $fnref ) = @_;
    $functionTags{$tag}->{fn}    = \&$fnref;
    $functionTags{$tag}->{owner} = $owner;
}

=pod

getContents( $text ) -> $text

Replace stubs by the original contents.
Only replaces stubs that need no further processing; STUB_INLINE_LINK for example is not included because the links need to be matched after processing all files.

=cut

sub getContents {
    my ( $this, $inText ) = @_;

    return $inText if !$inText;

    my $text = $inText;
    $this->_handleContentsOfVerbatimTags($text);

    while ( $text =~ s/$macrosPattern/$this->_expandMacro( $1, $2, $3 )/e ) { }

    VisDoc::StringUtils::restoreCDATATags($text);

    return $text;
}

=pod

=cut

sub substituteInlineLinkStub {
    my ( $this, $inText ) = @_;

    return $inText if !$inText;
    my $text = $inText;

    my $macrosPattern = '('
      . VisDoc::StringUtils::getStubKeyPatternForTagNames(
        $VisDoc::StringUtils::STUB_INLINE_LINK )
      . ')';

    while ( $text =~ s/$macrosPattern/$this->_expandMacro( $1, $2, $3 )/e ) { }

    return $text;
}

=pod

=cut

sub substituteInheritDocStub {
    my ( $this, $text, $inClass, $inMember, $inField ) = @_;

    return $text if !$text;

    while ( $text =~
s/\{\@inheritDoc\}/$this->_parseStubInheritDoc( $inClass, $inMember, $inField )/e
      )
    {
    }

    return $text;
}

=pod

getContentsOfLinkStub( $text ) -> $text

Retrieves the original contents of a link stub. For instance with tag:

{@link #previous Get previous value}

this function will return:

#previous Get previous value

Is used by JavadocParser to generate LinkData objects from text strings.

=cut

sub getContentsOfLinkStub {
    my ( $this, $inText ) = @_;

    return $this->_getContentsOfStub( $VisDoc::StringUtils::STUB_INLINE_LINK,
        $inText );
}

=pod

getDescriptionParts( $description ) -> ($beforeFirstLineTag, $summaryLine, $rest)

$beforeFirstLineTag is lifted out to catch summaries starting with <p>... (etc.)

Cases:

1)
Bla. blo <pre>xyz</pre> all the rest.
beforeFirstLineTag	= 
first line			= Bla.
rest				=  blo <pre>xyz</pre> all the rest.

2)
<pre>xyz... something else.</pre> all the rest.
beforeFirstLineTag	= <pre>
first line			= xyz...
rest				=  something else.</pre> all the rest.

3)
<p>xyz <pre>something else</pre> all the rest.</p>
beforeFirstLineTag	= <p>
first line			= xyz 
rest				= <pre>something else</pre> all the rest.</p>
 
 4)
 first.last@comp.com <b>yo!</b>
 beforeFirstLineTag	= 
 first line			= first.last@comp.com <b>yo!</b> 
 rest				= 

=cut

sub getDescriptionParts {
    my ( $this, $inDescriptionText ) = @_;

    my $beforeFirstLineTag = '';
    my $summaryLine        = '';
    my $rest               = '';

    my $description = $this->getContents($inDescriptionText);

    my $HTML_BLOCK_ELEMENTS =
'ul|tr|th|td|table|pre|p|ol|li|ins|img|html|hr|h|div|del|center|br|blockquote|address';

    # first check if text starts with block content
    my $pattern = '^\s*(<(?:' . $HTML_BLOCK_ELEMENTS . ')\s*>)(.*)$';

    if ( $description =~ m/$pattern/is ) {
        if ($1) {
            $beforeFirstLineTag = $1;
            $description = $2 if $2;
        }
    }
    VisDoc::StringUtils::trimSpaces($beforeFirstLineTag);

    # look for dot, or a block tag
    my $upToTagPattern =
      '^(.*?)((?:\.+ )|(?:<(?:' . $HTML_BLOCK_ELEMENTS . ')|$))(.*)$';

    if ( $description =~ m/$upToTagPattern/ims ) {
        $summaryLine = $1;
        $summaryLine .= $2 if $2;
        $rest = $3 if $3;

    }
    else {
        $summaryLine = $description;
    }

    #	VisDoc::StringUtils::trimSpaces($summaryLine);
    #	VisDoc::StringUtils::trimSpaces($rest);
    return ( $beforeFirstLineTag, $summaryLine, $rest );
}

=pod

Dispatches FindLinksEvent to all listeners (MethodData, ParameterData, PropertyData)

=cut

sub createLinkReferencesInMemberDefinitions {
    my ( $this, $inClasses ) = @_;

    my $event =
      VisDoc::FindLinksEvent->new( $VisDoc::FindLinksEvent::NAME, $this,
        $inClasses, \&_createLinkData );

    $this->dispatchEvent($event);
}

=pod

Dispatches SubstituteLinkStubsEvent to all listeners (MethodData, ParameterData, PropertyData)

=cut

sub substituteLinkReferencesInMemberDefinitions {
    my ( $this, $inClasses ) = @_;

    my $event = VisDoc::SubstituteLinkStubsEvent->new(
        $VisDoc::SubstituteLinkStubsEvent::NAME,
        $this, $inClasses, \&substituteInlineLinkStub );

    $this->dispatchEvent($event);
}

=pod

createInheritDocLinkData( $className, $memberName, $label ) -> $stubString

=cut

sub createInheritDocLinkData {
    my ( $this, $inClassName, $inMemberName, $inLabel ) = @_;

    my $stub = $this->_createLinkData( $inClassName, $inMemberName, $inLabel );

    # temporarily replace LINK stub by INHERIT_DOC stub
    # so we can remove 'inherited' links
    # to prevent the concatenation of links
    my $p1 = $VisDoc::StringUtils::STUB_INLINE_LINK;
    my $p2 = $VisDoc::StringUtils::STUB_TAG_INHERITDOC_LINK;
    $stub =~ s/$p1/$p2/go;

    return $stub;
}

=pod

createAndStoreInlineLinkData( $value, $stub ) -> $linkData

Creates a LinkData object from a value and an existing stub.
Stores ref to object in {linkDataRefs}.

=cut

sub createAndStoreInlineLinkData {
    my ( $this, $inLink, $inStub ) = @_;

    my $linkData = VisDoc::LinkData::createLinkData( 'link', $inLink, $inStub );
    $VisDoc::FileData::linkDataRefs->{$inStub} = \$linkData;

    return $linkData;
}

=pod

createInheritedFieldValue( $fieldData, $superClassData, $superMemberData ) -> $text

=cut

sub createInheritedFieldValue {
    my ( $this, $inField, $inSuperclassData, $inSuperMember ) = @_;

    my $superJavaDoc = $inSuperMember->{javadoc};
    return undef if !$superJavaDoc;

    my $existingFieldValue =
      $superJavaDoc->getCombinedFieldValue( $inField->{name} );
    return undef if !$existingFieldValue;

    # remove existing inheritDoc stubs
    #$existingFieldValue =~ s/\s*%STARTINHERITDOC%(.*?)%ENDINHERITDOC%\s*//g;

    # remove existing inheritDoc link stubs
    my $pattern = VisDoc::StringUtils::getStubKeyPatternForTagNames(
        $VisDoc::StringUtils::STUB_TAG_INHERITDOC_LINK);
    $existingFieldValue =~ s/\s*$pattern\s*//gs;

    my $linkStub = $this->createInheritDocLinkData( $inSuperclassData->{name},
        $inSuperMember->getName(), '&rarr;' );

    return
"%STARTINHERITDOC%$existingFieldValue <span class=\"inheritDocLink\">$linkStub</span>%ENDINHERITDOC%";
}

=pod

Some stub strings need further processing. For instance, a link will be formatted differently than code text.
This function calls a dispatch function for each stub so that each can be processed in its own way.

=cut

sub _expandMacro {

    #my ( $this, $inTagString, $inTagName, $inNumber ) = @_;

    if ( $functionTags{ $_[2] }->{fn} ) {
        my $owner = $functionTags{ $_[2] }->{owner} || $_[0];

        my @params = @_;
        shift @params;

        my $result = &{ $functionTags{ $_[2] }->{fn} }( $owner, @params );
        return $result;
    }
    else {
        return "tag undefined";
    }
}

sub _parseCodeStub {
    my ( $this, $inTagString, $inTagName, $inNumber ) = @_;

    my $stubText = $this->getStubValue( $inTagString, $inTagName );
    my $formatted = $this->_formatCodeText($stubText);

    return $formatted;
}

=pod

_parseStubInlineLink($tagString, $tagName, $number) -> $text

=cut

sub _parseStubInlineLink {
    my ( $this, $inTagString, $inTagName, $inNumber ) = @_;

    # check to see if a linkDataRefs exists
    my $ref = $VisDoc::FileData::linkDataRefs->{$inTagString};

    return '' if !$ref;
    return $$ref->formatInlineLink();
}

=pod

_parseStubInheritDoc($className, $memberName, $fieldName) -> $text

=cut

sub _parseStubInheritDoc {
    my ( $this, $inClass, $inMember, $inField ) = @_;

    my $inheritedComment =
      $this->_getInheritedComment( $inClass, $inMember, $inField );
          
    return $inheritedComment || '';
}

=pod

_getInheritedComment( $class, $member ) -> $description

=cut

sub _getInheritedComment {
    my ( $this, $inClass, $inMember, $inField ) = @_;

    my $inherited;

    my $interfaceChain = $inClass->getSuperInterfaceChain();
    
    $inherited =
      $this->_getInheritedCommentForSuperclassOrInterface( $inMember, $inField,
        $interfaceChain );

    if ( !$inherited ) {
        my $superclassChain = $inClass->getSuperclassChain();
        $inherited =
          $this->_getInheritedCommentForSuperclassOrInterface( $inMember,
            $inField, $superclassChain );
    }

    return $inherited;
}

=pod

=cut

sub _getInheritedCommentForSuperclassOrInterface {
    my ( $this, $inMember, $inField, $inSuperChain ) = @_;

    return undef if !$inSuperChain || !scalar @{$inSuperChain};

    my $memberName = $inMember->getName();

    # go through the list of Class objects
    foreach my $superclass ( @{$inSuperChain} ) {

        my $superclassData = $superclass->{classdata};
        next if !$superclassData;

        my $superMember =
          $superclassData->getMemberWithQualifiedName($memberName);
        next if !$superMember;

        my $inherited = $this->createInheritedFieldValue( $inField, $superclassData,
            $superMember );
            
        # retrieve contents through the superclass filedata object
		$inherited = $superclassData->{fileData}->getContents($inherited);
		return $inherited;
    }
    return undef;
}

=pod

=cut

sub _parseLiteralText {
    my ( $this, $inTagString, $inTagName, $inNumber ) = @_;

    my $text = $this->getStubValue( $inTagString, $inTagName );

    my $formatter = VisDoc::Formatter::formatter( $this->{language} );
    $formatter->formatLiteral($text);
    return $text;
}

=pod

_handleContentsOfVerbatimTags( $text ) -> $text

Verbatim tags: quoted strings, property objects, arrays.

=cut

sub _handleContentsOfVerbatimTags {

    #my $this = $_[0]
    #my $text = $_[1]

    my $re = "
      %
      (
      $VisDoc::StringUtils::VERBATIM_STUB_QUOTED_STRING
      ||
      $VisDoc::StringUtils::VERBATIM_STUB_PROPERTY_OBJECT
      ||
      $VisDoc::StringUtils::VERBATIM_STUB_ARRAY
      )
      _
      ([0-9]+)
      %
      ";

    while ( $_[1] =~ m/$re/gxs ) {
        next if !$1 || !$2;
        my $key = VisDoc::StringUtils::getStubKey( $1, $2 )
          ;    # includes number, for instance: %STUB_1%
               # find original value
        my $value = $_[0]->_getValue( $1, $key );

        $_[1] =~ s/$key/$value/ if $value;
    }
}

=pod

=cut

sub _getValue {
    my ( $this, $inStubKey, $inKey ) = @_;

    return $this->{ getDataKey($inStubKey) }->{$inKey};
}

=pod

_formatCodeText( $text ) -> $text

Wraps <code>...</code> (for single line text) or <pre>...</pre> (for multiline text) around text.


=cut

sub _formatCodeText {
    my ( $this, $inText ) = @_;

    return '' if !$inText;

    my $text = $inText;

    # remove stars, preserve linebreaks
    VisDoc::StringUtils::handleStarsInCodeText( $text, 1 );

# strip spaces at end of code block, between last character of code and the tag </code> or </pre>
    $text =~ s/[[:space:]]*(<\/code>|<\/pre>|<\/blockquote>|<\/div>)/$1/go;

    # make all left spacing equal
    $text =~ s/\n\n/\n/go;
    $text = $this->_equalizeLeftIndent($text);

    VisDoc::StringUtils::convertHtmlEntities($text);

    my $formatter = VisDoc::Formatter::formatter( $this->{language} );
    $formatter->colorize($text);

    # place code text in <pre> text if running on multiple lines
    my $tag = ( $text =~ m/\n/g ) ? 'pre' : 'code';
    my $prefix = "<$tag>";
    $prefix = "$prefix\n" if $tag eq 'pre';
    my $suffix = "</$tag>";
    $suffix = "\n$suffix" if $tag eq 'pre';

    # remove spaces at end
    $text =~ s/[[:space:]]+$//s;

    return "$prefix$text$suffix";
}

=pod

=cut

sub _equalizeLeftIndent {
    my ( $this, $inText ) = @_;

    my @tmplines = split( "\n", $inText );
    my @lines;
    my $smallestLeftIndent = 99999999;

    foreach my $line (@tmplines) {

        # first change tabs to spaces so we can count
        $line =~ s/\t/    /gso;

        # count number of spaces at left
        $line =~ m/^(\s+)(.*)$/g;
        push @lines, $line;

        next if !$1;
        my $leftIndent = length $1;
        next if $leftIndent == 0;

        if ($2) {
            $smallestLeftIndent = $leftIndent
              if ( $leftIndent < $smallestLeftIndent );
        }
    }

# Now we know how much space is redundant (smallestLeftIndent), strip each line from redundant space

    foreach my $line (@lines) {
        $line =~ m/^(\s+)(.*)$/g;
        
        next if !$1;
        my $leftIndent   = ( length $1 ) - $smallestLeftIndent;
        my $indentString = ' ' x $leftIndent;
        $line =~ s/^(\s+)(.*)$/$indentString$2/g;        
    }

    my $text = join( "\n", @lines );
    return $text;
}

=pod

_getContentsOfStub( $stubName, $text ) -> $text

Replaces stubs from text with their value.

=cut

sub _getContentsOfStub {
    my ( $this, $inStubName, $inText ) = @_;

    return $inText if !$inText;

    my $re = "%($inStubName)_([0-9]+)%";

    return $inText if !( $inText =~ m/$re/sx );
    local $_ = $inText;

    while (m/$re/gxs) {
        next if ( !$1 || !$2 );

        my $key = VisDoc::StringUtils::getStubKey( $1, $2 );

        my $dataKey;
        my $value = '';
        my $tag   = '';
        if ( $1 eq $inStubName ) {
            $dataKey = getDataKey($1);

            # find original value
            $value = $this->{$dataKey}->{$key};

            # TODO: use getStubValue
        }
        $_ =~ s/$key/$value/ if $value;
    }
    return $_;
}

=pod

_createLinkData( $className, $memberName, $label ) -> $stubString

=cut

sub _createLinkData {
    my ( $this, $inClassName, $inMemberName, $inLabel ) = @_;

    my $counterRef = $this->getStubCounterRef();
    my $stub =
      VisDoc::StringUtils::getStubKey( $VisDoc::StringUtils::STUB_INLINE_LINK,
        ${$counterRef} );
    ${$counterRef}++;

    my $linkText = $inMemberName ? "$inClassName#$inMemberName" : $inClassName;
    $linkText .= " $inLabel" if $inLabel;

    my $linkData = $this->createAndStoreInlineLinkData( $linkText, $stub );

    return $stub;
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
