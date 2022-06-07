use v6;
use Test;

plan 46;

use PDF::IO::IndObj;
use PDF::Class;
use PDF::Grammar::Test :is-json-equiv;
use PDF::Grammar::PDF;
use PDF::Grammar::PDF::Actions;
use PDF::COS::Stream;
use PDF::Image;
use PDF::Content::FontObj;

my PDF::Grammar::PDF::Actions $actions .= new: :lite;

my $input = q:to"--END-OBJ--";
4 0 obj <<
  /Type /Page
  /Parent 3 0 R
  /Resources <<
    /Font << /F1 7 0 R >>
    /ProcSet 6 0 R
  >>
  /MediaBox [0 0 595 842]
>> endobj
--END-OBJ--

PDF::Grammar::PDF.parse($input, :$actions, :rule<ind-obj>)
    // die "parse failed";
my %ast = $/.ast;
my $reader = class { has $.auto-deref = False }.new;
my PDF::IO::IndObj $ind-obj .= new( |%ast, :$reader);
is $ind-obj.obj-num, 4, '$.obj-num';
is $ind-obj.gen-num, 0, '$.gen-num';
my $page = $ind-obj.object;
isa-ok $page, 'PDF::Page';
is $page.Type, 'Page', '$.Type accessor';
my  PDF::COS::Stream $dummy-stream .= new( :decoded('%dummy stream') );
is $page<Parent>, (:ind-ref[3, 0]), '$page<Parent>';
is $page.Resources, { :Font{ :F1( :ind-ref[7, 0] )}, :ProcSet( :ind-ref[6, 0]) }, '$.Resources accessor';

is-json-equiv $ind-obj.ast, %ast, 'ast regeneration';

$page.Contents = $dummy-stream;
is-deeply $page.Contents, ($dummy-stream), '$.Contents accessor';
is-deeply $page.contents, '%dummy stream', '$.contents accessor';

lives-ok {$page.Thumb = PDF::Image.open: "t/images/dna.small.gif"}, '$page.Thumb = $image - lives';
lives-ok {$page.Thumb.data-uri}, '$page.Thumb.data-uri - lives';

my PDF::Content::FontObj $font = $page.core-font( 'Helvetica' );
isa-ok $font.to-dict, 'PDF::Font::Type1';
is $font.font-name, 'Helvetica', '.font-name';
my PDF::Content::FontObj $font-again = $page.core-font( 'Helvetica' );
is-deeply $font-again, $font, 'core font caching';
is-deeply $font-again.WHICH, $font.WHICH, 'core font caching';
is-deeply [$page.Resources.Font.keys.sort], [<F1 F2>], 'font resource entries';
my PDF::Content::FontObj $font2 = $page.core-font( :family<Helvetica>, :weight<bold> );
is $font2.font-name, 'Helvetica-Bold', '.font-name';
is-deeply [$page.Resources.Font.keys.sort], [<F1 F2 F3>], 'font resource entries';

is-json-equiv $page.MediaBox, [0, 0, 595, 842], '$.MediaBox accessor';
is-json-equiv $page.media-box, [0, 0, 595, 842], '$.media-box accessor';
is-json-equiv $page.crop-box, $page.media-box, '$.crop-box accessor';
is-json-equiv $page.bleed-box, $page.media-box, '$.bleed-box accessor';
is-json-equiv $page.art-box, $page.crop-box, '$.art-box - accessor';
is-json-equiv $page.trim-box, $page.crop-box, '$.trim-box - accessor';

$page<MediaBox>:delete;
is-json-equiv $page.media-box, [0, 0, 612, 792], 'media-box - default';
is-json-equiv $page.bleed-box, $page.media-box, '$.bleed-box - default';

$page.media-box = 0, 0, 150, 200;
is-json-equiv $page.media-box, [0, 0, 150, 200], 'media-box - list setter';

$page.media-box = [-10,-10,260,310];
$page.crop-box = [0,0,250,300];
is-json-equiv $page.bleed, (0, 0, 0, 0), '$.bleed original';
$page.bleed-box = [-3,-3,253,303];
is-json-equiv $page.media-box, [-10, -10, 260, 310], 'media-box - 4 arg setter';
is-json-equiv $page.MediaBox, [-10, -10, 260, 310], '.MediaBox accessor';
is-json-equiv $page<MediaBox>, [-10, -10, 260, 310], '<MediaBox> accessor';
is-json-equiv $page.crop-box, [0, 0, 250, 300], '$.crop-box - updated';
is-json-equiv $page.bleed-box, [-3, -3, 253, 303], '$.bleed-box - updated';
is-json-equiv $page.bleed, (3, 3, 3, 3), '$.bleed';
$page.bleed = 4;
is-json-equiv $page.bleed-box, [-4, -4, 254, 304], '$.bleed-box - updated';
$page.bleed = 3,4,5,6;
is-json-equiv $page.bleed-box, [-3,-4,255,306], 'bleed setter';
is-json-equiv $page.trim-box, $page.crop-box, '$trim-box - get';
is-json-equiv $page.art-box, $page.crop-box, '$.art-box - get';
$page.ArtBox = [10,10,240,290];
is-json-equiv $page.art-box, [10,10,240,290], '$.art-box - updated';
use PDF::Content::Page :PageSizes;
$page.media-box = PageSizes::A3;
is-json-equiv $page.media-box, [0,0,842,1190], 'media-box page-name setter';
$page.media-box = $page.to-landscape( PageSizes::A3 );
is-json-equiv $page.media-box, [0,0,1190,842], 'media-box page-name setter :landscape';
is-json-equiv $page.media-box, [0,0,1190,842], 'media-box page-name setter :landscape';

$page.gfx.ops(['BT', :Tj[ :literal('Hello, world!') ], 'ET']);
is-deeply [$page.gfx.content-dump], ['BT', '(Hello, world!) Tj', 'ET'], 'finished Contents';
lives-ok {$page.check}, '$page.check lives';

my $xobject = $page.to-xobject;
isa-ok $xobject, 'PDF::XObject::Form';
is-deeply $xobject.BBox, $page.trim-box, 'xobject copied trim-box';


