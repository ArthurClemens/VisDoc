use strict;
use warnings;
use diagnostics;

package MemberFormatterTests;
use base qw(Test::Unit::TestCase);

use VisDoc;
use VisDoc::MemberFormatterAS2;
use VisDoc::MemberFormatterAS3;
use VisDoc::MemberFormatterJava;

my $debug = 0;

sub new {
    my $self = shift()->SUPER::new(@_);

    return $self;
}

sub set_up {
    my ($this) = @_;

    VisDoc::FileData::initLinkDataRefs();
}

sub test_formatParameterData_as2 {
    my ($this) = @_;

    {
        my $varArgs = '';
        my $name    = 'drawing';
        my $type    = 'Canvas';
        my $value   = 'null';
        my $parameterData =
          VisDoc::ParameterData->new( $varArgs, $name, $type, $value );

        my $formatter =
          VisDoc::MemberFormatterFactory::getMemberFormatterForLanguage('as2');
        my $result   = $formatter->formatParameterData($parameterData);
        my $expected = 'drawing:Canvas = null';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {
        my $varArgs = '...args';
        my $name    = '';
        my $type    = '';
        my $value   = '';
        my $parameterData =
          VisDoc::ParameterData->new( $varArgs, $name, $type, $value );

        my $formatter =
          VisDoc::MemberFormatterFactory::getMemberFormatterForLanguage('as2');
        my $result   = $formatter->formatParameterData($parameterData);
        my $expected = '...args';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

sub test_formatParameterData_as3 {
    my ($this) = @_;

    {
        my $varArgs = '';
        my $name    = 'drawing';
        my $type    = 'Canvas';
        my $value   = 'null';
        my $parameterData =
          VisDoc::ParameterData->new( $varArgs, $name, $type, $value );

        my $formatter =
          VisDoc::MemberFormatterFactory::getMemberFormatterForLanguage('as3');
        my $result   = $formatter->formatParameterData($parameterData);
        my $expected = 'drawing:Canvas = null';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {
        my $varArgs = '...args';
        my $name    = '';
        my $type    = '';
        my $value   = '';
        my $parameterData =
          VisDoc::ParameterData->new( $varArgs, $name, $type, $value );

        my $formatter =
          VisDoc::MemberFormatterFactory::getMemberFormatterForLanguage('as2');
        my $result   = $formatter->formatParameterData($parameterData);
        my $expected = '...args';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

sub test_formatParameterData_java {
    my ($this) = @_;

    {
        my $varArgs = '';
        my $name    = 'args';
        my $type    = 'String[]';
        my $value   = '';
        my $parameterData =
          VisDoc::ParameterData->new( $varArgs, $name, $type, $value );

        my $formatter =
          VisDoc::MemberFormatterFactory::getMemberFormatterForLanguage('java');
        my $result   = $formatter->formatParameterData($parameterData);
        my $expected = 'String[] args';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {
        my $varArgs = '';
        my $name    = 'c';
        my $type    = 'Collection<?>';
        my $value   = '';
        my $parameterData =
          VisDoc::ParameterData->new( $varArgs, $name, $type, $value );

        my $formatter =
          VisDoc::MemberFormatterFactory::getMemberFormatterForLanguage('java');
        my $result   = $formatter->formatParameterData($parameterData);
        my $expected = 'Collection<?> c';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

sub test_memberSignature_as2 {
    my ($this) = @_;

    my $text = 'class A {

public static var ALARM : String = "alarm";	
public function insertIter(data:BinaryTreeObject,key:Number):Void {}
}
';

    my $fileParser = VisDoc::FileParser->new();
    my $fileData   = $fileParser->parseText( $text, 'as2' );
    my $classes    = $fileData->{packages}->[0]->{classes};
    my $properties = $classes->[0]->{properties};
    my $methods    = $classes->[0]->{methods};

    #use Data::Dumper;
    #print("properties=" . Dumper($properties));
    #print("methods=" . Dumper($methods));
    {
        my $propertyData = $properties->[0];

        my $formatter =
          VisDoc::MemberFormatterFactory::getMemberFormatterForLanguage('as2');
        my $result   = $formatter->typeInfo($propertyData);
        my $expected = ' : String';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {
        my $methodData = $methods->[0];

        my $formatter =
          VisDoc::MemberFormatterFactory::getMemberFormatterForLanguage('as2');
        my $result   = $formatter->typeInfo($methodData);
        my $expected = '(data:BinaryTreeObject, key:Number) : Void';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

sub test_memberSignature_as3 {
    my ($this) = @_;

    my $text = 'package {
class A {

public static const ALARM:String = "alarm";	
protected function insertIter(data:BinaryTreeObject = null,key:Number, ...rest):void {}
}
}
';

    my $fileParser = VisDoc::FileParser->new();
    my $fileData   = $fileParser->parseText( $text, 'as3' );
    my $classes    = $fileData->{packages}->[0]->{classes};
    my $properties = $classes->[0]->{properties};
    my $methods    = $classes->[0]->{methods};

    #use Data::Dumper;
    #print("properties=" . Dumper($properties));
    #print("methods=" . Dumper($methods));

    {
        my $propertyData = $properties->[0];

        my $formatter =
          VisDoc::MemberFormatterFactory::getMemberFormatterForLanguage('as3');
        my $result   = $formatter->typeInfo($propertyData);
        my $expected = ' : String';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {
        my $methodData = $methods->[0];

        my $formatter =
          VisDoc::MemberFormatterFactory::getMemberFormatterForLanguage('as3');
        my $result = $formatter->typeInfo($methodData);
        my $expected =
          '(data:BinaryTreeObject = null, key:Number, ...rest) : void';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

sub test_memberSignature_java {
    my ($this) = @_;

    my $text = 'class A {

public int x;	
public void SFSEvent(String[] args, Collection<?> c) {}
}
';

    my $fileParser = VisDoc::FileParser->new();
    my $fileData   = $fileParser->parseText( $text, 'java' );
    my $classes    = $fileData->{packages}->[0]->{classes};
    my $properties = $classes->[0]->{properties};
    my $methods    = $classes->[0]->{methods};

    #use Data::Dumper;
    #print("properties=" . Dumper($properties));
    #print("methods=" . Dumper($methods));

    {
        my $propertyData = $properties->[0];

        my $formatter =
          VisDoc::MemberFormatterFactory::getMemberFormatterForLanguage('java');
        my $result   = $formatter->typeInfo($propertyData);
        my $expected = 'int x';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
    {
        my $methodData = $methods->[0];

        my $formatter =
          VisDoc::MemberFormatterFactory::getMemberFormatterForLanguage('java');
        my $result   = $formatter->typeInfo($methodData);
        my $expected = 'void SFSEvent(String[] args, Collection<?> c)';
        print("RES=$result.\n")   if $debug;
        print("EXP=$expected.\n") if $debug;
        $this->assert( $result eq $expected );
    }
}

1;
