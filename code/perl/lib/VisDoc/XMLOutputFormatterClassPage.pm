# See bottom of file for license and copyright information

package VisDoc::XMLOutputFormatterClassPage;
use base 'VisDoc::XMLOutputFormatterBase';

use strict;
use warnings;
use XML::Writer();
use VisDoc::ClassData;
use VisDoc::MemberData;
use VisDoc::PackageData;
use VisDoc::Time;
use VisDoc::MemberFormatterFactory;
use VisDoc::Language;
use VisDoc::StringUtils;

=pod

_formatData ($xmlWriter, $classData) -> $bool

=cut

sub _formatData {
    my ( $this, $inWriter ) = @_;

    $this->_writeAssetLocations($inWriter);
    $this->_writeTitleAndPageId($inWriter);
    $this->_writeLanguageId($inWriter);
    $this->_writeClassData($inWriter);
    $this->_writeSummary($inWriter);
    $this->_writeMembers($inWriter);
    $this->_writeFooter($inWriter);

    return 1;
}

=pod

=cut

sub _writeLanguageId {
    my ( $this, $inWriter ) = @_;

	$inWriter->cdataElement( 'language', $this->{language} );
}

=pod

=cut

sub _writeAccessKeyLinkForSection {
    my ( $this, $inWriter, $inKey, $inTitleKey ) = @_;

    my $title = $this->_docTerm($inTitleKey);
    $title =~ s/ //go;
    $inWriter->cdataElement( $inKey, $title );
}

=pod

=cut

sub _writeClassData {
    my ( $this, $inWriter ) = @_;

    $inWriter->startTag('classData');

    $this->_writePackage($inWriter);
    $this->_writeKindOfClass($inWriter);
    $this->_writeEnclosingClass($inWriter);
    $this->_writeInheritsFrom($inWriter);
    $this->_writeImplements($inWriter);
    $this->_writeImplementedBy($inWriter);
    $this->_writeSubclasses($inWriter);
    $this->_writeDispatchedBy($inWriter);
    $this->_writeClassDetails($inWriter);
    $this->_writeSourceCode($inWriter);
    $this->_writeClassDescription($inWriter);
    $this->_writeClassFields($inWriter);
	$this->_writeMetadata($inWriter);
	
    $inWriter->endTag('classData');
}

=pod

=cut

sub _writePackage {
    my ( $this, $inWriter ) = @_;

    my $packageName = $this->{data}->{packageName};
    return if !$packageName;

    $inWriter->startTag('package');

    $inWriter->cdataElement( 'title',
        $this->_docTerm('classproperty_package') );
    $inWriter->startTag('item');
    $this->_writeLinkXml( $inWriter, $packageName,
        VisDoc::PackageData::createUriForPackage($packageName) );
    $inWriter->endTag('item');

    $inWriter->endTag('package');
}

=pod

=cut

sub _writeKindOfClass {
    my ( $this, $inWriter ) = @_;

    $inWriter->startTag('kindOfClass');

    $inWriter->cdataElement( 'title', $this->_docTerm('classproperty_kind') );
    my $formatter = VisDoc::Formatter::formatter( $this->{language} );

    my $classAccess = $formatter->formatClassAccess( $this->{data}->{type},
        $this->{data}->{access}, 1 );
    $inWriter->cdataElement( 'value', $classAccess );

    $inWriter->endTag('kindOfClass');
}

=pod

=cut

sub _writeEnclosingClass {
    my ( $this, $inWriter ) = @_;

    my $enclosingClass = $this->{data}->{enclosingClass};
    return if !$enclosingClass;

    $inWriter->startTag('enclosingClass');

    $inWriter->cdataElement( 'title',
        $this->_docTerm('classproperty_enclosingclass') );
    $inWriter->startTag('item');
    $this->_writeLinkXml(
        $inWriter,
        $enclosingClass->{name},
        $enclosingClass->getUri()
    );
    $inWriter->endTag('item');
    $inWriter->endTag('enclosingClass');
}

=pod

Creates a progressive list of superclasses, each separated by a colon.
Each superclass is made a link (if possible - otherwise the name is used)

=cut

sub _writeInheritsFrom {
    my ( $this, $inWriter ) = @_;

    my $superclassChain = $this->{data}->getSuperclassChain();

    $inWriter->startTag('inheritsFrom');

    $inWriter->cdataElement( 'title',
        $this->_docTerm('classproperty_inheritsfrom') );

    if ( $superclassChain && scalar @{$superclassChain} ) {

        # go through the list of Class objects
        foreach my $superclass ( @{$superclassChain} ) {

            # we can create a link if we have a reference to a ClassData object
            my $classdata = $superclass->{classdata};
            if ( $classdata && $classdata->{name} ) {
                $inWriter->startTag('item');
                $this->_writeLinkXml(
                    $inWriter,
                    $classdata->{name},
                    VisDoc::ClassData::createUriForClass(
                        $classdata->{classpath}
                    )
                );
                $inWriter->endTag('item');
            }
            elsif ( $superclass->{name} ) {
                $inWriter->startTag('item');
                $this->_writeLinkXml( $inWriter, $superclass->{name} );
                $inWriter->endTag('item');
            }
        }
    }
    else {

        # inherits from none
        $inWriter->startTag('item');
        $this->_writeLinkXml( $inWriter, $this->_docTerm('classproperty_none'),
            undef );
        $inWriter->endTag('item');
    }

    $inWriter->endTag('inheritsFrom');
}

