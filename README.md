**WORK IN PROGRESS**

# ascii-art

An image to ASCII-art converter, implemented in GNU Octave.

Inspired by [Stack Overflow 32987103][so] by Spektre.

[so]: https://stackoverflow.com/q/32987103

## Font

This converter is based on the font [DejaVu Sans Mono][font],
which consists of public-domain changes applied to
Bitstream Vera Fonts, which are ©&nbsp;2003 Bitstream, Inc.

[font]: https://dejavu-fonts.github.io/

Glyph images are obtained by taking a screenshot of an [HTML page][html]
containing nothing except the 95 printable ASCII characters
`U+0020 SPACE` through `U+007E Tilde`
rendered in 32px DejaVu Sans Mono in a `<pre>` element.
In Firefox 68.10.0esr (64-bit) on Debian&nbsp;10
this results in a [1805×38-pixel element][png]:

![The 95 printable ASCII characters rendered in DejaVu Sans Mono][png]

Therefore each glyph is 19×38 pixels (i.e.&nbsp;aspect ratio 2).

[png]: glyphs/ascii.png
[html]: glyphs/ascii.html

## Character selection scheme

The general idea is thus:

1. Convert image to greyscale intensity matrix
2. Subdivide greyscale intensity matrix into blocks
3. Select best character for each block:
   1. Compute average intensity of block
   2. Declare window of acceptable average intensities nigh thereunto
   3. Preselect characters whose glyph has average intensity in window
   4. Compute nit of block
   5. Select character whose glyph has nit closest to nit of block

A "nit" is a 9-bit approximation of an image,
computed by subdividing the image into 9 blocks (3×3)
and computing whether the average intensity of each block
exceeds a specified threshold intensity.

Precomputed nits for DejaVu Sans Mono glyphs:

![The 95 printable ASCII characters with their nits below][nits]

[nits]: glyphs/ascii_with_nits_graphical.png

## TODO

* Speed up character selection
* Command line function

## Remarks

Probably it would be better doing some wavelet transformation
instead of a simple 3×3 approximation,
or perhaps even training an AI to do the character selection,
but I really don't have time for that.
