use strict;
use warnings;
use diagnostics;

package FormatterTests;
use base qw(Test::Unit::TestCase);

use VisDoc;
use VisDoc::FileParser;
use VisDoc::ParserBase;
use VisDoc::ParserAS2;
use VisDoc::ParserAS3;
use VisDoc::ParserJava;
use VisDoc::MethodData;
use VisDoc::PropertyData;
use VisDoc::StringUtils;

my $debug = 0;

sub new {
    my $self = shift()->SUPER::new(@_);

    return $self;
}

sub set_up {
    my ($this) = @_;

    VisDoc::FileData::initLinkDataRefs();
}

=pod

=cut

sub test_formatCodeText {
    my ($this) = @_;

    my $text = '<code>
// returns a float between 8 and 19, for example 7.87623
Random.between(8, 19, true);
</code>
';

    my $fileData = VisDoc::FileData->new();
    $fileData->{language} = 'as3';
    my $result   = $fileData->_formatCodeText($text);
    my $expected = '<pre>
&<span class="codeKeyword">lt</span>;code&<span class="codeKeyword">gt</span>;
<span class="codeComment">// returns a float between 8 and 19, for example 7.87623</span>
Random.between(<span class="codeNumber">8</span>, <span class="codeNumber">19</span>, <span class="codeIdentifier">true</span>);&<span class="codeKeyword">lt</span>;/code&<span class="codeKeyword">gt</span>;
</pre>';

    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_colorizeCode_1 {
    my ($this) = @_;

    my $text = '// returns a float between 8 and 19, for example 7.87623
Random.between(8, 19, true);';

    VisDoc::StringUtils::convertHtmlEntities($text);

    my $formatter = VisDoc::Formatter::formatter('as3');
    $formatter->colorize($text);

    my $result = $text;
    my $expected =
'<span class="codeComment">// returns a float between 8 and 19, for example 7.87623</span>
Random.between(<span class="codeNumber">8</span>, <span class="codeNumber">19</span>, <span class="codeIdentifier">true</span>);';

    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_colorizeCode_2 {
    my ($this) = @_;

    my $text = 'the numbers #ff0000, %26 and &#0123;';

    VisDoc::StringUtils::convertHtmlEntities($text);

    my $formatter = VisDoc::Formatter::formatter('as3');
    $formatter->colorize($text);

    my $result = $text;
    my $expected =
'the numbers #ff0000, <span class="codeNumber">%26</span> <span class="codeKeyword">and</span> <span class="codeNumber">&amp;#0123</span>;';

    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}

=pod

=cut

sub test_handleSquareBrackets {
    my ($this) = @_;

    my $text = '//returns "string1","string2","string3" or "string4" 
Random.Object(["string1","string2","string3","string4"]);';

    VisDoc::StringUtils::convertHtmlEntities($text);

    my $formatter = VisDoc::Formatter::formatter('as3');
    $formatter->colorize($text);

    my $result = $text;
    my $expected =
'<span class="codeComment">//returns &quot;string1&quot;,&quot;string2&quot;,&quot;string3&quot; or &quot;string4&quot; </span>
Random.<span class="codeIdentifier">Object</span>([&quot;string1&quot;,&quot;string2&quot;,&quot;string3&quot;,&quot;string4&quot;]);';

    print("RES=$result.\n")   if $debug;
    print("EXP=$expected.\n") if $debug;
    $this->assert( $result eq $expected );
}
1;
