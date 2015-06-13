use Test;
use v6;

use PDF::DOM::Util::Font;
use PDF::DOM;

my $hb-afm = PDF::DOM::Util::Font::core-font( 'Helvetica-Bold' );
isa-ok $hb-afm, ::('Font::AFM'); 
is $hb-afm.FontName, 'Helvetica-Bold', 'FontName';

my $ab-afm = PDF::DOM::Util::Font::core-font( 'Arial-Bold' );
isa-ok $hb-afm, ::('Font::AFM'); 
is $hb-afm.FontName, 'Helvetica-Bold', 'FontName';

my $hbi-afm = PDF::DOM::Util::Font::core-font( 'Helvetica-BoldItalic' );
is $hbi-afm.FontName, 'Helvetica-BoldOblique', 'FontName';

my $hb-afm-again = PDF::DOM::Util::Font::core-font( 'Helvetica-Bold' );

ok $hb-afm-again === $hb-afm, 'font caching';

my $dict = $hbi-afm.to-dom('Font');

my $font = PDF::Object.compose( :$dict );

isa-ok $font, ::('PDF::DOM::Font::Type1');

is $font.BaseFont, 'Helvetica-BoldOblique';

done;