## precompute_glyph_properties
##
## Precompute properties of the glyphs in glyphs/ascii.png,
## assumed to contain glyphs for the 95 printable ASCII characters
## `U+0020 SPACE` through `U+007E Tilde` in a single row.

## ----------------------------------------------------------------
## ASCII constants
## ----------------------------------------------------------------

PRINTABLE_ASCII_CODE_POINT_FIRST = 0x0020;
PRINTABLE_ASCII_CODE_POINT_LAST = 0x007E;

PRINTABLE_ASCII_TOTAL_NUMBER = ...
  PRINTABLE_ASCII_CODE_POINT_LAST - PRINTABLE_ASCII_CODE_POINT_FIRST + 1;

## ----------------------------------------------------------------
## Load glyphs from file
## ----------------------------------------------------------------

GLYPHS_IMAGE_FILE = "glyphs/ascii.png";

glyphs_greyscale_matrix = image_file_to_greyscale_matrix (GLYPHS_IMAGE_FILE);

glyph_height = rows (glyphs_greyscale_matrix);
glyph_width = columns (glyphs_greyscale_matrix) / PRINTABLE_ASCII_TOTAL_NUMBER;
glyph_aspect_ratio = glyph_height / glyph_width;

glyphs_block_array = matrix_to_block_array (
  glyphs_greyscale_matrix,
  PRINTABLE_ASCII_TOTAL_NUMBER,
  glyph_aspect_ratio
);

## ----------------------------------------------------------------
## Build [code point, average intensity] table
## ----------------------------------------------------------------

glyph_average_intensities_table = zeros (PRINTABLE_ASCII_TOTAL_NUMBER, 2);

for i = 1 : PRINTABLE_ASCII_TOTAL_NUMBER
  
  glyph_block = glyphs_block_array{i};
  
  code_point = PRINTABLE_ASCII_CODE_POINT_FIRST + i - 1;
  average_intensity = matrix_to_average_intensity (glyph_block);
  
  glyph_average_intensities_table(i,:) = [code_point, average_intensity];
  
endfor

## ----------------------------------------------------------------
## Sort table by average intensity
## ----------------------------------------------------------------

glyph_average_intensities_table = ...
  sortrows (glyph_average_intensities_table, 2);

characters_sorted_by_glyph_average_intensity = ...
  char (glyph_average_intensities_table(:,1)');

fprintf ("\nCharacters sorted by glyph average intensity:\n%s{END}\n\n",
  characters_sorted_by_glyph_average_intensity
)

## ----------------------------------------------------------------
## Normalise average intensities to [0, 1]
## ----------------------------------------------------------------

glyph_average_intensities = glyph_average_intensities_table(:,2);

min_glyph_average_intensity = min (glyph_average_intensities);
max_glyph_average_intensity = max (glyph_average_intensities);

glyph_average_intensities = (
  (glyph_average_intensities - min_glyph_average_intensity)
  / (max_glyph_average_intensity - min_glyph_average_intensity)
);

glyph_average_intensities_table(:,2) = glyph_average_intensities;

## ----------------------------------------------------------------
## Export table
## ----------------------------------------------------------------

PRECOMPUTED_AVERAGE_INTENSITIES_TEXT_FILE = ...
  "glyphs/precomputed_glyph_average_intensities.txt";

dlmwrite (
  PRECOMPUTED_AVERAGE_INTENSITIES_TEXT_FILE,
  glyph_average_intensities_table
);

## ----------------------------------------------------------------
## Export readable version of table (characters instead of code points)
## ----------------------------------------------------------------

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
