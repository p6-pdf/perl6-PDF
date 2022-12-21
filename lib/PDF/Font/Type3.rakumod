use v6;

class PDF::Font::Type3 {
    use PDF::Font;
    use PDF::Content::Resourced;
    also is PDF::Font;
    also does PDF::Content::Resourced;

    use PDF::COS::Tie;
    use PDF::COS::Dict;
    use PDF::COS::Name;
    use PDF::COS::Stream;
    use PDF::FontDescriptor;
    use PDF::Encoding;
    use PDF::Resources;

    # use ISO_32000::Table_112-Entries_in_a_Type_3_font_dictionary;
    # also does ISO_32000::Table_112-Entries_in_a_Type_3_font_dictionary;

    has PDF::COS::Name $.Name is entry;                          # (Required in PDF 1.0; optional otherwise) See Table 5.8 on page 413
    has Numeric @.FontBBox is entry(:required, :len(4));         # (Required) A rectangle expressed in the glyph coordinate system, specifying the font bounding box.
    has Numeric @.FontMatrix is entry(:required, :len(6));       # (Required) An array of six numbers specifying the font matrix, mapping glyph space to text space
    has PDF::COS::Stream %.CharProcs is entry(:required);        # (Required) A dictionary in which each key is a character name and the value associated with that key is a content stream that constructs and paints the glyph for that character.

    has PDF::Encoding $.Encoding is entry(:required);  # (Required) An encoding dictionary whose Differences array specifies the complete character encoding for this font

    has UInt $.FirstChar is entry(:required);          # (Required) The first character code defined in the font’s Widths array

    has UInt $.LastChar is entry(:required);           # (Required) The last character code defined in the font’s Widths array

    has Numeric @.Widths is entry(:required);          # (Required) An array of (LastChar − FirstChar + 1) widths, each element being the glyph width for the character code that equals FirstChar plus the array index.

    has PDF::FontDescriptor $.FontDescriptor is entry(:indirect);     # (Required in Tagged PDF documents; must be an indirect reference) A font descriptor describing the font’s default metrics other than its glyph widths

    has PDF::Resources $.Resources is entry;           # (Optional but strongly recommended; PDF 1.2) A list of the named resources, such as fonts and images, required by the glyph descriptions in this font

    has PDF::COS::Stream $.ToUnicode is entry;         # (Optional; PDF 1.2) A stream containing a CMap file that maps character codes to Unicode values
}
