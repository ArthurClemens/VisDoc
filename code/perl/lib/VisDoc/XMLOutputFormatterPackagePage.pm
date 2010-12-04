# See bottom of file for license and copyright information

package VisDoc::XMLOutputFormatterPackagePage;
use base 'VisDoc::XMLOutputFormatterClassPage';

use strict;
use warnings;
use XML::Writer();
use VisDoc::PackageData;

=pod

_formatData ($xmlWriter, $classData) -> $bool

=cut

sub _formatData {
    my ( $this, $inWriter ) = @_;

    $this->_writeAssetLocations($inWriter);
    $this->_writeTitleAndPageId($inWriter);
    $this->_writeClassData($inWriter);
	# do not write the summary
    $this->_writeMembers($inWriter);
    $this->_writeFooter($inWriter);

    return 1;
}

=pod

=cut

sub _writeClassData {
    my ( $this, $inWriter ) = @_;

    $inWriter->startTag('classData');
    $this->_writePackageTitle($inWriter);
    $this->_writeClassDetails($inWriter);
    $this->_writeClassDescription($inWriter);
    $inWriter->endTag('classData');
}

=pod

=cut

sub _writePackageTitle {
    my ( $this, $inWriter ) = @_;

    $inWriter->startTag('packageTitle');

    my $title =
        $this->{data}->{anonymous}
      ? $this->_docTerm('classproperty_anonymous_package')
      : $this->_docTerm('classproperty_package');
    $inWriter->cdataElement( 'title', $title );

    $inWriter->endTag('packageTitle');
}

=pod

Writes out: classpath and fields author and version (if defined)

=cut

sub _writeClassDetails {
    my ( $this, $inWriter ) = @_;

    $inWriter->startTag('classDetails');

    $this->_writeDetailsValue( $inWriter, undef, 'version',
        'classdetail_version' );
    $this->_writeDetailsValue( $inWriter, undef, 'author',
        'classdetail_author' );
    $this->_writeDetailsValue( $inWriter, $this->{data}->{name},
        undef, 'classdetail_classpath' );

    $inWriter->endTag('classDetails');
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

    &$callToWriteSummaryPart( 'classes',   'summary_classes' );
    &$callToWriteSummaryPart( 'functions', 'summary_functions' );

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

    $inWriter->endTag('memberList');
    $inWriter->endTag('pageSummary');
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
    &$callToCreateMemberSection( 'classes',   'header_classes' );
    &$callToCreateMemberSection( 'functions', 'header_functions' );
    $inWriter->endTag('memberSections');
}

=pod

=cut

sub _getMembersForPart {
    my ( $this, $inPackageData, $inPartName ) = @_;

    my $members;
    $members = $inPackageData->getClasses()
      if ( $inPartName eq 'classes' );
    $members = $inPackageData->getFunctions()
      if ( $inPartName eq 'functions' );

    if ( !$this->{preferences}->{listPrivate} ) {
        my $publicMembers;
        foreach my $member ( @{$members} ) {
            if ( $member->isPublic() ) {
                push( @{$publicMembers}, $member );
            }
        }
        $members = $publicMembers;
    }

    @{$members} = sort { $a->{name} cmp $b->{name} } @{$members} if $members;
    return $members;
}

=pod

=cut

sub _writeMembers_forMemberGroup_memberText {
    my ( $this, $inWriter, $inMember ) = @_;

    return if $inMember->isExcluded();
    return if !$this->{preferences}->{listPrivate} && !$inMember->isPublic();

    $inWriter->startTag('member');
    $inWriter->cdataElement( 'id', $inMember->getId() );

    if ( !$inMember->isPublic() ) {
        $inWriter->cdataElement( 'private', 'true' );
    }

    if ( $inMember->isa('VisDoc::ClassData') ) {
        $inWriter->startTag('title');
        $this->_writeLinkXml( $inWriter, $inMember->{name},
            $inMember->getUri() );
        $inWriter->endTag('title');
        $this->_writeMembers_forMemberGroup_memberText_description( $inWriter,
            $inMember );
    }
    if ( $inMember->isa('VisDoc::MemberData') ) {
        $inWriter->cdataElement( 'title', $inMember->{name} );

        $this->_writeMembers_forMemberGroup_memberText_fullMethod( $inWriter,
            $inMember );
        $this->_writeMembers_forMemberGroup_memberText_description( $inWriter,
            $inMember );
        $this->_writeMembers_forMemberGroup_memberText_fields( $inWriter,
            $inMember );
    }

=pod
    $this->_writeMembers_forMemberGroup_memberText_fullMethod($inWriter, $inMember);
    $this->_writeMembers_forMemberGroup_memberText_description($inWriter, $inMember);
=cut

    $inWriter->endTag('member');
}

=pod

Override: do not write the full description, only the summary.

=cut

sub _writeMembers_forMemberGroup_memberText_description {
    my ( $this, $inWriter, $inMember ) = @_;

    return if !$inMember->{javadoc};

    
    $inWriter->startTag('description');

	my $fields      = $inMember->{javadoc}->fieldsWithName('deprecated');
    
    if ($fields) {
        $this->_writeFieldValue( $inWriter, 'deprecated', $fields );
    }

    # description text
    my $summary =
          $this->getSummaryLine( $inMember->{javadoc}, $this->{data}->{fileData} ) || '';
          
    $inWriter->cdataElement('text', $summary);


    $inWriter->endTag('description');
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
