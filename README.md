**WORK IN PROGRESS**

# ascii-art

An image to ASCII-art converter, implemented in GNU Octave.

Inspired by [Stack Overflow q 32987103][so], by Spektre.

[so]: https://stackoverflow.com/q/32987103

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

Probably it would be better doing some wavelet transformation
instead of a simple 3×3 approximation,
or perhaps even training an AI to do the character selection,
but I really don't have time for that.
