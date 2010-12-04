package VisDoc::FormatterAS2;
use base 'VisDoc::FormatterBase';

use strict;
use warnings;
use List::Util qw(first);

=pod

=cut

sub new {
    my ($class) = @_;
    my VisDoc::FormatterAS2 $this = $class->SUPER::new();

    $this->{LANGUAGE} = 'as2';
    $this->{syntax}   = {
        keywords =>
'\bwith\b|\bwhile\b|\bvoid\b|\bvar\b|\btypeof\b|\btry\b|\bthrow\b|\breturn\b|\bor\b|\bonClipEvent\b|\bon\b|\bnot\b|\bnew\b|\bne\b|\blt\b|\ble\b|\binstanceof\b|\bin\b|\bif\b|\bgt\b|\bge\b|\bfunction\b|\bfor\b|\bfinally\b|\beq\b|\belse\b|\bdo\b|\bdelete\b|\bcontinue\b|\bcatch\b|\bbreak\b|\band\b|\badd\b|\b#include\b',
        identifiers =>
'\bXMLSocket\b|\bXMLNode\b|\bXML\b|\bVoid\b|\bVideo\b|\bupdateAfterEvent\b|\bunloadMovieNum\b|\bunloadMovie\b|\bunload\b|\bunescape\b|\bundefined\b|\btrue\b|\btrace\b|\btoggleHighQuality\b|\bthis\b|\bTextSnapshot\b|\bTextFormat\b|\bTextField\b|\btellTarget\b|\btargetPath\b|\btabIndex\b|\btabEnabled\b|\btabChildren\b|\bSystem\.useCodepage\b|\bSystem\.security\b|\bSystem\.capabilities\b|\bSystem\.capabilities\b|\bSystem\b|\bsubstring\b|\bStyleSheet\b|\bString\.fromCharCode\b|\bString\b|\bstopDrag\b|\bstopAllSounds\b|\bstop\b|\bstartDrag\b|\bStage\.width\b|\bStage\.showMenu\b|\bStage\.scaleMode\b|\bStage\.height\b|\bStage\.align\b|\bSound\b|\bSharedObject\b|\bsetSelected\b|\bsetSelectColor\b|\bsetProperty\b|\bsetInterval\b|\bset\b|\bSelection\.setSelection\b|\bSelection\.setFocus\b|\bSelection\.getFocus\b|\bSelection\.getEndIndex\b|\bSelection\.getCaretIndex\b|\bSelection\.getBeginIndex\b|\brollOver\b|\brollOut\b|\bremoveMovieClip\b|\bremoveListener\b|\breleaseOutside\b|\brelease\b|\brandom\b|\bprintNum\b|\bPrintJob\b|\bprintAsBitmapNum\b|\bprintAsBitmap\b|\bprint\b|\bprevScene\b|\bprevFrame\b|\bpress\b|\bplay\b|\bparseInt\b|\bparseFloat\b|\bpaperWidth\b|\bpaperHeight\b|\bpageWidth\b|\bpageHeight\b|\borientation\b|\bord\b|\bonXML\b|\bonUnload\b|\bonSync\b|\bonStatus\b|\bonStatus\b|\bonSoundComplete\b|\bonSetFocus\b|\bonSelect\b|\bonScroller\b|\bonRollOver\b|\bonRollOut\b|\bonResize\b|\bonReleaseOutside\b|\bonRelease\b|\bonPress\b|\bonMouseWheel\b|\bonMouseUp\b|\bonMouseMove\b|\bonMouseDown\b|\bonLoadStart\b|\bonLoadProgress\b|\bonLoadInit\b|\bonLoadError\b|\bonLoadComplete\b|\bonLoad\b|\bonLoad\b|\bonKillFocus\b|\bonKeyUp\b|\bonKeyDown\b|\bonID3\b|\bonEnterFrame\b|\bonDragOver\b|\bonDragOut\b|\bonData\b|\bonConnect\b|\bonClose\b|\bonChanged\b|\bonActivity\b|\bObject\b|\bNumber\.POSITIVE_INFINITY\b|\bNumber\.NEGATIVE_INFINITY\b|\bNumber\.NaN\b|\bNumber\.MIN_VALUE\b|\bNumber\.MAX_VALUE\b|\bNumber\b|\bnull\b|\bnextScene\b|\bnextFrame\b|\bnewline\b|\bNetStream\b|\bNetConnection\b|\bMovieClipLoader\b|\bMovieClip\b|\bmouseUp\b|\bmouseMove\b|\bmouseDown\b|\bMouse\.show\b|\bMouse\.hide\b|\bMMExecute\b|\bMicrophone\b|\bmbsubstring\b|\bmbord\b|\bmblength\b|\bmbchr\b|\bMath\.tan\b|\bMath\.SQRT2\b|\bMath\.SQRT1_2\b|\bMath\.sqrt\b|\bMath\.sin\b|\bMath\.round\b|\bMath\.random\b|\bMath\.pow\b|\bMath\.PI\b|\bMath\.min\b|\bMath\.max\b|\bMath\.LOG2E\b|\bMath\.LOG10E\b|\bMath\.log\b|\bMath\.LN2\b|\bMath\.LN10\b|\bMath\.floor\b|\bMath\.exp\b|\bMath\.E\b|\bMath\.cos\b|\bMath\.ceil\b|\bMath\.atan2\b|\bMath\.atan\b|\bMath\.asin\b|\bMath\.acos\b|\bMath\.abs\b|\blocalToGlobal\b|\bLocalConnection\b|\bLoadVars\b|\bloadVariablesNum\b|\bloadVariables\b|\bloadMovieNum\b|\bloadMovie\b|\bload\b|\blength\b|\bkeyUp\b|\bkeyPress\b|\bkeyDown\b|\bKey\.UP\b|\bKey\.TAB\b|\bKey\.SPACE\b|\bKey\.SHIFT\b|\bKey\.RIGHT\b|\bKey\.PGUP\b|\bKey\.PGDN\b|\bKey\.LEFT\b|\bKey\.isToggled\b|\bKey\.isDown\b|\bKey\.INSERT\b|\bKey\.HOME\b|\bKey\.getCode\b|\bKey\.getAscii\b|\bKey\.ESCAPE\b|\bKey\.ENTER\b|\bKey\.END\b|\bKey\.DOWN\b|\bKey\.DELETEKEY\b|\bKey\.CONTROL\b|\bKey\.CAPSLOCK\b|\bKey\.BACKSPACE\b|\bKey\.ALT\b|\bisNaN\b|\bisFinite\b|\bint\b|\bInfinity\b|\bifFrameLoaded\b|\bhitTestTextNearPos\b|\bhitTest\b|\bhitArea\b|\bgotoAndStop\b|\bgotoAndPlay\b|\bglobalToLocal\b|\bgetVersion\b|\bgetURL\b|\bgetTimer\b|\bgetText\b|\bgetSelectedText\b|\bgetSelected\b|\bgetProperty\b|\bgetDepth\b|\bgetCount\b|\bgetBytesTotal\b|\bgetBytesLoaded\b|\bgetBounds\b|\bget\b|\bFunction\b|\bfscommand\b|\bfocusEnabled\b|\bfindText\b|\bfalse\b|\beval\b|\bescape\b|\bError\b|\benterFrame\b|\bduplicateMovieClip\b|\bdragOver\b|\bdragOut\b|\bDate\.UTC\b|\bDate\b|\bdata\b|\bCustomActions\.uninstall\b|\bCustomActions\.list\b|\bCustomActions\.install\b|\bCustomActions\.get\b|\bContextMenuItem\b|\bContextMenu\b|\bColor\b|\bclearInterval\b|\bchr\b|\bCamera\b|\bcall\b|\bButton\b|\bBoolean\b|\battachMovie\b|\bArray\.UNIQUESORT\b|\bArray\.RETURNINDEXEDARRAY\b|\bArray\.NUMERIC\b|\bArray\.DESCENDING\b|\bArray\.CASEINSENSITIVE\b|\bArray\b|\barguments\.caller\b|\barguments\.callee\b|\baddRequestHeader\b|\baddListener\b|\bAccessibility\.updateProperties\b|\bAccessibility\.isActive\b|\b<identifier text="super\b|\b<identifier text="_global\b|\b\.zoom\b|\b\.xmlDecl\b|\b\.wordWrap\b|\b\.windowlessDisable\b|\b\.width\b|\b\.width\b|\b\.watch\b|\b\.visible\b|\b\.version\b|\b\.variable\b|\b\.valueOf\b|\b\.useHandCursor\b|\b\.useEchoSuppression\b|\b\.url\b|\b\.unwatch\b|\b\.unshift\b|\b\.unloadMovie\b|\b\.unloadClip\b|\b\.underline\b|\b\.type\b|\b\.transform\b|\b\.trackAsMenu\b|\b\.toUpperCase\b|\b\.toString\b|\b\.toLowerCase\b|\b\.time\b|\b\.time\b|\b\.textWidth\b|\b\.textHeight\b|\b\.textFieldWidth\b|\b\.textFieldHeight\b|\b\.textColor\b|\b\.text\b|\b\.target\b|\b\.tabStops\b|\b\.swapDepths\b|\b\.substring\b|\b\.substr\b|\b\.styleSheet\b|\b\.stopDrag\b|\b\.stop\b|\b\.status\b|\b\.startDrag\b|\b\.start\b|\b\.start\b|\b\.split\b|\b\.splice\b|\b\.sortOn\b|\b\.sort\b|\b\.smoothing\b|\b\.smoothing\b|\b\.slice\b|\b\.size\b|\b\.silenceTimeOut\b|\b\.silenceLevel\b|\b\.showSettings\b|\b\.shift\b|\b\.setYear\b|\b\.setVolume\b|\b\.setUTCSeconds\b|\b\.setUTCMonth\b|\b\.setUTCMinutes\b|\b\.setUTCMilliseconds\b|\b\.setUTCHours\b|\b\.setUTCFullYear\b|\b\.setUTCDate\b|\b\.setUseEchoSuppression\b|\b\.setTransform\b|\b\.setTime\b|\b\.setTextFormat\b|\b\.setStyle\b|\b\.setSilenceLevel\b|\b\.setSeconds\b|\b\.setRGB\b|\b\.setRate\b|\b\.setQuality\b|\b\.setPan\b|\b\.setNewTextFormat\b|\b\.setMotionLevel\b|\b\.setMonth\b|\b\.setMode\b|\b\.setMinutes\b|\b\.setMilliseconds\b|\b\.setMask\b|\b\.setLoopback\b|\b\.setKeyFrameInterval\b|\b\.setHours\b|\b\.setGain\b|\b\.setFullYear\b|\b\.setFps\b|\b\.setDate\b|\b\.setClipboard\b|\b\.setBufferTime\b|\b\.setBufferTime\b|\b\.serverString\b|\b\.separatorBefore\b|\b\.sendAndLoad\b|\b\.send\b|\b\.send\b|\b\.send\b|\b\.selectable\b|\b\.seek\b|\b\.seek\b|\b\.scroll\b|\b\.screenResolutionY\b|\b\.screenResolutionX\b|\b\.screenDPI\b|\b\.screenColor\b|\b\.save\b|\b\.rightMargin\b|\b\.rewind\b|\b\.reverse\b|\b\.restrict\b|\b\.replaceText\b|\b\.replaceSel\b|\b\.removeTextField\b|\b\.removeNode\b|\b\.removeMovieClip\b|\b\.registerClass\b|\b\.receiveVideo\b|\b\.receiveAudio\b|\b\.rate\b|\b\.quality\b|\b\.quality\b|\b\.push\b|\b\.publish\b|\b\.prototype\b|\b\.print\b|\b\.previousSibling\b|\b\.prevFrame\b|\b\.position\b|\b\.pop\b|\b\.playerType\b|\b\.play\b|\b\.play\b|\b\.play\b|\b\.pixelAspectRatio\b|\b\.pause\b|\b\.pause\b|\b\.password\b|\b\.parseXML\b|\b\.parseCSS\b|\b\.parse\b|\b\.parentNode\b|\b\.os\b|\b\.nodeValue\b|\b\.nodeType\b|\b\.nodeName\b|\b\.nextSibling\b|\b\.nextFrame\b|\b\.names\b|\b\.name\b|\b\.name\b|\b\.muted\b|\b\.multiline\b|\b\.moveTo\b|\b\.moveTo\b|\b\.mouseWheelEnabled\b|\b\.motionTimeOut\b|\b\.motionLevel\b|\b\.message\b|\b\.menu\b|\b\.maxscroll\b|\b\.maxhscroll\b|\b\.maxChars\b|\b\.manufacturer\b|\b\.loopback\b|\b\.loop\b|\b\.localToGlobal\b|\b\.localFileReadDisable\b|\b\.loadVariables\b|\b\.loadSound\b|\b\.loadMovie\b|\b\.loaded\b|\b\.loadClip\b|\b\.load\b|\b\.liveDelay\b|\b\.lineTo\b|\b\.lineTo\b|\b\.lineStyle\b|\b\.length\b|\b\.leftMargin\b|\b\.leading\b|\b\.lastIndexOf\b|\b\.lastChild\b|\b\.language\b|\b\.keyFrameInterval\b|\b\.join\b|\b\.italic\b|\b\.isDebugger\b|\b\.isConnected\b|\b\.insertBefore\b|\b\.input\b|\b\.indexOf\b|\b\.index\b|\b\.indent\b|\b\.ignoreWhite\b|\b\.htmlText\b|\b\.html\b|\b\.hscroll\b|\b\.hitTest\b|\b\.hideBuiltInItems\b|\b\.height\b|\b\.height\b|\b\.height\b|\b\.hasVideoEncoder\b|\b\.hasStreamingVideo\b|\b\.hasStreamingAudio\b|\b\.hasScreenPlayback\b|\b\.hasScreenBroadcast\b|\b\.hasPrinting\b|\b\.hasMP3\b|\b\.hasEmbeddedVideo\b|\b\.hasChildNodes\b|\b\.hasAudioEncoder\b|\b\.hasAudio\b|\b\.hasAccessibility\b|\b\.gotoAndStop\b|\b\.gotoAndPlay\b|\b\.globalToLocal\b|\b\.getYear\b|\b\.getVolume\b|\b\.getUTCSeconds\b|\b\.getUTCMonth\b|\b\.getUTCMinutes\b|\b\.getUTCMilliseconds\b|\b\.getUTCHours\b|\b\.getUTCFullYear\b|\b\.getUTCDay\b|\b\.getUTCDate\b|\b\.getURL\b|\b\.getTransform\b|\b\.getTimezoneOffset\b|\b\.getTime\b|\b\.getTextSnapshot\b|\b\.getTextFormat\b|\b\.getTextExtent\b|\b\.getSWFVersion\b|\b\.getStyleNames\b|\b\.getStyle\b|\b\.getSize\b|\b\.getSeconds\b|\b\.getRGB\b|\b\.getRemote\b|\b\.getProgress\b|\b\.getPan\b|\b\.getNextHighestDepth\b|\b\.getNextDepth\b|\b\.getNewTextFormat\b|\b\.getMonth\b|\b\.getMinutes\b|\b\.getMilliseconds\b|\b\.getLocal\b|\b\.getInstanceAtDepth\b|\b\.getHours\b|\b\.getFullYear\b|\b\.getFontList\b|\b\.getDepth\b|\b\.getDay\b|\b\.getDate\b|\b\.getBytesTotal\b|\b\.getBytesLoaded\b|\b\.getBounds\b|\b\.get\b|\b\.gain\b|\b\.fps\b|\b\.forward_back\b|\b\.font\b|\b\.flush\b|\b\.firstChild\b|\b\.exactSettings\b|\b\.endFill\b|\b\.enabled\b|\b\.embedFonts\b|\b\.duration\b|\b\.duplicateMovieClip\b|\b\.domain\b|\b\.docTypeDecl\b|\b\.descent\b|\b\.deblocking\b|\b\.data\b|\b\.customItems\b|\b\.curveTo\b|\b\.curveTo\b|\b\.currentFps\b|\b\.currentFps\b|\b\.createTextNode\b|\b\.createTextField\b|\b\.createEmptyMovieClip\b|\b\.createEmptyMovieClip\b|\b\.createElement\b|\b\.copy\b|\b\.contentType\b|\b\.connect\b|\b\.connect\b|\b\.connect\b|\b\.condenseWhite\b|\b\.concat\b|\b\.color\b|\b\.close\b|\b\.close\b|\b\.close\b|\b\.cloneNode\b|\b\.clear\b|\b\.clear\b|\b\.clear\b|\b\.clear\b|\b\.clear\b|\b\.childNodes\b|\b\.charCodeAt\b|\b\.charAt\b|\b\.caption\b|\b\.call\b|\b\.call\b|\b\.bytesTotal\b|\b\.bytesLoaded\b|\b\.bullet\b|\b\.builtInItems\b|\b\.bufferTime\b|\b\.bufferTime\b|\b\.bufferLength\b|\b\.bufferLength\b|\b\.bottomScroll\b|\b\.borderColor\b|\b\.border\b|\b\.bold\b|\b\.beginGradientFill\b|\b\.beginFill\b|\b\.bandwidth\b|\b\.backgroundColor\b|\b\.background\b|\b\.avHardwareDisable\b|\b\.autoSize\b|\b\.attributes\b|\b\.attachVideo\b|\b\.attachVideo\b|\b\.attachSound\b|\b\.attachMovie\b|\b\.attachAudio\b|\b\.ascent\b|\b\.apply\b|\b\.appendChild\b|\b\.allowInsecureDomain\b|\b\.allowDomain\b|\b\.align\b|\b\.addProperty\b|\b\.addPage\b|\b\.activityLevel\b|\b\.__proto__\b|\b-Infinity\b|\b_root\b|\b_parent\b|\b_level\b',
        properties =>
'\bwith\b|\bwhile\b|\bvoid\b|\bvar\b|\btypeof\b|\btry\b|\bthrow\b|\bswitch\b|\bstatic\b|\breturn\b|\bpublic\b|\bprivate\b|\bor\b|\bonClipEvent\b|\bon\b|\bnot\b|\bnew\b|\bne\b|\blt\b|\ble\b|\binterface\b|\binstanceof\b|\bin\b|\bimport\b|\bimplements\b|\bif\b|\bgt\b|\bge\b|\bfunction\b|\bfor\b|\bfinally\b|\bextends\b|\beq\b|\belse\b|\bdynamic\b|\bdo\b|\bdelete\b|\bdefault\b|\bcontinue\b|\bclass\b|\bcatch\b|\bcase\b|\bbreak\b|\band\b|\badd\b|\b#initclip\b|\b#include\b|\b#endinitclip\b',
    };
    bless $this, $class;
    return $this;
}

=pod

_isDefaultAccess( \@access ) -> $bool

Returns 1 if access is empty or contains 'public'.

=cut

sub _isDefaultAccess {
    my ( $this, $inAccess ) = @_;

    return 1 if !$inAccess;
    return 1 if !( scalar @{$inAccess} );
    return 1 if List::Util::first { $_ eq 'public' } @{$inAccess};
    return 0;
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
