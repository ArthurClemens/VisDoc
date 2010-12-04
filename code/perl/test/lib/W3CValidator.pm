# Copyright (C) 2005 Crawford Currie, http://www.c-dot.co.uk
#
# This code is licensed under the terms of the GNU General Public License
# version 2. This notice must be retained in all derivatives or copies.
#
# Programmatic interface to the W3C validation service
# To use this object:
#
# use W3CValidator;
#
# my $tv = new W3CValidator
# unless( $tv->validateFile( "fileondisc.html" )) {
#     print "not valid\n";
# }
# unless( $tv->validateURL( "http://myinternetserver/bin/view/My/Topic" )) {
#    print "not valid\n";
# }
#
# Notes:
#    * The validation is against the doctype specified in the file/URL
#    * The HTML results of the last validation are available from
#    * $tv->{details}
#    * URLs must be visible from the internet. Intranet URLs won't work.
#
package W3CValidator;

use strict;
use LWP::UserAgent;

sub new {
    my $class = shift;
    my $this = bless( {}, $class );

    $this->{ua} = LWP::UserAgent->new;
    $this->{ua}->agent("W3CValidator ");

    return $this;
}

# PRIVATE check the results
sub _checkResponse {
    my( $this, $response ) = @_;

    if( $response->is_redirect ) {
        $response = $this->{ua}->get( $response->header( "Location" ));
    }

    return "Network error: ", $response->request->uri,
      " -- ", $response->status_line, "\nAborting\n", $response->as_string
        unless $response->is_success;

    $this->{details} = $response->content();
    if ( $this->{details} =~ /was checked and found to be valid/ ) {
        return 1;
    }

    return 0;
}

# Perform validation check on a disk file
# return 0 for invalid content
sub validateFile {
    my ( $this, $file ) = @_;

    my $response =
      $this->{ua}->post( 'http://validator.w3.org/check',
                        [
                         uploaded_file => [ $file ],
                         charset => "%28detect%20automatically%29",
                         fbc => 1,
                         doctype => "%28detect%20automatically%29",
                         fbd => 1,
                         ss => 0,
                         outline => 0,
                         sp => 0,
                         noatt => 0,
                         No200 => 0,
                         verbose => 0
                        ],
                        'Content_type' => "form-data" );

    return $this->_checkResponse( $response );
}

# Perform validation check on a URL
# return 0 for invalid content
sub validateURL {
    my ( $this, $url ) = @_;

    my $response =
      $this->{ua}->post( 'http://validator.w3.org/check',
                         [
                          uri => $url,
                          charset => "%28detect%20automatically%29",
                          fbc => 1,
                          doctype => "%28detect%20automatically%29",
                          fbd => 1,
                          ss => 0,
                          outline => 0,
                          sp => 0,
                          noatt => 0,
                          No200 => 0,
                          verbose => 0
                         ],
                         'Content_type' => "form-data" );

    return $this->_checkResponse( $response );
}

1;
