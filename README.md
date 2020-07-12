# ascii-art

An image to ASCII-art converter, implemented in GNU Octave.

Inspired by [Stack Overflow 32987103][so] by Spektre.

[so]: https://stackoverflow.com/q/32987103


## Usage

Currently there is no command line capability.
In GNU Octave:

```
image_to_ascii (image_, characters_per_line)
image_to_ascii (image_file_name, characters_per_line)
image_to_ascii (..., block_size_scalar)
image_to_ascii (..., [block_height, block_width])
image_to_ascii (..., property, value, ...)
```

Returns ASCII art character array.

Available properties (default value):
* `"glyphs"` (`"resources/dejavu_sans_mono_glyphs.png"`)<br>
  Image file containing glyphs for the 95 printable ASCII characters
  `U+0020 SPACE` through `U+007E TILDE`, arranged in a row from left to right.
* `"m"` (`1.6`)<br>
   Parameter for increasing contrast. See [image_increase_contrast.m].
* `"method"` (`"cubic"`)<br>
   Method for image-resizing interpolation. See [image_resize.m].
* `"output"` (`""`)<br>
   File name to write ASCII art to. If non-empty, must be `*.html` or `*.txt`.
* `"p"` (`1.3`)<br>
   Parameter for p-norm. See [nearest_neighbour.m].


## Font

Any font can be processed by supplying a different glyphs image
for the `"glyphs"` property, though you will have to change the CSS
in the [output template] correspondingly.

By default the converter uses the font [DejaVu Sans Mono][font],
which consists of public-domain changes applied to
Bitstream Vera Fonts, which are ©&nbsp;2003 Bitstream, Inc.

The [default glyphs image][dejavu.png] is obtained
by taking a screenshot of an [HTML file][dejavu.html]
containing nothing except the 95 printable ASCII characters
`U+0020 SPACE` through `U+007E Tilde` in a `<pre>` element.
In Firefox 68.10.0esr (64-bit) on Debian&nbsp;10
this results in a [1140×24-pixel element][dejavu.png]:

![The 95 printable ASCII characters, rendered in DejaVu Sans Mono.][dejavu.png]

[font]: https://dejavu-fonts.github.io/
[dejavu.png]: resources/dejavu_sans_mono_glyphs.png
[dejavu.html]: resources/dejavu_sans_mono_glyphs.html
[output template]: resources/output_template.html

## Algorithm

### TLDR

* Resize each font glyph into a block of a prescribed size.
* Resize the image by into an array of blocks of the same size.
* Select the best character for each block by seeking the nearest neighbour
  amongst the font glyph blocks.

Resizing is done via interpolation (default bicubic).

The glyph aspect ratio is already taken care of
when computing the size of the array of blocks
(which is the size of the resultant character array).

The size of the blocks themselves need not have the same aspect ratio.
For 1×1 blocks, the conversion is effectively intensity-only.
For finer blocks, the conversion is also influenced by character shape.
From some eyeball-norm testing, 5×3 blocks work well
(and generally speaking odd numbers give better results).

The blocks should not be too fine, both because the conversion becomes slow
and because it doesn't make sense to use blocks which have a finer granularity
than the resolution of the glyph images.

### In full

0. Preprocess image
   1. Convert the image to greyscale.
   1. Increase the contrast of the image.

1. Process glyphs and build data set
   1. Import the glyphs image file.
   1. Compute the glyph aspect ratio.
   1. Subdivide the glyphs image file into a cell array,
      with one glyph per subimage.
   1. Compute the average intensity of each glyph subimage.
   1. Resize each glyph subimage to the given block size.
   1. Build a data set matrix whose rows are the
      flattened resized glyph subimages.
   1. Normalise the glyph average intensities in to the range `[0, 1]`.
   1. Adjust the data set so that its average intensities (row averages)
      are close to the normalised glyph average intensities.

2. Resize image and subdivide into array of blocks
   1. Compute the size of the ASCII art character array
      for the given characters per line and glyph aspect ratio.
   1. Compute the size of the resized image,
      which is the size of the image formed by replacing each character
      of the character array with a block of the given block size.
   1. Resize the image.
   1. Subdivide the resized image into an array of blocks,
      with the array being the size of the character array
      and the blocks therefore being the given block size.

3. Select best characters
   1. For each block in the array of blocks,
      flatten the block and find the index of the nearest neighbour
      in the glyph data set.
   1. Convert the glyph index to its corresponding code point.
      Thus build an array of code points.
   1. Convert the code point array to a character array.

4. Write to file (if specified)
   1. Convert the character array to a string.
   1. Fill the appropriate template.
   1. Write to file.
