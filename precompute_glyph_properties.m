## precompute_glyph_properties
##
## Precompute properties of the glyphs in glyphs/ascii.png,
## assumed to contain glyphs for the 95 printable ASCII characters
## `U+0020 SPACE` through `U+007E Tilde` in a single row.
## 1. Average intensities
##    * Build table with rows [code point, average intensity]
##    * Sort table by average intensity
##    * Re-normalise average intensities to the range [0, 255]
##    * Round average intensities to the nearest integer
##    * Export table to glyphs/precomputed_glyph_average_intensities.txt.
##    * Also export readable version with characters instead of code points.
## 2. Nits (9-bit representations)
##    * Build table with rows [code point, nit]
##    * Export table to glyphs/precomputed_glyph_nits.txt.
##    * Also export graphical version with nits underneath glyphs.

## ----------------------------------------------------------------
## Load glyphs from file
## ----------------------------------------------------------------

GLYPHS_IMAGE_FILE = "glyphs/ascii.png";

glyphs_greyscale_matrix = image_file_to_greyscale_matrix (GLYPHS_IMAGE_FILE);

PRINTABLE_ASCII_CODE_POINT_FIRST = 0x0020;
PRINTABLE_ASCII_CODE_POINT_LAST = 0x007E;

PRINTABLE_ASCII_TOTAL_NUMBER = ...
  PRINTABLE_ASCII_CODE_POINT_LAST - PRINTABLE_ASCII_CODE_POINT_FIRST + 1;

glyph_height = rows (glyphs_greyscale_matrix);
glyph_width = columns (glyphs_greyscale_matrix) / PRINTABLE_ASCII_TOTAL_NUMBER;
glyph_aspect_ratio = glyph_height / glyph_width;

glyphs_block_array = matrix_to_block_array (
  glyphs_greyscale_matrix,
  PRINTABLE_ASCII_TOTAL_NUMBER,
  glyph_aspect_ratio
);

## ----------------------------------------------------------------
## Choose nit threshold for glyphs
## ----------------------------------------------------------------

MIN_INTENSITY = 0;
MAX_INTENSITY = 255;

GLYPH_NIT_THRESHOLD = floor (0.83 * (MAX_INTENSITY - MIN_INTENSITY));

## ----------------------------------------------------------------
## Compute properties [code point, average intensity]
## ----------------------------------------------------------------

glyph_properties_table = zeros (PRINTABLE_ASCII_TOTAL_NUMBER, 3);

for i = 1 : PRINTABLE_ASCII_TOTAL_NUMBER
  
  glyph_block = glyphs_block_array{i};
  
  NIT_MARGIN_TOP = 4;
  NIT_MARGIN_LEFT = 1;
  glyph_block_for_nit = ...
    glyph_block(
      1 + NIT_MARGIN_TOP : end,
      1 + NIT_MARGIN_LEFT : end
    );
  
  code_point = PRINTABLE_ASCII_CODE_POINT_FIRST + i - 1;
  average_intensity = matrix_to_average_intensity (glyph_block);
  nit = matrix_to_nit (glyph_block_for_nit, GLYPH_NIT_THRESHOLD);
  
  glyph_properties_table(i,:) = [code_point, average_intensity, nit];
  
endfor

## ----------------------------------------------------------------
## 1. Average intensities
## ----------------------------------------------------------------

## Build table

glyph_average_intensities_table = glyph_properties_table(:, [1, 2]);

## Sort table

glyph_average_intensities_table = ...
  sortrows (glyph_average_intensities_table, 2);

