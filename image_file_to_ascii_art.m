## ascii_art = image_file_to_ascii_art (file_name, characters_per_line)
##
## Load image from file and convert to ASCII art.
## Assumes glyph aspect ratio of 2 (see README.md).

function ascii_art = image_file_to_ascii_art (file_name, characters_per_line)
  
  PRINTABLE_ASCII_CODE_POINT_FIRST = 0x0020;
  
  MIN_INTENSITY = 0;
  MAX_INTENSITY = 255;
  
  GLYPH_ASPECT_RATIO = 2;
  AVERAGE_INTENSITY_TOLERANCE = 10;
  
  PRECOMPUTED_AVERAGE_INTENSITIES_TEXT_FILE = ...
    "glyphs/precomputed_glyph_average_intensities.txt";
  GLYPH_AVERAGE_INTENSITIES_TABLE = ...
    dlmread (PRECOMPUTED_AVERAGE_INTENSITIES_TEXT_FILE);
  
  SORTED_CODE_POINTS_VECTOR = GLYPH_AVERAGE_INTENSITIES_TABLE(:,1);
  GLYPH_AVERAGE_INTENSITIES_VECTOR = GLYPH_AVERAGE_INTENSITIES_TABLE(:,2);
  
  PRECOMPUTED_NITS_TEXT_FILE = "glyphs/precomputed_glyph_nits.txt";
  GLYPH_NITS_TABLE = dlmread (PRECOMPUTED_NITS_TEXT_FILE);
  
  GLYPH_NITS_VECTOR = GLYPH_NITS_TABLE(:,2);
  
  greyscale_matrix = image_file_to_greyscale_matrix (file_name);
  
  block_array = matrix_to_block_array (
    greyscale_matrix,
    characters_per_line,
    GLYPH_ASPECT_RATIO
  );
  
  ascii_art = zeros (size (block_array));
  
  for i = 1 : numel (block_array)
    
    block = block_array{i};
    
    block_average_intensity = matrix_to_average_intensity (block);
    
    average_intensity_window_lower_bound = max (
      block_average_intensity - AVERAGE_INTENSITY_TOLERANCE,
      MIN_INTENSITY
    );
    average_intensity_window_upper_bound = min (
      block_average_intensity + AVERAGE_INTENSITY_TOLERANCE,
      MAX_INTENSITY
    );
    average_intensity_window = [ ...
      average_intensity_window_lower_bound, ...
      average_intensity_window_upper_bound
    ];
    
    preselected_average_intensity_index_window = ...
      lookup (GLYPH_AVERAGE_INTENSITIES_VECTOR, average_intensity_window);
    preselected_average_intensity_index_range = ...
      preselected_average_intensity_index_window(1) : ...
      preselected_average_intensity_index_window(2);
    
    block_nit = matrix_to_nit (block, block_average_intensity);
    
    preselected_code_points = ...
      SORTED_CODE_POINTS_VECTOR(preselected_average_intensity_index_range);
    
    preselected_nit_indices = ...
      preselected_code_points - PRINTABLE_ASCII_CODE_POINT_FIRST + 1;
    
    preselected_nit_distances = zeros (size (preselected_nit_indices));
    
    for j = 1 : numel (preselected_nit_distances)
      
      preselected_nit_index = preselected_nit_indices(j);
      preselected_nit = GLYPH_NITS_VECTOR(preselected_nit_index);
      
      preselected_nit_distances(j) = nit_distance (block_nit, preselected_nit);
      
    endfor
    
    [~, nearest_nit_first_index] = min (preselected_nit_distances);
    best_code_point = preselected_code_points(nearest_nit_first_index);
    
    ascii_art(i) = best_code_point;
    
  endfor
  
  ascii_art = char (ascii_art);
  
endfunction
