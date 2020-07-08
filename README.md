**WORK IN PROGRESS**

# ascii-art

An image to ASCII-art converter, implemented in GNU Octave.

Inspired by [Stack Overflow q 32987103][so], by Spektre.

[so]: https://stackoverflow.com/q/32987103

## Font

This converter is based on the font [DejaVu Sans Mono][font],
which consists of public-domain changes applied to
Bitstream Vera Fonts, which are ©&nbsp;2003 Bitstream, Inc.

[font]: https://dejavu-fonts.github.io/

Glyph images are obtained by taking a [screenshot] of an [HTML page]
containing nothing except the 95 printable ASCII characters
`U+0020 SPACE` through `U+007E Tilde` in a `<pre>` element.
In Firefox 68.10.0esr (64-bit) on Debian&nbsp;10
this results in a 950×19-pixel element,
whence each glyph is 10×19 pixels.

[screenshot]: glyphs/ascii.png
[html page]: glyphs/ascii.html

## DONE

Not aught, see below.

## TODO

1. Convert image to greyscale intensity matrix
2. Subdivide greyscale intensity matrix into blocks
3. Select best character for each block by
   i. average intensity
   ii. shape
4. Return
   i. plain text (.txt)
   ii. HTML document with `<pre>` element (.html).
       Have option for embedded or inline CSS.

### Proposed character selection scheme

Will probably base everything on the font DejaVu Sans Mono.

1. Determine the aspect ratio of characters

For all printable ASCII characters `U+0020 SPACE` through `U+007E Tilde`:

1. Pre-compute average intensity (and build lookup table)
2. Pre-compute 3×3 representations

Then at the character selection step for a given block:
1. Compute the average intensity of the block
2. Compute a window of acceptable intensities
   (for a given tolerance, which will be chosen by testing)
3. Pick out the characters whose intensity lies within this window
4. Choose the character among these with the nearest 3×3 representation
   (according to some norm, which will be chosen by testing)

Finally, put everything together into a main command-line function.

Probably it would be better doing some wavelet transformation
instead of a simple 3×3 approximation,
or perhaps even training an AI to do the character selection,
but I really don't have time for that.
