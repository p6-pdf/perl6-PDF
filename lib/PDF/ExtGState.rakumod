#| /Type /ExtGState
unit role PDF::ExtGState;

use PDF::COS::Tie::Hash;
also does PDF::COS::Tie::Hash;

use PDF::COS::Tie;
use PDF::COS::Name;
use PDF::Mask;
use PDF::Function;

# use ISO_32000::Table_58-Entries_in_a_Graphics_State_Parameter_Dictionary;
# also does ISO_32000::Table_58-Entries_in_a_Graphics_State_Parameter_Dictionary;

has PDF::COS::Name $.Type is entry where 'ExtGState';
has Numeric $.LW is entry(:alias<line-width>);               # (Optional; PDF 1.3) The line width
has UInt $.LC is entry(:alias<line-cap>);                    # (Optional; PDF 1.3) The line cap style
has UInt $.LJ is entry(:alias<line-join>);                   # (Optional; PDF 1.3) The line join style
has Numeric $.ML is entry(:alias<miter-limit>);              # (Optional; PDF 1.3) The miter limit
has UInt @.D is entry(:alias<dash-pattern>);                 # (Optional; PDF 1.3) The line dash pattern, expressed as an array of the form [ dashArray dashPhase ], where dashArray is itself an array and dashPhase is an integer
has PDF::COS::Name $.RI is entry(:alias<rendering-intent>);  # (Optional; PDF 1.3) The name of the rendering intent
has Bool $.OP is entry(:alias<overprint-paint>);             # (Optional) A flag specifying whether to apply overprint
has Bool $.op is entry(:alias<overprint-stroke>);            # (Optional; PDF 1.3) A flag specifying whether to apply overprint for painting operations other than stroking
has Int $.OPM is entry(:alias<overprint-mode>);              # (Optional; PDF 1.3) The overprint mode
has @.Font is entry(:len(2));          # (Optional; PDF 1.3) An array of the form [ font size ], where font is an indirect reference to a font dictionary and size is a number expressed in text space units.

my subset XFerFunction where PDF::Function|PDF::COS::Name;
has XFerFunction $.BG is entry(:alias<black-generation-old>);             # (Optional) The black-generation function, which maps the interval [ 0.0 1.0 ] to the interval [ 0.0 1.0 ]
has XFerFunction $.BG2 is entry(:alias<black-generation>);                # (Optional; PDF 1.3) Same as BG except that the value may also be the name Default, denoting the black-generation function that was in effect at the start of the page
# If both BG and BG2 are present in the same graphics state parameter dictionary, BG2 takes precedence.

has XFerFunction $.UCR is entry(:alias<under-color-removal-old>);          # (Optional) The undercolor-removal function, which maps the interval [ 0.0 1.0 ] to the interval [ −1.0 1.0 ]
has XFerFunction $.UCR2 is entry(:alias<under-color-removal>);            # (Optional; PDF 1.3) Same as UCR except that the value may also be the name Default, denoting the undercolor-removal function that was in effect at the start of the page.

has XFerFunction @.TR is entry(:alias<transfer-function-old>, :array-or-item);            # (Optional) The transfer function, which maps the interval [ 0.0 1.0 ] to the interval [ 0.0 1.0 ]
has XFerFunction @.TR2 is entry(:alias<transfer-function>, :array-or-item);               # (Optional; PDF 1.3) Same as TR except that the value may also be the name Default, denoting the transfer function that was in effect at the start of the page.

has $.HT is entry(:alias<halftone>) where Hash|'Default';    # (Optional) The halftone dictionary or stream or the name 'Default'
has Numeric $.FL is entry(:alias<flatness-tolerance>);       # (Optional; PDF 1.3) The flatness tolerance
has Numeric $.SM is entry(:alias<smoothness-tolerance>);             # (Optional; PDF 1.3) The smoothness tolerance
has Bool $.SA is entry(:alias<stroke-adjustment>);           # (Optional) A flag specifying whether to apply automatic stroke adjustment
has $.BM is entry(:alias<blend-mode>);                       # (Optional; PDF 1.4) The current blend mode to be used in the transparent imaging model
my subset SMaskLike where PDF::Mask|PDF::COS::Name;
has SMaskLike $.SMask is entry(:alias<soft-mask>);          # (Optional; PDF 1.4) The current soft mask, specifying the mask shape or mask opacity values to be used in the transparent imaging mode
my subset Alpha of Numeric where 0.0 .. 1.0;
has Alpha $.CA is entry(:alias<stroke-alpha>);               # (Optional; PDF 1.4) The current stroking alpha constant, specifying the constant shape or constant opacity value to be used for stroking operations in the transparent imaging model
has Alpha $.ca is entry(:alias<fill-alpha>);                 # (Optional; PDF 1.4) Same as CA, but for nonstroking operations
has Bool $.AIS is entry(:alias<alpha-source-flag>);          # (Optional; PDF 1.4) The alpha source flag (“alpha is shape”), specifying whether the current soft mask and alpha constant are to be interpreted as shape values (true) or opacity values (false).
has Bool $.TK is entry(:alias<text-knockout>);               # (Optional; PDF 1.4) The text knockout flag, which determines the behavior of overlapping glyphs within a text object in the transparent imaging model

# The graphics transparency , with 0 being fully opaque and 1 being fully transparent.
# This is a convenience method setting proper values for stroke-alpha and fill-alpha.
method transparency is rw {
    Proxy.new(
        FETCH => {
            my \fill-alpha = self.ca;
            fill-alpha eqv self.CA
                ?? fill-alpha
                !! Mu
        },
        STORE => -> $, Alpha \val {
            self.ca = self.CA = val;
        });
}
