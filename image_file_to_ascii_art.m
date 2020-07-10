## ascii_art = image_file_to_ascii_art (
##   file_name, characters_per_line, property, value, ...
## )
## Load image from file and convert to ASCII art.
## Returns ASCII art character array.
## The following properties may be set:
## * "output" (default: "")
##   Name of output file.
##   If empty, ASCII art is not written to output file.
##   If non-empty, must be *.html or *.txt.

function ascii_art = image_file_to_ascii_art (
  file_name, characters_per_line, varargin
)
  ERROR_PREFIX = "image_file_to_ascii_art: ";
  
  DEFAULT_PROPERTIES = {
    "output", "",
    {}{:}
  };
  
  [~, output_file_name] = ...
    parseparams (varargin, DEFAULT_PROPERTIES{:});
  
  if strcmp (output_file_name, "")
    
    output_type = "none";
    
  elseif !isempty (regexp (output_file_name, "\.html$"))
    
    OUTPUT_TEMPLATE_HTML_FILE = "output_template.html";
    
    if strcmp (output_file_name, OUTPUT_TEMPLATE_HTML_FILE)
      error ([ERROR_PREFIX, "You fool. Don't overwrite the template file!"]);
    endif
    
    output_type = "html";
    
  elseif !isempty (regexp (output_file_name, "\.txt$"))
    
    output_type = "txt";
    
  else
    
    error ([ERROR_PREFIX, "\"output\" must be *.html or *.txt"]);
    
  endif
  
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
  
  if !strcmp (output_type, "none")
    
    ascii_art_string = character_array_to_string (ascii_art);
    
  endif
  
  switch (output_type)
    
    case "html"
      
      ascii_art_string = escape_html_syntax_characters (ascii_art_string);
      
      output_template_html = fileread (OUTPUT_TEMPLATE_HTML_FILE);
      title_string = escape_html_syntax_characters (file_name);
      
      file_id = fopen (output_file_name, "w");
      fprintf (file_id, output_template_html, title_string, ascii_art_string);
      fclose (file_id);
    
    case "txt"
      
      file_id = fopen (output_file_name, "w");
      fprintf (file_id, "%s", ascii_art_string);
      fclose (file_id);
    
  endswitch
  
endfunction