=pod

=cut

sub _writeImplements {
    my ( $this, $inWriter ) = @_;

    my $interfaces = $this->{data}->{interfaces};

    return if !$interfaces || !scalar @{$interfaces};

    $inWriter->startTag('conformsTo');

    $inWriter->cdataElement( 'title',
        $this->_docTerm('classproperty_implements') );

    my @interfaces =
      sort { lc( $a->{name} ) cmp lc( $b->{name} ) } @{$interfaces};
    foreach my $interface (@interfaces) {

        my $classdata = $interface->{classdata};
        if ( $classdata && $classdata->{name} ) {
            $inWriter->startTag('item');
            $this->_writeLinkXml( $inWriter, $classdata->{name},
                VisDoc::ClassData::createUriForClass( $classdata->{classpath} )
            );
            $inWriter->endTag('item');
        }
        elsif ( $interface->{name} ) {
            $inWriter->startTag('item');
            $this->_writeLinkXml( $inWriter, $interface->{name}, VisDoc::ClassData::createUriForClass( $interface->{classpath} )
            );
            $inWriter->endTag('item');
        }
    }

    $inWriter->endTag('conformsTo');
}

=pod

=cut

sub _writeImplementedBy {
    my ( $this, $inWriter ) = @_;

    my $implementedBy = $this->{data}->{implementedBy};
    return if !$implementedBy || !scalar @{$implementedBy};

    $inWriter->startTag('implementedBy');

    $inWriter->cdataElement( 'title',
        $this->_docTerm('classproperty_implementedby') );

    my @classes =
      sort { lc( $a->{name} ) cmp lc( $b->{name} ) } @{$implementedBy};
    foreach my $class (@classes) {
        if ( $class && $class->{classpath} ) {
            $inWriter->startTag('item');
            $this->_writeLinkXml( $inWriter, $class->{name},
                VisDoc::ClassData::createUriForClass( $class->{classpath} ) );
            $inWriter->endTag('item');
        }
        elsif ( $class->{name} ) {
            $inWriter->startTag('item');
            $this->_writeLinkXml( $inWriter, $class->{name}, undef );
            $inWriter->endTag('item');
        }
    }

    $inWriter->endTag('implementedBy');
}

=pod

=cut

sub _writeSubclasses {
    my ( $this, $inWriter ) = @_;

    my $subclasses = $this->{data}->{subclasses};
    return if !$subclasses || !scalar @{$subclasses};

    $inWriter->startTag('subclasses');

    my $titleKey =
      ( $this->{data}->{type} == $VisDoc::ClassData::TYPE->{CLASS} )
      ? 'classproperty_subclasses'
      : 'classproperty_subinterfaces';

    $inWriter->cdataElement( 'title', $this->_docTerm($titleKey) );

    my @classes = sort { lc( $a->{name} ) cmp lc( $b->{name} ) } @{$subclasses};
    foreach my $class (@classes) {
        if ( $class && $class->{classpath} ) {
            $inWriter->startTag('item');
            $this->_writeLinkXml( $inWriter, $class->{name},
                VisDoc::ClassData::createUriForClass( $class->{classpath} ) );
            $inWriter->endTag('item');
        }
        elsif ( $class->{name} ) {
            $inWriter->startTag('item');
            $this->_writeLinkXml( $inWriter, $class->{name}, undef );
            $inWriter->endTag('item');
        }
    }

    $inWriter->endTag('subclasses');
}

=pod

=cut

sub _writeDispatchedBy {
    my ( $this, $inWriter ) = @_;

    my $dispatchedBy = $this->{data}->{dispatchedBy};
    return if !$dispatchedBy || !scalar @{$dispatchedBy};

    $inWriter->startTag('dispatchedBy');

    $inWriter->cdataElement( 'title',
        $this->_docTerm('classproperty_dispatchedby') );

    my @classes =
      sort { lc( $a->{name} ) cmp lc( $b->{name} ) } @{$dispatchedBy};
    foreach my $class (@classes) {
        if ( $class && $class->{classpath} ) {
            $inWriter->startTag('item');
            $this->_writeLinkXml( $inWriter, $class->{name},
                VisDoc::ClassData::createUriForClass( $class->{classpath} ) );
            $inWriter->endTag('item');
        }
        elsif ( $class->{name} ) {
            $inWriter->startTag('item');
            $this->_writeLinkXml( $inWriter, $class->{name}, undef );
            $inWriter->endTag('item');
        }
    }

    $inWriter->endTag('dispatchedBy');
}