characters_ordered_by_glyph_average_intensity = ...
  char (glyph_average_intensities_table(:,1)');

fprintf ("\nCharacters ordered by glyph average intensity:\n%s{END}\n\n",
  characters_ordered_by_glyph_average_intensity
)

## Re-normalise average intensities

glyph_average_intensities = glyph_average_intensities_table(:,2);

min_glyph_average_intensity = min (glyph_average_intensities);
max_glyph_average_intensity = max (glyph_average_intensities);

glyph_average_intensities = (
  (glyph_average_intensities - min_glyph_average_intensity)
  / (max_glyph_average_intensity - min_glyph_average_intensity)
  * (MAX_INTENSITY - MIN_INTENSITY)
);

## Round average intensities

glyph_average_intensities = round (glyph_average_intensities);

glyph_average_intensities_table(:,2) = glyph_average_intensities;

## Export table

PRECOMPUTED_AVERAGE_INTENSITIES_TEXT_FILE = ...
  "glyphs/precomputed_glyph_average_intensities.txt";

dlmwrite (
  PRECOMPUTED_AVERAGE_INTENSITIES_TEXT_FILE,
  glyph_average_intensities_table
);

## Also export readable version

PRECOMPUTED_AVERAGE_INTENSITIES_TEXT_FILE_READABLE = ...
  "glyphs/precomputed_glyph_average_intensities_readable.txt";

file_id = fopen (PRECOMPUTED_AVERAGE_INTENSITIES_TEXT_FILE_READABLE, "w");

for i = 1 : PRINTABLE_ASCII_TOTAL_NUMBER
  
  code_point = glyph_average_intensities_table(i,1);
  character = char (code_point);
  
  average_intensity = glyph_average_intensities_table(i,2);
  
  fprintf(file_id, "%s %i", character, average_intensity);
  fprintf(file_id, "\n");
  
endfor

fclose (file_id);

## ----------------------------------------------------------------
## 2. Nits
## ----------------------------------------------------------------

## Build table

glyph_nits_table = glyph_properties_table(:, [1, 3]);

## Export table

PRECOMPUTED_NITS_TEXT_FILE = "glyphs/precomputed_glyph_nits.txt";

dlmwrite (PRECOMPUTED_NITS_TEXT_FILE, glyph_nits_table);

## Also export graphical

NIT_SIZE_LINEAR = 3;
NIT_SIZE = NIT_SIZE_LINEAR ^ 2;

nit_graphical_block_height = floor (glyph_height / NIT_SIZE_LINEAR);
nit_graphical_block_width = floor (glyph_width / NIT_SIZE_LINEAR);
nit_graphical_block = ...
  ones (nit_graphical_block_height, nit_graphical_block_width);

nit_graphical_matrix_rows = nit_graphical_block_height * NIT_SIZE_LINEAR;
nit_graphical_matrix_columns = nit_graphical_block_width * NIT_SIZE_LINEAR;

glyphs_nits_graphical_matrix = ...
  MAX_INTENSITY(ones (size (glyphs_greyscale_matrix)));

for i = 1 : PRINTABLE_ASCII_TOTAL_NUMBER
  
  nit = glyph_nits_table(i,2);
  bit_vector = bitget (nit, NIT_SIZE : -1 : 1);
  bit_matrix = reshape (bit_vector, NIT_SIZE_LINEAR, NIT_SIZE_LINEAR);
  nit_graphical_matrix = ...
    MIN_INTENSITY + (MAX_INTENSITY - MIN_INTENSITY) * bit_matrix;
  nit_graphical_matrix = kron (nit_graphical_matrix, nit_graphical_block);
  
  column_offset = (i - 1) * glyph_width;
  
  glyphs_nits_graphical_matrix(
    1 : nit_graphical_matrix_rows,
    (1 : nit_graphical_matrix_columns) + column_offset
  ) = nit_graphical_matrix;
  
endfor

glyphs_greyscale_with_nits_graphical_matrix = [
  glyphs_greyscale_matrix
  glyphs_nits_graphical_matrix
];

GLYPHS_WITH_NITS_IMAGE_FILE = "glyphs/ascii_with_nits.png";

imwrite (
  glyphs_greyscale_with_nits_graphical_matrix,
  GLYPHS_WITH_NITS_IMAGE_FILE
);
