## string_ = character_array_to_string (character_array)
##
## Convert character array to string.
## Needed because character arrays represent newlines by a new row
## instead of an actual newline character.

function string_ = character_array_to_string (character_array)
  
  character_array_rows = rows (character_array);
  
  newline_column = "\n"(ones (character_array_rows, 1));
  
  character_array = [character_array, newline_column];
  
  string_ = (character_array'(:))';
  
endfunction