=pod

Writes out: version, author, classpath, last modified

=cut

sub _writeClassDetails {
    my ( $this, $inWriter ) = @_;

    $inWriter->startTag('classDetails');

    $this->_writeDetailsValue( $inWriter, undef, 'version',
        'classdetail_version' );
    $this->_writeDetailsValue( $inWriter, undef, 'author',
        'classdetail_author' );
    $this->_writeDetailsValue(
        $inWriter, $this->{data}->{classpath},
        undef,     'classdetail_classpath'
    );

    my $modificationDate =
      VisDoc::Time::formatTime( $this->{data}->{fileData}->{modificationDate} );

    $this->_writeDetailsValue( $inWriter, $modificationDate, undef,
        'classdetail_lastmodified' );

    $inWriter->endTag('classDetails');
}

=pod

=cut

sub _writeSourceCode {
    my ( $this, $inWriter ) = @_;

    return if !$this->{preferences}->{includeSourceCode};

    my $path = $this->{data}->{fileData}->{path};
    $path = File::Spec->rel2abs( $path, $this->{preferences}->{base} );

    my $classText = VisDoc::readFile($path);
    return if !$classText;

    $classText =~ s/\r/\n/gs;
    $classText =~ s/\n\n/\n/gs;
    $classText =~ s/\t/    /g;

    VisDoc::StringUtils::trimBOM($classText);
    VisDoc::StringUtils::trimSpaces($classText);

    $inWriter->startTag('sourceCode');

    $inWriter->cdataElement( 'viewSourceButton',
        $this->_docTerm('includesource_viewsourcebutton') );
    $inWriter->cdataElement( 'hideSourceButton',
        $this->_docTerm('includesource_hidesourcebutton') );
    $inWriter->cdataElement( 'sourceBottomButton',
        $this->_docTerm('includesource_tosourceend') );

    $inWriter->cdataElement( 'sourceCodeText',     $classText );
    $inWriter->cdataElement( 'sourceCodeLanguage', "brush:$this->{language}" );

    $inWriter->cdataElement( 'sourceTopButton',
        $this->_docTerm('includesource_tosourcetop') );

    $inWriter->endTag('sourceCode');
}

=pod

=cut

sub _writeClassDescription {
    my ( $this, $inWriter ) = @_;

    return if !$this->{data}->{javadoc};

    $inWriter->startTag('classDescription');

    my $fields = $this->{data}->{javadoc}->fieldsWithName('deprecated');
    if ($fields) {
        $this->_writeFieldValue( $inWriter, 'deprecated', $fields );
    }

    my $description = $this->{data}->{javadoc}->getDescription();
    if ($description) {
        $description = $this->{data}->{fileData}->getContents($description);
        my ( $beforeFirstLineTag, $summaryLine, $rest ) =
          $this->{data}->{fileData}->getDescriptionParts($description);

        if ( $summaryLine && !$beforeFirstLineTag ) {
            $inWriter->cdataElement( 'summary', $summaryLine );
        }
        else {
            $rest = "$beforeFirstLineTag$summaryLine$rest";
        }
        if ($rest) {
            $inWriter->cdataElement( 'restOfDescription', $rest );
        }
    }

    $inWriter->endTag('classDescription');
}

=pod

_writeClassFields

<fields>
	<field>
		<title>
			<![CDATA[See also]]>
		</title>
		<description>
				<item>
					<value>
						<![CDATA[ <a class="className" href="com_visiblearea_see_See.html">com.visiblearea.see.See</a> ]]>
					</value>
				</item>
		</description>
	</field>
</fields>

NOTE: should get format with <link>:

