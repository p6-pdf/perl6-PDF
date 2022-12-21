use v6;

#| /ShadingType 2 - Axial

class PDF::Pattern::Shading {
    use PDF::COS::Dict;
    use PDF::Pattern;

    also is PDF::COS::Dict;
    also does PDF::Pattern;

    use PDF::COS::Tie;
    use PDF::Shading;
    use PDF::ExtGState;

    # use ISO_32000::Table_76-Entries_in_a_Type_2_Pattern_Dictionary;
    # also does ISO_32000::Table_76-Entries_in_a_Type_2_Pattern_Dictionary;

    has PDF::Shading $.Shading is entry(:required);                 # (Required) A shading object (see below) defining the shading pattern’s gradient fill.
    has PDF::ExtGState $.ExtGState is entry;                        # (Optional) A graphics state parameter dictionary
}
