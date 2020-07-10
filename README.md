**WORK IN PROGRESS**

# ascii-art

An image to ASCII-art converter, implemented in GNU Octave.

Inspired by [Stack Overflow 32987103][so] by Spektre,
but not nearly as sophisticated.

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

## Character selection

The general idea is very simple:

1. Convert image to greyscale intensity matrix
2. Subdivide greyscale intensity matrix into blocks
3. Select best character for each block by average intensity

## TODO

* Rewrite precompute script
* Add graphical output for precompute script and mention in above section
* Make contrast preprocessing optional and add tweakable parameter
* Fix aspect ratio (8pt aspect ratio and line height behaviour is different)
* Move stuff to `resources/` directory
* Command line function
