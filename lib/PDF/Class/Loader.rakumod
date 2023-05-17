use v6;

use PDF::COS;

PDF::COS.loader = class PDF::Class::Loader {
    use PDF::COS::Loader;
    also is PDF::COS::Loader;
    use PDF::Class::Defs :ActionSubtype, :AnnotSubtype, :FontFileType;
    use PDF::COS::Util :from-ast;
    use PDF::COS::Name;
    use PDF::COS::Dict;

    method class-paths {<PDF PDF::COS::Type>}
    method warn {True}

    multi method load-delegate(Hash :$dict! where {.<FunctionType>:exists}) {
	$.find-delegate('Function', :base-class(PDF::COS::Dict)).delegate-function( :$dict );
    }

    multi method load-delegate(Hash :$dict! where {.<PatternType>:exists}) {
        my UInt $pt = from-ast $dict<PatternType>;
        my $sub-type = [Mu, 'Tiling', 'Shading'][$pt];
        note "Unknown /PatternType $pt" without $sub-type;
	$.find-delegate('Pattern', :base-class(PDF::COS::Dict), $sub-type);
    }

    multi method load-delegate(Hash :$dict! where {.<ShadingType>:exists}) {
	$.find-delegate('Shading', :base-class(PDF::COS::Dict)).delegate-shading( :$dict );
   }

    multi method load-delegate( Hash :$dict! where {.<Type>:exists}, :$base-class!) {
        my $type = from-ast($dict<Type>);
        my $subtype = from-ast($_)
            with $dict<Subtype> // $dict<S>;
        with $subtype {
            when '3D'   { $_ = 'ThreeD' }
            when .chars <= 2
            || $type ~~ 'OutputIntent'|'StructElem' # no specific subclasses
                        { $_ = Nil }
        }
        $type ~~
            'Ind'|'Ttl'|'Org'              # handled by PDF::OCG
            |'SigRef'|'TransformParams'    # handled by PDF::Signature
            |'Sig'|'PageLabel'             # handled by PDF::Catalog
            |'EmbeddedFile'                # handled by PDF::Filespec
            |'Stream'                      # MS print-driver fluff
            ?? $base-class
            !! $.find-delegate( $type, $subtype, :$base-class );
    }

    #| Reverse lookup for classes when /Subtype is required but /Type is optional
    multi method load-delegate(Hash :$dict! where {.<Subtype>:exists }, :$base-class!) {
	my $subtype = from-ast $dict<Subtype>;

	my $type = do given $subtype {
            when '3D' { $subtype = 'ThreeD'; 'Annot' }
	    when AnnotSubtype  { 'Annot' }
            when 'Markup3D'    { 'ExData' }
	    when 'PS'|'Image'|'Form' { 'XObject' }
            when FontFileType {
                $subtype = Nil; # not currently subclassed
                'FontFile'
            }
	    default { Nil }
	};

	with $type {
	    $.find-delegate($_, $subtype, :$base-class);
	}
	else {
	    $base-class;
	}
    }

    #| Reverse lookup for classes when /S (subtype) is required, but /Type is optional
    multi method load-delegate(Hash :$dict! where {.<S>:exists }, :$base-class!) {
	my $subtype = from-ast $dict<S>;

	my $type = do given $subtype {
            when 'Alpha'|'Luminosity' { 'Mask' }
            when 'GTS_PDFX'|'GTS_PDFA1'|'ISO_PDFE1' {
                    $subtype = Nil; # not subclassed
                    'OutputIntent';
                 }
            when ActionSubtype  { 'Action' }
            when 'Transparency' { 'Group' }
            default { Nil }
	};

	with $type {
	    $.find-delegate($_, $subtype, :$base-class);
	}
        else {
            $base-class;
        }
    }

    my subset ColorSpaceName of PDF::COS::Name
        where ('CalGray'|'CalRGB'|'Lab'|'ICCBased'|'Pattern' #| PDF Spec 1.7 Section 4.5.4 CIE-Based Color Spaces
               |'Indexed'|'Separation'|'DeviceN'); #| PDF Spec 1.7 Section 4.5.5 Special Color Spaces)
    my subset ColorSpace of List where {
        .elems <= 5 && from-ast(.[0]) ~~ ColorSpaceName
    }

    multi method load-delegate(ColorSpace :$array!, :$base-class!) {
	my $color-type = from-ast $array[0];
	$.find-delegate('ColorSpace', $color-type, :$base-class);
    }

    multi method load-delegate(:$base-class!) {
	$base-class;
    }

    method pdf-class { PDF::COS.required('PDF::Class') }
}
