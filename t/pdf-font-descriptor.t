use v6;
use Test;

plan 10;

use PDF::Class;
use PDF::IO::IndObj;
use PDF::Grammar::Test :is-json-equiv;
use PDF::Grammar::PDF;
use PDF::Grammar::PDF::Actions;
use PDF::FontDescriptor;

my PDF::Grammar::PDF::Actions $actions .= new: :lite;

my $input = q:to"--END-OBJ--";
236 0 obj <<
    /Type /FontDescriptor
    /Ascent 898
    /CapHeight 0
    /Descent -210
    /Flags 4
    /FontBBox [ 0 -211 1359 899 ]
    /FontFamily (Wingdings)
    /FontFile2 227 0 R
    /FontName /MPAEJB+Wingdings-Regular
    /FontStretch /Normal
    /FontWeight 400
    /ItalicAngle 0
    /StemV 0
>> endobj
--END-OBJ--

PDF::Grammar::PDF.parse($input, :$actions, :rule<ind-obj>)
    // die "parse failed";
my %ast = $/.ast;
my $reader = class { has $.auto-deref = False }.new;
my PDF::IO::IndObj $ind-obj .= new( |%ast, :$reader);
is $ind-obj.obj-num, 236, '$.obj-num';
is $ind-obj.gen-num, 0, '$.gen-num';
my $font-descriptor-obj = $ind-obj.object;
does-ok $font-descriptor-obj, PDF::FontDescriptor;
is $font-descriptor-obj.Type, 'FontDescriptor', '$.Type accessor';
is $font-descriptor-obj.FontFamily, 'Wingdings', '$.FontFamily accessor';
is $font-descriptor-obj.Ascent, 898, '$.Ascent accessor';
is $font-descriptor-obj.CapHeight, 0, '$.CapHeight accessor';
is-json-equiv $font-descriptor-obj.FontBBox, [ 0, -211, 1359, 899, ], '$.CapHeight accessor';
lives-ok {$font-descriptor-obj.check}, '$font-descriptor-obj.check lives';
is-json-equiv $ind-obj.ast, %ast, 'ast regeneration';
