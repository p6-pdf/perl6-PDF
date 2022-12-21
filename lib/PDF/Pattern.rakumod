use v6;

role PDF::Pattern {
    use PDF::COS::Tie::Hash;
    use PDF::Class::Type;

    also does PDF::COS::Tie::Hash;
    also does PDF::Class::Type::Subtyped;

    use PDF::COS::Tie;
    use PDF::COS::Name;

    # /Type entry is optional, but should be /Pattern when present
    has PDF::COS::Name $.Type is entry where 'Pattern';

    my subset PatternTypeInt of Int where 1|2;
    has PatternTypeInt $.PatternType is entry(:required);  # (Required) A code identifying the type of pattern that this dictionary describes; must be 1 for a tiling pattern, or 2 for a shading pattern.

    has Numeric @.Matrix is entry(:len(6), :default[1, 0, 0, 1, 0, 0]);                # (Optional) An array of six numbers specifying the pattern matrix. Default value: the identity matrix [ 1 0 0 1 0 0 ].

    my enum PatternTypes is export(:PatternTypes) « :Tiling(1) :Shading(2) »;
    my constant %PatternTypes = PatternTypes.enums.Hash;
    my constant %PatternNames = PatternTypes.enums.invert.Hash;

    method type    { 'Pattern' }
    method subtype { %PatternNames[ self<PatternType> ] }

    method cb-init {

        for self.^mro {
            my Str $class-name = .^name;

            if $class-name ~~ /^ 'PDF::' (\w+) ['::' (\w+)]? $/ {
                my Str $type-name = ~$0;

                if self<Type>:exists {
                    # /Type already set. check it agrees with the class name
                    die "conflict between class-name $class-name ($type-name) and dictionary /Type /{self<Type>}"
                        unless self<Type> eq $.type;
                }

                if $1 {
                    my Str $subtype = ~$1;
                    my $mro-pattern-type := %PatternTypes{$subtype};
		    die "$class-name has unknown subtype $subtype"
			unless $mro-pattern-type.defined;

                    with self<PatternType> {
		        die "conflict between class-name $class-name ($subtype) and /PatternType /{self<PatternType>.value}"
			    unless $_ == $mro-pattern-type;
                    }
                    else {
		        $_ = $mro-pattern-type;
                    }

                }

                last;
            }
        }

    }

}
