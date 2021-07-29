use v6;

use PDF::COS::Dict;
use PDF::Action;

#| /Action Subtype - GoToR
class PDF::Action::GoToR
    is PDF::COS::Dict
    does PDF::Action {

    # use ISO_32000::Table_200-Additional_entries_specific_to_a_remote_go-to_action;
    # also does ISO_32000::Table_200-Additional_entries_specific_to_a_remote_go-to_action;

    use PDF::COS::Tie;
    use PDF::Destination :DestRef, :coerce-dest;
    use PDF::Filespec :FileRef, :&to-file;
    use PDF::Page;

    has FileRef $.F is entry(:alias<file>, :required, :coerce(&to-file)); # (Required) The file in which the destination shall be located.
    my subset RemoteDestRef of DestRef where .[0] ~~ UInt;
    has RemoteDestRef $.D is entry(:required, :alias<destination>, :coerce(&coerce-dest)); # (Required) The destination to jump to. If the value is an array defining an explicit destination, its first element shall be a page number within the remote document rather than an indirect reference to a page object in the current document. The first page shall be numbered 0.
    has Bool $.NewWindow is entry; # (Optional; PDF 1.2) A flag specifying whether to open the destination document in a new window. If this flag is false, the destination document replaces the current document in the same window. If this entry is absent, the conforming reader should behave in accordance with its preference.
}
