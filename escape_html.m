## escaped_string = escape_html (string_)
##
## Escape HTML syntax characters &, <, >.

function escaped_string = escape_html (string_)
  
  string_ = strrep (string_, "&", "&amp;");
  string_ = strrep (string_, "<", "&lt;");
  string_ = strrep (string_, ">", "&gt;");
  
  escaped_string = string_;
  
endfunction
