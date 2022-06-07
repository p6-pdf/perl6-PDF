use v6;
use Test;
plan 6;

use PDF::Class;
use PDF::Grammar::PDF;
use PDF::Grammar::PDF::Actions;
use PDF::IO::IndObj;

my $input = q:to"--END--";
42 0 obj <<
    /Type /Group
    /S /Transparency
    /I true
    /CS /DeviceRGB
>>
endobj
--END--

my PDF::Grammar::PDF::Actions $actions .= new: :lite;
PDF::Grammar::PDF.parse($input, :$actions, :rule<ind-obj>)
    // die "parse failed: $input";
my %ast = $/.ast;

my PDF::IO::IndObj $ind-obj .= new( :$input, |%ast );
my $group-obj = $ind-obj.object;
isa-ok $group-obj, 'PDF::Group';
is $group-obj.Type, 'Group', 'Group Type';
is $group-obj.S, 'Transparency', 'Subtype';
is $group-obj.I, True, 'I';
is $group-obj.CS, 'DeviceRGB', 'CS';
lives-ok {$group-obj.check}, '$group-obj.check lives';

done-testing;
