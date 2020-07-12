## do_examples
##
## Convert images in examples directory to ASCII art.

EXAMPLES_DIRECTORY = "examples";
CHARACTERS_PER_LINE = 120;

jpg_files = dir (fullfile (EXAMPLES_DIRECTORY, "*.jpg"));
png_files = dir (fullfile (EXAMPLES_DIRECTORY, "*.png"));
image_files = [
  jpg_files;
  png_files;
];

OUTPUT_EXTS = {".html", ".txt"};

for image_file = image_files'
  
  image_file_name = fullfile (EXAMPLES_DIRECTORY, image_file.name);
  [~, file_name_no_ext] = fileparts (image_file_name);
  
  for n = 1 : numel (OUTPUT_EXTS)
    
    output_file_name = fullfile (
      EXAMPLES_DIRECTORY,
      [file_name_no_ext, OUTPUT_EXTS{n}]
    );
    image_to_ascii (
      image_file_name,
      CHARACTERS_PER_LINE,
      "output", output_file_name
    );
    
  endfor
  
endfor