<link>
	<name>
		<![CDATA[VisDoc]]>
	</name>
	<uri>
		<![CDATA[http://visiblearea.com/visdoc/]]>
	</uri>
</link>

=cut

sub _writeClassFields {
    my ( $this, $inWriter ) = @_;

    return if !$this->{data}->{javadoc};

    my $allFields = $this->{data}->{javadoc}->getAllFieldsGroupedByName();

    my @keys = sort keys %{$allFields};
    return if !scalar @keys;

    my $doneFields     = 'version|author|description';
    my $excludedFields = 'deprecated|exclude';
    my $privateFields =
      'class|property|method|helpid|tiptext|link|inheritDoc|img';

    my $excludePattern = "$doneFields|$excludedFields|$privateFields";
    my @fieldKeys;
    map { push( @fieldKeys, $_ ) if !( $_ =~ m/($excludePattern)/ ); } @keys;
    return if !( scalar @fieldKeys );

    foreach my $key (@fieldKeys) {
        my $fields = $allFields->{$key};
        $this->_writeFieldValue( $inWriter, $key, $fields ) if $fields;
    }
}

=pod

=cut

sub _writeMetadata {
	my ( $this, $inWriter ) = @_;

	my $metadataFields = $this->{data}->{metadata};
	$this->_writeMetadataFields( $inWriter, 'metadata', $metadataFields )
		if $metadataFields && scalar @{$metadataFields};
}

=pod

<field>
	<title>
		<![CDATA[Events broadcasted to listeners]]>
	</title>
	<description>
		<item>
			<value>
				<![CDATA[<code>onChanged(changedField:TextField):Void</code>  When the selection is changed by the user.]]>
			</value>
		</item>
		<item>
			... etcetera
		</item>
	</description>
</field>

=cut

sub _writeFieldValue {
    my ( $this, $inWriter, $inTitleKey, $inFields ) = @_;

	return if !scalar @{$inFields};
	
    $inWriter->startTag('field');
    my $title = VisDoc::Language::getJavadocTerm($inTitleKey) || $inTitleKey;
   
    $inWriter->cdataElement( 'title', $title );
    $inWriter->startTag('description');

    foreach my $field ( @{$inFields} ) {
        my $value;

        if ( $field->isa("VisDoc::LinkData") ) {
            my VisDoc::LinkData $linkData = $field;
            $value = $linkData->formatInlineLink('html');
        }
        else {
            $value = $field->getValue();
        }
        if ($value) {
            $value = $this->{data}->{fileData}->getContents($value);
        }
        $this->_writeValueXml( $inWriter, $value );
    }
    $inWriter->endTag('description');
    $inWriter->endTag('field');
}

=pod

<field>
	<title>
		<![CDATA[Parameters]]>
	</title>
	<paramfield>
		<name>
			<![CDATA[inValue]]>
		</name>
		<description>
			<![CDATA[The amount of force]]>
		</description>
	</paramfield>
	<paramfield>
		... etcetera
	</paramfield>
</field>

=cut

sub _writeParamFields {
    my ( $this, $inWriter, $inTitleKey, $inParamFields ) = @_;

    $inWriter->startTag('field');
    my $title = VisDoc::Language::getJavadocTerm($inTitleKey);
    $inWriter->cdataElement( 'title', $title );

    # quickly calculate the longest param name
    my $longestName = 0;
    foreach my $field ( @{$inParamFields} ) {
        my $l = length $field->{name};
        $longestName = $l if $l > $longestName;
    }

    foreach my $field ( @{$inParamFields} ) {

        my $value;
        if ( $field->isa("VisDoc::LinkData") ) {
            my VisDoc::LinkData $linkData = $field;
            $value = $linkData->formatInlineLink('html');
        }
        else {
            $value = $field->getValue();
        }
        if ($value) {
            $value = $this->{data}->{fileData}->getContents($value);
        }

        $inWriter->startTag('paramfield');
        my $name = $field->{name};
        if ($name) {
            my $paddingLength = $longestName - length $name;
            my $padding       = ' ' x $paddingLength;
            $inWriter->cdataElement( 'name', "$name$padding" );
        }

        $inWriter->cdataElement( 'description', $value ) if $value;
        $inWriter->endTag('paramfield');

    }
    $inWriter->endTag('field');
}

=pod

<field>
	<title>
		<![CDATA[Component metadata]]>
	</title>
	<metadatatags>
		<tag>
			<title>
				<![CDATA[Collection]]>
			</title>
			<metadatatagattribute>
				<name>
					<![CDATA[collectionClass]]>
				</name>
				<description>
					<![CDATA["config/OpenSpace.xml"]]>
				</description>
			</metadatatagattribute>
		</tag>
	</metadatatags>
</field>

=cut

sub _writeMetadataFields {
    my ( $this, $inWriter, $inTitleKey, $inFields ) = @_;

    $inWriter->startTag('field');
    my $title = VisDoc::Language::getJavadocTerm($inTitleKey);
    $inWriter->cdataElement( 'title', $title );

    $inWriter->startTag('metadatatags');

    foreach my $field ( @{$inFields} ) {

        $inWriter->startTag('tag');

        my $name = $field->{'name'};
        if ($name) {
            $inWriter->cdataElement( 'title', $name );
        }

        if ( !$field->{items} || !scalar @{ $field->{items} } ) {
            $inWriter->cdataElement( 'metadatatagattribute', '' );
        }
        else {
            foreach my $item ( @{ $field->{items} } ) {
                $inWriter->startTag('metadatatagattribute');

                foreach my $key ( keys %{$item} ) {
                    my $name =
                      $key eq $VisDoc::MetadataData::NO_KEY ? '' : $key;
                    $inWriter->cdataElement( 'name', $name );
                    my $description = $item->{$key} ? $item->{$key} : '';
                    $inWriter->cdataElement( 'description', $description );
                }

                $inWriter->endTag('metadatatagattribute');
            }
        }

        $inWriter->endTag('tag');
    }
    $inWriter->endTag('metadatatags');
    $inWriter->endTag('field');
}

=pod

=cut

sub _writeSummary {
    my ( $this, $inWriter ) = @_;

    return
      if $this->{data}->getMemberCount( $this->{preferences}->{listPrivate} ) ==
          0;

    $inWriter->startTag('pageSummary');

    my $title = $this->_docTerm('header_summary');
    $inWriter->cdataElement( 'title', $title );
    $title =~ s/ //go;
    $inWriter->cdataElement( 'id', $title );

    $inWriter->startTag('memberList');

    my $summaryData = {
        hasMembers  => 0,
        hasTypeInfo => 0,
        hasSummary  => 0,
    };
    my $callToWriteSummaryPart = sub {
        my ( $inKey, $inTitleKey ) = @_;

        $this->_writeSummary_forMemberGroup( $inWriter, $this->{data}, $inKey,
            $inKey, $this->_docTerm($inTitleKey), $summaryData );
    };

    &$callToWriteSummaryPart( 'innerclasses',    'header_innerclasses' );
    &$callToWriteSummaryPart( 'constructors',    'header_constructor' );
    &$callToWriteSummaryPart( 'namespaces',      'header_namespaces' );
    &$callToWriteSummaryPart( 'constants',       'header_constants' );
    &$callToWriteSummaryPart( 'classproperties', 'header_classproperties' );
    &$callToWriteSummaryPart( 'instanceproperties',
        'header_instanceproperties' );
    &$callToWriteSummaryPart( 'classmethods',    'header_classmethods' );
    &$callToWriteSummaryPart( 'instancemethods', 'header_instancemethods' );

    # showHideTypeInfo
    if ( $summaryData->{hasTypeInfo} ) {
        $inWriter->startTag('showHideTypeInfo');
        $inWriter->cdataElement( 'showTypeInfo',
            $this->_docTerm('summary_showTypeInfo') );
        $inWriter->cdataElement( 'hideTypeInfo',
            $this->_docTerm('summary_hideTypeInfo') );
        $inWriter->endTag('showHideTypeInfo');
    }

    # showHideSummaries
    if ( $summaryData->{hasSummary} ) {
        $inWriter->startTag('showHideSummaries');
        $inWriter->cdataElement( 'showSummaries',
            $this->_docTerm('summary_showSummaries') );
        $inWriter->cdataElement( 'hideSummaries',
            $this->_docTerm('summary_hideSummaries') );
        $inWriter->endTag('showHideSummaries');
    }

=pod
	# sort members toggle
	if ($summaryData->{hasMembers}) {
		$inWriter->startTag('sortSummaries');
		$inWriter->cdataElement('sortAlphabetically', VisDoc::Language::getDocTerm('summary_sortAlphabetically', $this->{language}));
		$inWriter->cdataElement('sortSourceOrder', VisDoc::Language::getDocTerm('summary_sortSourceOrder', $this->{language}));
		$inWriter->endTag('sortSummaries');
	}
=cut

    $inWriter->endTag('memberList');
    $inWriter->endTag('pageSummary');
}

=pod

@param summaryData: object to store temporary data

=cut

sub _writeSummary_forMemberGroup {
    my ( $this, $inWriter, $inClassData, $inPartName, $inMemberType, $inTitle,
        $inSummaryData )
      = @_;


    my $members = $this->_getMembersForPart( $inClassData, $inPartName );
    return if !$members || !scalar @{$members};

    my $isPrivatePart = $this->_isPartPrivate( $members );

    $inWriter->startTag('memberSummaryPart', 'private' => $isPrivatePart);

    if ( $members && scalar @{$members} ) {

        $inSummaryData->{hasMembers} += 1;

        foreach my $member ( @{$members} ) {

            next if $member->isExcluded();
            next
              if !$this->{preferences}->{listPrivate} && !$member->isPublic();

            $inWriter->startTag('item', 'private' => $member->isPublic() ? 0 : 1);

            $inWriter->cdataElement( 'id',    $member->getId() );
            $inWriter->cdataElement( 'title', $member->{name} );

            $this->_writeSummary_typeInfo( $inWriter, $member, $inSummaryData );

            $inWriter->endTag('item');
        }
    }

    # do this anyhow, even if the current class has no members for this type
    # we want to show inherited members
    my $hasInheritedMembers = 0;
    if ($inMemberType) {
        $hasInheritedMembers =
          $this->_writeInheritedMemberList( $inWriter, $inClassData,
            $inMemberType );
    }

    if ( ( $members && scalar @{$members} ) || $hasInheritedMembers ) {
        $inWriter->cdataElement( 'title', $inTitle );
    }

    $inWriter->endTag('memberSummaryPart');
}

=pod

_writeSummary_typeInfo( $writer, $memberData )

<typeInfo member="property">
	<returnType>
		<![CDATA[Number]]>
	</returnType>
	<typeInfoString>
		<![CDATA[ : Number]]>
	</typeInfoString>
</typeInfo>

=cut

sub _writeSummary_typeInfo {
    my ( $this, $inWriter, $inMember, $inSummaryData ) = @_;

    # functionParameters
    # returnType
    # typeInfoString
    # summary
    # typeInfo

    my $memberType =
        $inMember->isa("VisDoc::PropertyData")
      ? $this->_docTerm('memberproperty_property')
      : '';

    my $memberFormatter =
      VisDoc::MemberFormatterFactory::getMemberFormatterForLanguage(
        $this->{language} );

    $inWriter->startTag( 'typeInfo', 'member' => $memberType );

    # type info (or member signature)
    # for example:
    # (faceSize:Number = 200) : void
    my $typeInfoString = $memberFormatter->typeInfo($inMember);

    if ( $typeInfoString && $typeInfoString ne '' ) {
        $typeInfoString =
          $this->{data}->{fileData}->getContents($typeInfoString);

        $inWriter->cdataElement( 'typeInfoString', $typeInfoString )
          if $typeInfoString;
        $inSummaryData->{hasTypeInfo} += 1;
    }

    # summary
    my $description = $inMember->{javadoc}->getDescription()
      if $inMember->{javadoc};
    if ($description) {
        my ( $beforeFirstLineTag, $summaryLine, $rest ) =
          $this->{data}->{fileData}->getDescriptionParts($description);
        if ($summaryLine) {
            VisDoc::StringUtils::stripHtml($summaryLine);
            $inWriter->cdataElement( 'summary', $summaryLine );
            $inSummaryData->{hasSummary} += 1;
        }
    }

    $inWriter->endTag('typeInfo');
}

=pod

_isPartPrivate( \@memberData ) -> $text

Returns false if one of the members is not private.

=cut

sub _isPartPrivate {
    my ( $this, $inMemberData ) = @_;

	foreach my $member ( @{$inMemberData} ) {
		return 0 if $member->isPublic();
	}
	
    return 1;
}

=pod

_constructSummaryForPart( $writer, $classData, $partName ) -> \@memberType

@param $partName: 'constructors', 'properties', etcetera (see _writeSummary)

Members should already be sorted by the order in the class file

=cut

sub _getMembersForPart {
    my ( $this, $inClassData, $inPartName ) = @_;

    my $members;
    $members = $inClassData->getConstructors()
      if ( $inPartName eq 'constructors' );
    $members = $inClassData->getInnerClasses()
      if ( $inPartName eq 'innerclasses' );
    $members = $inClassData->getNamespaces() if ( $inPartName eq 'namespaces' );
    $members = $inClassData->getConstants()  if ( $inPartName eq 'constants' );
    $members = $inClassData->getInstanceMethods()
      if ( $inPartName eq 'instancemethods' );
    $members = $inClassData->getClassProperties()
      if ( $inPartName eq 'classproperties' );
    $members = $inClassData->getClassMethods()
      if ( $inPartName eq 'classmethods' );
    $members = $inClassData->getInstanceProperties()
      if ( $inPartName eq 'instanceproperties' );

# unless we explicitely list event handlers, remove any event handler from the current list
# TODO

    if ( !$this->{preferences}->{listPrivate} ) {
        my $publicMembers;
        foreach my $member ( @{$members} ) {
            if ( $member->isPublic() ) {
                push( @{$publicMembers}, $member );
            }
        }
        $members = $publicMembers;
    }

    #use Data::Dumper;
    #print "members=" . Dumper($members);

    return $members;
}

=pod

_writeInheritedMemberList( $classData, $memberType ) -> $bool

=cut

sub _writeInheritedMemberList {
    my ( $this, $inWriter, $inClassData, $inMemberType ) = @_;

    return 0 if ( $inMemberType eq 'constructors' );

    my $hasInheritedMembers = 0;

    my $superclasses;
    if ( $inClassData->{type} & $VisDoc::ClassData::TYPE->{'CLASS'} ) {
    	$superclasses = $inClassData->getSuperclassChain();
    } elsif ( $inClassData->{type} & $VisDoc::ClassData::TYPE->{'INTERFACE'} ) {
    	$superclasses = $inClassData->getSuperInterfaceChain();
    }
    
    my $currentMembers = $this->_getMembersForPart( $inClassData, $inMemberType );
    my $currentMembersNameHash = {};
    foreach my $member (@{$currentMembers}) {
    	$currentMembersNameHash->{ $member->getName() } = 1;
    }

    foreach my $superclass ( @{$superclasses} ) {

        my $classDataRef       = $superclass->{classdata};
        my $privateMemberCount = 0;

        if ( $classDataRef && $classDataRef->isa("VisDoc::ClassData") ) {
        
            my $members =
              $this->_getMembersForPart( $classDataRef, $inMemberType );

            if ( $members && scalar @{$members} ) {


                # sort array on method name
                @{$members} = sort { $a->{name} cmp $b->{name} } @{$members};
                
                # filter out members that are already in the current member list
				@{$members} = grep { !$currentMembersNameHash->{ $_->getName() } } @{$members};

				# add the current members to the hash for next iteration
				foreach my $member (@{$members}) {
					$currentMembersNameHash->{ $member->getName() } = 1;
				}
	
				if ( $members && scalar @{$members} ) {
    
                    $hasInheritedMembers = 1;

					$inWriter->startTag('inheritedMethods');
					$inWriter->startTag('fromClass');
	
					my $titleKey = "header_summary_inherited$inMemberType";
					my $title    = $this->_docTerm($titleKey);
	
					$inWriter->startTag('title');
					$inWriter->cdataElement( 'text', $title );
					my $superclassURI = VisDoc::ClassData::createUriForClass(
						$superclass->{classpath} );
					$this->_writeLinkXml( $inWriter, $classDataRef->{name},
						$superclassURI );
					$inWriter->endTag('title');
	
					foreach my $member ( @{$members} ) {
	
						$inWriter->startTag('item');
	
						$this->_writeLinkXml(
							$inWriter,
							$member->{name},
							$superclassURI,
							{
								memberName => $member->getId()
							}
						);
						if ( !$member->isPublic() ) {
							$inWriter->startTag('private');
							$inWriter->endTag('private');
						}
						$inWriter->endTag('item');
					}
	
					$inWriter->endTag('fromClass');
					$inWriter->endTag('inheritedMethods');
				}
            }
        }
    }
    return $hasInheritedMembers;
}

=pod

=cut

sub _writeMembers {
    my ( $this, $inWriter ) = @_;

    my $callToCreateMemberSection = sub {
        my ( $inKey, $inTitleKey ) = @_;

        $this->_writeMembers_forMemberGroup( $inWriter, $this->{data}, $inKey,
            $inTitleKey );
    };

    $inWriter->startTag('memberSections');

    &$callToCreateMemberSection( 'innerclasses',    'header_innerclasses' );
    &$callToCreateMemberSection( 'constructors',    'header_constructor' );
    &$callToCreateMemberSection( 'namespaces',      'header_namespaces' );
    &$callToCreateMemberSection( 'constants',       'header_constants' );
    &$callToCreateMemberSection( 'classproperties', 'header_classproperties' );
    &$callToCreateMemberSection( 'instanceproperties',
        'header_instanceproperties' );
    &$callToCreateMemberSection( 'classmethods',    'header_classmethods' );
    &$callToCreateMemberSection( 'instancemethods', 'header_instancemethods' );
    &$callToCreateMemberSection( 'eventhandlers',   'header_eventhandlers' );

    $inWriter->endTag('memberSections');
}

=pod

=cut

sub _writeMembers_forMemberGroup {
    my ( $this, $inWriter, $inClassData, $inPartName, $inTitleKey ) = @_;

    my $members = $this->_getMembersForPart( $inClassData, $inPartName );

    if ( $members && scalar @{$members} ) {

		my $isPrivatePart = $this->_isPartPrivate( $members );	
		
		$inWriter->startTag('memberSection', 'private' => $isPrivatePart ? 1 : 0);
		
        my $title = $this->_docTerm($inTitleKey);
        $inWriter->cdataElement( 'title', $title );
        $title =~ s/ //go;
        $inWriter->cdataElement( 'id', $title );

        # sort array on method name
        @{$members} = sort { $a->{name} cmp $b->{name} } @{$members};

        foreach my $member ( @{$members} ) {

            $this->_writeMembers_forMemberGroup_memberText( $inWriter,
                $member );
        }

        $inWriter->endTag('memberSection');
    }
}

=pod

=cut

sub _writeMembers_forMemberGroup_memberText {
    my ( $this, $inWriter, $inMember ) = @_;

    return if $inMember->isExcluded();
    return if !$this->{preferences}->{listPrivate} && !$inMember->isPublic();

    my $isInnerClass = $inMember->{isInnerClass};
    $inWriter->startTag('member', 'private' => $inMember->isPublic() ? 0 : 1); # if !$isInnerClass;
#    $inWriter->startTag('class')  if $isInnerClass;

    $inWriter->cdataElement( 'id', $inMember->getId());

    my $link = $inMember->{name};

    $inWriter->startTag('title');
    if ($isInnerClass) {

        # $link = $inMember->{innerClassReference};
    }
    else {
        $inWriter->characters($link);
    }
    $inWriter->endTag('title');
    $this->_writeMembers_forMemberGroup_memberText_fullMethod( $inWriter,
        $inMember );
    $this->_writeMembers_forMemberGroup_memberText_description( $inWriter,
        $inMember );
    $this->_writeMembers_forMemberGroup_memberText_fields( $inWriter,
        $inMember );

    $inWriter->endTag('member'); # if !$isInnerClass;
#    $inWriter->endTag('class')  if $isInnerClass;

}

=pod

=cut

sub _writeMembers_forMemberGroup_memberText_fullMethod {
    my ( $this, $inWriter, $inMember ) = @_;

    my $memberFormatter =
      VisDoc::MemberFormatterFactory::getMemberFormatterForLanguage(
        $this->{language} );

    $inWriter->startTag('fullMemberString', 'private' => $inMember->isPublic() ? 0 : 1);

    my $leftString  = $memberFormatter->fullMemberStringLeft($inMember);
    my $rightString = $memberFormatter->fullMemberStringRight($inMember);

    # resolve link references
    $leftString  = $this->{data}->{fileData}->getContents($leftString);
    $rightString = $this->{data}->{fileData}->getContents($rightString);

    my $leftTextNoHtml = $leftString;
    VisDoc::StringUtils::stripHtml($leftTextNoHtml);

    my $spaceCount = length $leftTextNoHtml;
    my $linefiller = " " x $spaceCount;

    my $memberString = $leftString . $rightString;
    $memberString =~ s/\n/\n$linefiller/g;

    $inWriter->cdataElement( 'memberString', $memberString  );

    if ( $inMember->isa("VisDoc::PropertyData") ) {
        my $getSetString = $memberFormatter->getSetString(
            $inMember,
            $this->_docTerm('read'),
            $this->_docTerm('write')
        );
        $inWriter->cdataElement( 'access', $getSetString ) if $getSetString;
    }

    $inWriter->endTag('fullMemberString');
}

=pod

<description>
	<fields>
		<field>
			<title>
				<![CDATA[Deprecated]]>
			</title>
			<description>
				<item>
					<value>
						<![CDATA[ As of JDK 1.1., see <a href="AllTags.html#method_D">method_D</a>. ]]>
					</value>
				</item>
			</description>
		</field>
	</fields>
	<text>
		<![CDATA[ 	Example of <b>supported</b> Javadoc tags. Inline tags: <b>@code:</b> <code>I can use &lt;html&gt; inside here &lt;hr&gt;</code>, <b>@inheritDoc</b>, <b>@link:</b> <a href="AllTags.html#method_A">link to method A</a>, <b>@literal:</b> I can use &lt;html&gt; inside here and even <br /><br /><br />some newlines. ]]>
	</text>
</description>

=cut

sub _writeMembers_forMemberGroup_memberText_description {
    my ( $this, $inWriter, $inMember ) = @_;

    return if !$inMember->{javadoc};

    my $fields      = $inMember->{javadoc}->fieldsWithName('deprecated');
    my $description = $inMember->{javadoc}->getDescription();

    return if !$fields && !$description;
	
    $inWriter->startTag('description');

    if ($fields) {
        $this->_writeFieldValue( $inWriter, 'deprecated', $fields );
    }

    # description text
    $inWriter->cdataElement('text', $this->{data}->{fileData}->getContents($description));

    $inWriter->endTag('description');
}

=pod

<fields>
	<paramfield>
		<name>
			<![CDATA[inValue]]>
		</name>
		<description>
			<![CDATA[The amount of force]]>
		</description>
	</paramfield>
	<field>
		<title>
			<![CDATA[Implementation note]]>
		</title>
		<description>
			<item>
				<value>
					<![CDATA[ This method invokes <code><span class="codeIdentifier">setInterval</span></code>. ]]>
				</value>
			</item>
		</description>
	</field>
</fields>

=cut

sub _writeMembers_forMemberGroup_memberText_fields {
    my ( $this, $inWriter, $inMember ) = @_;

    return if !$inMember->{javadoc};

    # other fields
    my $allFields = $inMember->{javadoc}->getAllFieldsGroupedByName();
	
    my @keys = sort keys %{$allFields};

    my $doneFields     = 'description';
    my $excludedFields = 'deprecated|exclude|private';
    my $privateFields =
      'class|property|method|helpid|tiptext|link|inheritDoc|img';

    my $excludePattern = "$doneFields|$excludedFields|$privateFields";
    my @fieldKeys;
    map { push( @fieldKeys, $_ ) if !( $_ =~ m/($excludePattern)/ ); } @keys;

    my $metadataFields = $inMember->{metadata};

#    $inWriter->startTag('fields');

    # meta fields
    $this->_writeMetadataFields( $inWriter, 'metadata', $metadataFields )
      if $metadataFields && scalar @{$metadataFields};

    # param fields
    my $paramFields = $inMember->{javadoc}->{params};

    $this->_writeParamFields( $inWriter, 'param', $paramFields )
      if $paramFields && scalar @{$paramFields};

    foreach my $key (@fieldKeys) {
        my $fields = $allFields->{$key};
        $this->_writeFieldValue( $inWriter, $key, $fields ) if $fields;
    }

#    $inWriter->endTag('fields');
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
