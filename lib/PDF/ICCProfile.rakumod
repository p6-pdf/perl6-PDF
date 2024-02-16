unit role PDF::ICCProfile;

use PDF::COS::Tie::Hash;
also does PDF::COS::Tie::Hash;

use PDF::COS::Tie;
use PDF::COS::Name;
use PDF::ColorSpace;
use PDF::Metadata::XML;
use PDF::Class::Defs :ColorSpace;

use ISO_32000::Table_66-Additional_Entries_Specific_to_an_ICC_Profile_Stream_Dictionary;
also does ISO_32000::Table_66-Additional_Entries_Specific_to_an_ICC_Profile_Stream_Dictionary;

use ISO_32000_2::Table_65-Additional_entries_specific_to_an_ICC_profile_stream_dictionary;
also does ISO_32000_2::Table_65-Additional_entries_specific_to_an_ICC_profile_stream_dictionary;

has UInt $.N is entry(:required, :alias<num-colors>);          # (Required) The number of color components in the color space described by the ICC profile data. This number must match the number of components actually in the ICC profile. As of PDF 1.4, N must be 1, 3, or 4.
has ColorSpace $.Alternate is entry;      # (Optional) An alternate color space to be used in case the one specified in the stream data is not supported (for example, by applications designed for earlier versions of PDF). The alternate space may be any valid color space (except a Pattern color space) that has the number of components specified by N. If this entry is omitted and the application does not understand the ICC profile data, the color space used is DeviceGray, DeviceRGB, or DeviceCMYK, depending on whether the value of N is 1, 3, or 4, respectively.
# Note: There is no conversion of source color values, such as a tint transformation, when using the alternate color space. Color values within the range of the ICCBased color space might not be within the range of the alternate color space. In this case, the nearest values within the range of the alternate space are substituted.

has Numeric @.Range is entry;              # (Optional) An array of 2 × N numbers [ min0 max0 min1 max1 … ] specifying the minimum and maximum valid values of the corresponding color components. These values must match the information in the ICC profile. Default value: [ 0.0 1.0 0.0 1.0 … ].

has PDF::Metadata::XML $.Metadata is entry;  # (Optional; PDF 1.4) A metadata stream containing metadata for the color space
