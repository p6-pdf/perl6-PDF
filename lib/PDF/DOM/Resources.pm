use v6;

role PDF::DOM::Resources {

    use PDF::DAO;
    use PDF::DOM::Type;
    use PDF::DOM::Util::Font;
    use PDF::DOM::Type::Font;

    my role ResourceEntry {
        has Str $.key is rw;
    }

    method core-font( *@arg, *%opt ) {
        my $core-font = PDF::DOM::Util::Font::core-font( |@arg, |%opt );
        self!find-resource(sub ($_){.isa(PDF::DOM::Type::Font) && .font-obj === $core-font}, :type<Font>)
            // do {
                my %params = $core-font.to-dom('Font');
                my $new-obj = PDF::DAO.coerce( |%params );
                self!register-resource( $new-obj );
        };
    }

    method resource(PDF::DAO $object, Bool :$eqv=False ) {
        my Str $type = $object.?type
            // die "not a resource object: {$object.WHAT}";

	my &match = $eqv
	    ?? sub ($_){$_ eqv $object}
	    !! sub ($_){$_ === $object};
        self!find-resource(&match, :$type)
            //  self!register-resource( $object );
    }

    method resource-entry(Str $type!, Str $key!) {
        my $resources = self.Resources;

        return unless
            $resources.defined
            && ($resources{$type}:exists)
            && ($resources{$type}{$key}:exists);

        my $object = $resources{$type}{$key}
        or return;

        my $entry = $object but ResourceEntry;
        $entry.key = $key;
        $entry;
    }

    method !find-resource( &match, Str :$type! ) {

        my $resources = self.Resources;

	$resources // {};

        my $entry;

        if $resources = $resources{$type} {

            for $resources.keys {
                my $resource = $resources{$_};
                if &match($resource) {
                    $entry = $resource but ResourceEntry;
                    $entry.key = $_;
                    last;
                }
            }
        }

        $entry;
    }

    multi method base-name( PDF::DAO $object ) is default {
        my Str $type = $object.?type
            // die "not a resource object: {$object.WHAT}";

        do given $type {
	    when 'ColorSpace' {'CS'}
            when 'ExtGState'  {'GS'}
            when 'Font'       {'F'}
            when 'Pattern'    {'Pt'}
	    when 'Shading'    {'Sh'}
            when 'XObject' {
                given $object.Subtype {
                    when 'Form'  {'Fm'}
                    when 'Image' {'Im'}
		    default { warn "unknown XObject subtype: $_"; 'Obj' }
		}
            }
            default { warn "unknown object type: $_"; 'Obj' }
        }
    }

    #| ensure that the object is registered as a page resource. Return a unique
    #| name for it.
    method !register-resource(PDF::DAO $object,
                             Str :$base-name = $.base-name($object),
                             :$type = $object.?type) {

	die "unable to register this resource"
	    unless $type.defined;

        my Str $id = $object.id;
        my $resources = self.Resources;

        $resources //= do {
            self<Resources> = {};
            self.Resources
        };

        $resources{$type} //= {};

        my Str $key = (1..*).map({$base-name ~ $_}).first({ $resources{$type}{$_}:!exists });

        $resources{$type}{$key} = $object;
        my $entry = $object but ResourceEntry;
        $entry.key = $key;
        $entry;
    }

}
