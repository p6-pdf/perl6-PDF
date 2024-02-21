use v6;

# Beads and Threads. Declare both together to avoid
# dealing with circular references

role PDF::Thread {...};

role PDF::Bead {

    use PDF::COS::Tie::Hash;
    also does PDF::COS::Tie::Hash;

    use ISO_32000::Table_161-Entries_in_a_bead_dictionary;
    also does ISO_32000::Table_161-Entries_in_a_bead_dictionary;

    use ISO_32000_2::Table_163-Entries_in_a_bead_dictionary;
    also does ISO_32000_2::Table_163-Entries_in_a_bead_dictionary;

    use PDF::COS::Tie;
    use PDF::COS::Name;

    has PDF::COS::Name $.Type is entry where 'Bead';	# [name] (Optional) The type of PDF object that this dictionary describes; if present, is Bead for a bead dictionary.
    has PDF::Thread $.T is entry(:alias<thread>);	# [dictionary] (Required for the first bead of a thread; optional for all others; is an indirect reference) The thread to which this bead belongs.
        # (PDF 1.1) This entry is permitted only for the first bead of a thread.
        # (PDF 1.2) It is permitted for any bead but required only for the first.
    has PDF::Bead $.N is entry(:required, :alias<next>);	# [dictionary] (Required; is an indirect reference) The next bead in the thread. In the last bead, this entry shall refer to the first bead.
    has PDF::Bead $.V is entry(:required, :alias<previous>);	# [dictionary] (Required; is an indirect reference) The previous bead in the thread. In the first bead, this entry shall refer to the last bead.
    my subset PageLike of Hash where { .<Type> ~~ 'Page' }; # autoloaded PDF::Page
    has PageLike $.P is entry(:alias<page>, :required, :indirect);	# [dictionary] (Required; is an indirect reference) The page object representing the page on which this bead appears.
    has Numeric @.R is entry(:len(4));	# [rectangle] (Required) A rectangle specifying the location of this bead on the page.

}

role PDF::Thread does PDF::COS::Tie::Hash {
    use ISO_32000::Table_160-Entries_in_a_thread_dictionary;
    also does ISO_32000::Table_160-Entries_in_a_thread_dictionary;
    use ISO_32000_2::Table_162-Entries_in_a_thread_dictionary;
    also does ISO_32000_2::Table_162-Entries_in_a_thread_dictionary;
    use PDF::COS::Tie;
    use PDF::COS::Name;
    use PDF::Info;

    has PDF::COS::Name $.Type is entry where 'Thread';	# [name] (Optional) The type of PDF object that this dictionary describes; if present, is Thread for a thread dictionary.
    has PDF::Bead $.F is entry(:required, :alias<first>);	# [dictionary] (Required; is an indirect reference) The first bead in the thread.
    has PDF::Info $.I is entry(:alias<info>);	# [dictionary] (Optional) A thread information dictionary containing information about the thread, such as its title, author, and creation date. The contents of this dictionary shall conform to the syntax for the document information dictionary (see Link 14.3.3, “Document Information Dictionary” ).

}

