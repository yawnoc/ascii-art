## precompute_glyph_average_intensities
##
## Precompute average intensities of the glyphs in glyphs/ascii.png,
## assumed to contain glyphs for the 95 printable ASCII characters
## `U+0020 SPACE` through `U+007E Tilde` in a single row.

## ----------------------------------------------------------------
## Printable ASCII constants
## ----------------------------------------------------------------

CODE_POINT_FIRST = 0x0020;
CODE_POINT_LAST = 0x007E;

CODE_POINT_RANGE = CODE_POINT_FIRST : CODE_POINT_LAST;
CODE_POINT_COUNT = numel (CODE_POINT_RANGE);

## ----------------------------------------------------------------
## Load glyphs from file
## ----------------------------------------------------------------

GLYPHS_IMAGE_FILE = "glyphs/printable_ascii.png";

glyphs_image = image_read_greyscale (GLYPHS_IMAGE_FILE);

glyph_height = rows (glyphs_image);
glyph_width = columns (glyphs_image) / CODE_POINT_COUNT;

glyph_aspect_ratio = glyph_height / glyph_width;

glyphs_image_subdivided = subdivide_matrix (
  glyphs_image,
  CODE_POINT_COUNT,
  glyph_aspect_ratio
);

## ----------------------------------------------------------------
## Compute average intensities
## ----------------------------------------------------------------

average_intensities = zeros (CODE_POINT_COUNT, 1);

for i = 1 : CODE_POINT_COUNT
  
  average_intensities(i) = ...
    matrix_to_average_intensity (glyphs_image_subdivided{i});
  
endfor

## ----------------------------------------------------------------
## Normalise average intensities to [0, 1]
## ----------------------------------------------------------------

min_average_intensity = min (average_intensities);
max_average_intensity = max (average_intensities);

average_intensities = (
  (average_intensities - min_average_intensity)
  / (max_average_intensity - min_average_intensity)
);

## ----------------------------------------------------------------
## Build and sort [code point, average intensity] table
## ----------------------------------------------------------------

average_intensities_table = [CODE_POINT_RANGE', average_intensities];

[average_intensities_table, sorting_indices] = ...
  sortrows (average_intensities_table, 2);

code_points = average_intensities_table(:,1);
characters = char (code_points);

average_intensities = average_intensities_table(:,2);

## ----------------------------------------------------------------
## Export table
## ----------------------------------------------------------------

PRECOMPUTED_AVERAGE_INTENSITIES_TEXT_FILE = ...
  "glyphs/precomputed_average_intensities.txt";

dlmwrite (
  PRECOMPUTED_AVERAGE_INTENSITIES_TEXT_FILE,
  average_intensities_table
);

## ----------------------------------------------------------------
## Export readable version of table (with characters instead of code points)
## ----------------------------------------------------------------

PRECOMPUTED_AVERAGE_INTENSITIES_TEXT_FILE_READABLE = ...
  "glyphs/precomputed_average_intensities_readable.txt";

file_id = fopen (PRECOMPUTED_AVERAGE_INTENSITIES_TEXT_FILE_READABLE, "w");

for i = 1 : CODE_POINT_COUNT
  
  fprintf(file_id, "%s %i", characters(i), average_intensities(i));
  fprintf(file_id, "\n");
  
endfor

fclose (file_id);

## ----------------------------------------------------------------
## Export graphical version of table
## ----------------------------------------------------------------

glyphs_image_sorted = cell2mat ({glyphs_image_subdivided{sorting_indices}});

glyph_sized_ones = ones (glyph_height, glyph_width);

average_intensities_image = kron (average_intensities', glyph_sized_ones);

average_intensities_table_graphical = ...
  [glyphs_image_sorted; average_intensities_image];

PRECOMPUTED_AVERAGE_INTENSITIES_IMAGE_FILE_GRAPHICAL = ...
  "glyphs/precomputed_average_intensities_graphical.png";

imwrite (
  average_intensities_table_graphical,
  PRECOMPUTED_AVERAGE_INTENSITIES_IMAGE_FILE_GRAPHICAL
);

## ----------------------------------------------------------------
## Print info
## ----------------------------------------------------------------

fprintf (
  "\nCharacters sorted by glyph average intensity:\n%s{END}\n\n",
  characters
);
