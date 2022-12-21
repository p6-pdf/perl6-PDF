use v6;

class PDF::Font::Type0 {
    use PDF::Font;
    also is PDF::Font;

    use PDF::COS::Tie;
    use PDF::COS::Name;
    use PDF::COS::Stream;
    use PDF::Font::CIDFont;
    use PDF::CMap :CMapRef;

    # use ISO_32000::Table_121-Entries_in_a_Type_0_font_dictionary;
    # also does ISO_32000::Table_121-Entries_in_a_Type_0_font_dictionary;

    has PDF::COS::Name $.BaseFont is entry(:required); # (Required) The PostScript name of the font. In principle, this is an arbitrary name, since there is no font program associated directly with a Type 0 font dictionary.
    has CMapRef $.Encoding is entry(:required);        # (Required) The name of a predefined CMap, or a stream containing a CMap that maps character codes to font numbers and CIDs.
    has PDF::Font::CIDFont @.DescendantFonts is entry(:required,:len(1));    # (Required) A one-element array specifying the CIDFont dictionary that is the descendant of this Type 0 font.
    has PDF::COS::Stream $.ToUnicode is entry;         # (Optional) A stream containing a CMap file that maps character codes to Unicode values
}
