# See bottom of file for license and copyright information

package VisDoc::Time;

use strict;
use warnings;

# Constants
our @ISOMONTH = (
    'January', 'February', 'March',     'April',   'May',      'June',
    'July',    'Augustus', 'September', 'October', 'November', 'December'
);

# SMELL: does not account for leap years
our @MONTHLENS = ( 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 );

our @WEEKDAY = (
    'Sunday',   'Monday', 'Tuesday',  'Wednesday',
    'Thursday', 'Friday', 'Saturday', 'Sunday'
);

our %MON2NUM = (
    jan => 0,
    feb => 1,
    mar => 2,
    apr => 3,
    may => 4,
    jun => 5,
    jul => 6,
    aug => 7,
    sep => 8,
    oct => 9,
    nov => 10,
    dec => 11
);

our $TZSTRING;    # timezone string for servertime; "Z" or "+01:00" etc.

#Tuesday, 05 December 2006, 12:29:42
our $DEFAULT_DATE_FORMAT         = '$wday, $day $month $year, $hour:$min:$sec';
our $DEFAULT_DISPLAY_TIME_VALUES = 'gmtime';

sub formatTime {
    my ( $epochSeconds, $formatString, $outputTimeZone ) = @_;
    my $value = $epochSeconds;

    $formatString   ||= $DEFAULT_DATE_FORMAT;
    $outputTimeZone ||= $DEFAULT_DISPLAY_TIME_VALUES;

    if ( $formatString =~ /http|email/i ) {
        $outputTimeZone = 'gmtime';
    }

    my ( $sec, $min, $hour, $day, $mon, $year, $wday );
    if ( $outputTimeZone eq 'servertime' ) {
        ( $sec, $min, $hour, $day, $mon, $year, $wday ) =
          localtime($epochSeconds);
    }
    else {
        ( $sec, $min, $hour, $day, $mon, $year, $wday ) = gmtime($epochSeconds);
    }

    #standard date time formats
    if ( $formatString =~ /rcs/i ) {

        # RCS format, example: "2001/12/31 23:59:59"
        $formatString = '$year/$mo/$day $hour:$min:$sec';
    }
    elsif ( $formatString =~ /http|email/i ) {

        # HTTP and email header format, e.g. "Thu, 23 Jul 1998 07:21:56 EST"
        # RFC 822/2616/1123
        $formatString = '$wday, $day $month $year $hour:$min:$sec $tz';
    }
    elsif ( $formatString =~ /iso/i ) {

        # ISO Format, see spec at http://www.w3.org/TR/NOTE-datetime
        # e.g. "2002-12-31T19:30:12Z"
        $formatString = '$year-$mo-$dayT$hour:$min:$sec$isotz';
    }

    $value = $formatString;
    $value =~ s/\$seco?n?d?s?/sprintf('%.2u',$sec)/gei;
    $value =~ s/\$minu?t?e?s?/sprintf('%.2u',$min)/gei;
    $value =~ s/\$hour?s?/sprintf('%.2u',$hour)/gei;
    $value =~ s/\$day/sprintf('%.2u',$day)/gei;
    $value =~ s/\$wday/$WEEKDAY[$wday]/gi;
    $value =~ s/\$dow/$wday/gi;
    $value =~ s/\$week/_weekNumber($day,$mon,$year,$wday)/egi;
    $value =~ s/\$mont?h?/$ISOMONTH[$mon]/gi;
    $value =~ s/\$mo/sprintf('%.2u',$mon+1)/gei;
    $value =~ s/\$year?/sprintf('%.4u',$year+1900)/gei;
    $value =~ s/\$ye/sprintf('%.2u',$year%100)/gei;
    $value =~ s/\$epoch/$epochSeconds/gi;

    if ( $value =~ /\$tz/ ) {
        my $tz_str;
        if ( $outputTimeZone eq 'servertime' ) {
            ( $sec, $min, $hour, $day, $mon, $year, $wday ) =
              localtime($epochSeconds);

            # SMELL: how do we get the different timezone strings (and when
            # we add usertime, then what?)
            $tz_str = 'Local';
        }
        else {
            ( $sec, $min, $hour, $day, $mon, $year, $wday ) =
              gmtime($epochSeconds);
            $tz_str = 'GMT';
        }
        $value =~ s/\$tz/$tz_str/gei;
    }
    if ( $value =~ /\$isotz/ ) {
        my $tz_str = 'Z';
        if ( $outputTimeZone ne 'gmtime' ) {

            # servertime
            # time zone designator (+hh:mm or -hh:mm)
            # cached.
            unless ( defined $TZSTRING ) {
                my $offset = _tzOffset();
                my $sign = ( $offset < 0 ) ? '-' : '+';
                $offset = abs($offset);
                my $hours = int( $offset / 3600 );
                my $mins = int( ( $offset - $hours * 3600 ) / 60 );
                if ( $hours || $mins ) {
                    $TZSTRING = sprintf( "$sign%02d:%02d", $hours, $mins );
                }
                else {
                    $TZSTRING = 'Z';
                }
            }
            $tz_str = $TZSTRING;
        }
        $value =~ s/\$isotz/$tz_str/gei;
    }

    return $value;
}

# Get timezone offset from GMT in seconds
# Code taken from CPAN module 'Time' - "David Muir Sharnoff disclaims
# any copyright and puts his contribution to this module in the public
# domain."
# Note that unit tests rely on this function being here.
sub _tzOffset {
    my $time = time();
    my @l    = localtime($time);
    my @g    = gmtime($time);

    my $off = $l[0] - $g[0] + ( $l[1] - $g[1] ) * 60 + ( $l[2] - $g[2] ) * 3600;

    # subscript 7 is yday.

    if ( $l[7] == $g[7] ) {

        # done
    }
    elsif ( $l[7] == $g[7] + 1 ) {
        $off += 86400;
    }
    elsif ( $l[7] == $g[7] - 1 ) {
        $off -= 86400;
    }
    elsif ( $l[7] < $g[7] ) {

        # crossed over a year boundary.
        # localtime is beginning of year, gmt is end
        # therefore local is ahead
        $off += 86400;
    }
    else {
        $off -= 86400;
    }

    return $off;
}

sub _weekNumber {
    my ( $day, $mon, $year, $wday ) = @_;

    require Time::Local;

    # calculate the calendar week (ISO 8601)
    my $nextThursday =
      Time::Local::timegm( 0, 0, 0, $day, $mon, $year ) +
      ( 3 - ( $wday + 6 ) % 7 ) * 24 * 60 * 60;    # nearest thursday
    my $firstFourth =
      Time::Local::timegm( 0, 0, 0, 4, 0, $year );    # january, 4th
    return
      sprintf( '%.0f', ( $nextThursday - $firstFourth ) / ( 7 * 86400 ) ) + 1;
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
