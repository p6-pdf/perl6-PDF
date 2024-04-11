use v6;
use PDF::COS::Array;
use PDF::COS::Dict;
use PDF::COS::Stream;
use PDF::COS::Tie::Array;
use PDF::COS::Tie::Hash;
use PDF::Content::XObject;

my Set $std-methods .= new: flat( <cb-init cb-check cb-finish type subtype <anon> delegate-function delegate-shading>, (PDF::COS::Stream, PDF::COS::Array).map: *.^methods>>.name);
my Set $stream-accessors .= new: <Length Filter DecodeParms F FFilter FDecodeParms DL>;

my %classes;

my $Anchor = "\n*(generated by `etc/make-quick-ref.pl`)*\n";

sub  MAIN(Str:D $md-file, :$class) {
    my @classes = $class || do {
                 scan-classes('lib'.IO);
                 %classes.keys
    }
    my $doc = $md-file.IO.slurp;
    my @table = gather { gen-table(@classes) }
    unshift @table, ('--------' xx 6) .join(' | ' );
    unshift @table, ('Class', 'Types', 'Accessors', 'Methods', 'Description', 'PDF 1.7 References', 'PDF 2.0 References').join: ' | ';
    print $doc.subst(/^^[[\N+"|"\N+\n]+]$Anchor/, @table.join("\n") ~ "\n" ~ $Anchor);
}

sub scan-classes($path) {

    for $path.dir.sort {
        next if /[^|'/']['.'|t|Type|Loader]/;
        if .d {
            scan-classes($_);
        }
        else {
            next unless /'.rakumod''6'?$/;
            my @class = .Str.split('/');
            @class.shift;
            next if @class[*-2] eq 'Class';
            @class.tail ~~ s/'.rakumod'$//;
            my $name = @class.join: "::";

            %classes{$name} = True;
        }
    }
    # delete base classes
    %classes.keys.map: {
        my @c = .split('::'); @c.pop;
        %classes{@c.join('::')}:delete;
    }
}

sub gen-table(@classes) {
    for @classes.sort({ when 'PDF::Class' {'A'}; when 'PDF::Catalog' {'B'}; default {$_}}) -> $class-name {
        $*ERR.print: ".";
        my $class = (require ::($class-name));

        my $type = do given $class {
            when PDF::COS::Array|PDF::COS::Tie::Array  {'array'}
            when PDF::COS::Stream|PDF::Content::XObject {'stream'}
            when PDF::COS::Dict|PDF::COS::Tie::Hash   {'dict'}
            default {
                warn "ignoring class: $class-name ({$class-name.raku})";
                next;
            }
        };

        my $doc = $class.WHY // '';
        my @interfaces = $class.^roles.grep({.^name ~~ /^ISO_32000/}).list;
        my @see-also = @interfaces.map: *.^name;
        my @pdf_17_refs = @see-also.grep(/^'ISO_32000::'/);
        my @pdf_20_refs = @see-also.grep(/^'ISO_32000_2::'/);
        my %seen;

        my Attribute @atts = $class.^attributes;
        for $class.^roles {
            try @atts.append: .^attributes
        }
        my @accessors = @atts
            .grep({.can('cos')})\
            .unique(:as(*.cos.accessor-name))\
            .map({my $name = .cos.accessor-name; %seen{$name}++; $name ~= "($_)" with .cos.alias; $name })\
            .grep(* ∉ $stream-accessors).sort;

        my @methods = $class.^methods.map(*.name).grep({!%seen{$_}}).grep(* ∉ $std-methods).sort.unique;
        my $ref = make-class-reference($class-name);
        take "$ref | $type | {@accessors.join: ', '} | {@methods.join: ', '} | $doc | {@pdf_17_refs.join: ' '} | {@pdf_20_refs.join: ' '}";

    }
}

sub make-class-reference($name) {
    my $path = $name.subst('::', '/', :g);
    my $md = 'docs/' ~ $name.subst('::', '/', :g) ~ '.md';
    if $md.IO.e {
        # this class has doco
        '[' ~ $name ~ '](' ~ 'https://pdf-raku.github.io/PDF-Class-raku/' ~ $path ~ ')';
    }
    else {
        # nothing to link to
        $name;
    }
}
