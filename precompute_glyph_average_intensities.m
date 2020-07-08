## precompute_glyph_average_intensities
##
## Precompute average intensities of the glyphs in glyphs/ascii.png,
## assumed to contain glyphs for the 95 printable ASCII characters
## `U+0020 SPACE` through `U+007E Tilde` in a single row. Then:
## 1. Build table with rows [code point, average intensity]
## 2. Sort table by average intensity
## 3. Re-normalise average intensities to the range [0, 255]
## 4. Round average intensities to the nearest integer
## 5. Export table to glyphs/precomputed_glyph_average_intensities.txt.
## Also:
## 6. Export readable version of table with characters instead of code points.

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
## 1.
## ----------------------------------------------------------------

glyph_average_intensities_table = zeros (PRINTABLE_ASCII_TOTAL_NUMBER, 2);

for i = 1 : PRINTABLE_ASCII_TOTAL_NUMBER
  
  code_point = PRINTABLE_ASCII_CODE_POINT_FIRST + i - 1;
  average_intensity = matrix_to_average_intensity (glyphs_block_array{i});
  
  glyph_average_intensities_table(i,1) = code_point;
  glyph_average_intensities_table(i,2) = average_intensity;
  
endfor

## ----------------------------------------------------------------
## 2.
## ----------------------------------------------------------------

glyph_average_intensities_table = ...
  sortrows (glyph_average_intensities_table, 2);

characters_ordered_by_glyph_average_intensity = ...
  char (glyph_average_intensities_table(:,1)');

fprintf ("\nCharacters ordered by glyph average intensity:\n%s{END}\n\n",
  characters_ordered_by_glyph_average_intensity
)

## ----------------------------------------------------------------
## 3.
## ----------------------------------------------------------------

glyph_average_intensities = glyph_average_intensities_table(:,2);

min_glyph_average_intensity = min (glyph_average_intensities);
max_glyph_average_intensity = max (glyph_average_intensities);

MIN_INTENSITY = 0;
MAX_INTENSITY = 255;

glyph_average_intensities = (
  (glyph_average_intensities - min_glyph_average_intensity)
  / (max_glyph_average_intensity - min_glyph_average_intensity)
  * (MAX_INTENSITY - MIN_INTENSITY)
);

## ----------------------------------------------------------------
## 4.
## ----------------------------------------------------------------

glyph_average_intensities = round (glyph_average_intensities);

glyph_average_intensities_table(:,2) = glyph_average_intensities;

## ----------------------------------------------------------------
## 5.
## ----------------------------------------------------------------

PRECOMPUTED_TABLE_TEXT_FILE = ...
  "glyphs/precomputed_glyph_average_intensities.txt";

dlmwrite (PRECOMPUTED_TABLE_TEXT_FILE, glyph_average_intensities_table);

## ----------------------------------------------------------------
## 6.
## ----------------------------------------------------------------

PRECOMPUTED_TABLE_TEXT_FILE_READABLE = ...
  "glyphs/precomputed_glyph_average_intensities_readable.txt";

file_id = fopen (PRECOMPUTED_TABLE_TEXT_FILE_READABLE, "w");

for i = 1 : PRINTABLE_ASCII_TOTAL_NUMBER
  
  code_point = glyph_average_intensities_table(i,1);
  character = char (code_point);
  
  average_intensity = glyph_average_intensities_table(i,2);
  
  fprintf(file_id, "%s %i", character, average_intensity);
  fprintf(file_id, "\n");
  
endfor

fclose (file_id);
