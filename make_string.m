## string_ = make_string (character_array)
##
## Make string from character array.
##
## Needed because character arrays represent newlines by a new row
## instead of an actual newline character.

function string_ = make_string (character_array)
  
  character_array_rows = rows (character_array);
  newlines_column = "\n"(ones (character_array_rows, 1));
  character_array = [character_array, newlines_column];
  
  string_ = (character_array'(:))';
  
endfunction
