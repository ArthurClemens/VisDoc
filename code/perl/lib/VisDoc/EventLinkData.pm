# See bottom of file for license and copyright information

package VisDoc::EventLinkData;

use base 'VisDoc::LinkData';
use strict;
use warnings;
use VisDoc::Language;

=pod

=cut

sub createLinkData {
    my ( $inFieldName, $inValue, $inStub ) = @_;

    my $pattern = VisDoc::StringUtils::stripCommentsFromRegex(
        $VisDoc::StringUtils::PATTERN_TAG_PACKAGE_CLASS_METHOD_LABEL);

    $inValue =~ m/$pattern/s;
    my $packageName = $3 || undef;
    my $className   = $4 || undef;
    my $memberName  = $5 || undef;    
    my $params      = $6 || undef;
    my $label       = $7 || undef;

    # remove quotes from label at start and end
    $label =~ s/^\"(.*?)\"$/$1/ if $label;

    my $linkData = VisDoc::EventLinkData->new(
        $inFieldName, $inStub, $packageName, $className,
        $memberName,  $params, $label
    );
    return $linkData;
}
=pod

formatInlineLink( $documentType ) -> $html

Formats data to an inline link: <a href="...">...</a>

=cut

sub formatInlineLink {
    my ( $this, $inDocumentType ) = @_;

    my $label = $this->{label} || '';

    my $link = '';

	# do not hide link

	my $type = $inDocumentType || 'html';

	my $linkLabel = '';
	$linkLabel .= $this->{package} if $this->{package};
	if ( $this->{class} ) {
		$linkLabel .= '.' if $linkLabel;
		$linkLabel .= $this->{class};
	} elsif ( $this->{member} ) {
		$linkLabel .= '.' if $linkLabel;
		$linkLabel .= $this->{member};
		
		if ( $this->{params} ) {
			$linkLabel .= '(' . $this->{params} . ')';
		}
	}
	
	my $postLabel = '';
	if ( $this->{class} && $this->{member} ) {
		$postLabel .= VisDoc::Language::getDocTerm( 'event_type' ) . ' ' . '<code>' . $this->{member} . '</code>';
	}
	$label = '' if $label eq $linkLabel;
	$postLabel .= " $label" if $label;
	
	if ($this->{uri}) {
		my $url = $this->{uri};
		$url =~ s/(.*?)(#\w+|$)/$1.html$2/;
		my $classStr = $this->{isPublic} ? '' : " class=\"private\"";
		$link = "<a href=\"$url\"$classStr>$linkLabel</a> $postLabel";
	} else {
		$link = "$linkLabel $postLabel";
	}

    return $link;
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
