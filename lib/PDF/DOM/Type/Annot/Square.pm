use v6;

use PDF::DOM::Type::Annot;

class PDF::DOM::Type::Annot::Square
    is PDF::DOM::Type::Annot {

    use PDF::DAO::Tie;
    use PDF::DAO::Name;

    # See [PDF 1.7 TABLE 8.39 Additional entries specific to a widget annotation]

    use PDF::DOM::Type::Border;
    has PDF::DOM::Type::Border $.BS is entry;              #| (Optional) A border style dictionary (see Table 8.17 on page 611) specifying the line width and dash pattern to be used in drawing the rectangle or ellipse.
                                         #| Note: The annotation dictionary’s AP entry, if present, takes precedence over the Land BS entries

    has Numeric @.IC is entry;           #| (Optional; PDF 1.4) An array of numbers in the range 0.0 to 1.0 specifying the interior color with which to fill the annotation’s rectangle or ellipse. The number of array elements determines the color space in which the color is defined:
    #| 0: No color; transparent
    #| 1: DeviceGray
    #| 3: 3DeviceRGB
    #| 4: DeviceCMYK

    has Hash $.BE is entry;              #| (Optional; PDF 1.5) A border effect dictionary describing an effect applied to the border described by the BS entry

    has Numeric @.RD is entry(:len(4));  #| (Optional; PDF 1.5) A set of four numbers describing the numerical differences between two rectangles: the Rect entry of the annotation and the actual boundaries of the underlying square or circle. Such a difference can occur in situations where a border effect (described by BE) causes the size of the Rect to increase beyond that of the square or circle.
    #| The four numbers correspond to the differences in default user space between the left, top, right, and bottom coordinates of Rect and those of the square or circle, respectively. Each value must be greater than or equal to 0. The sum of the top and bottom differences must be less than the height of Rect, and the sum of the left and right differences must be less than the width of Rect.

}