## escaped_string = escape_html_syntax_characters (string_)
##
## Escape the three HTML syntax characters &, <, >.

function escaped_string = escape_html_syntax_characters (string_)
  
  string_ = strrep (string_, "&", "&amp;");
  string_ = strrep (string_, "<", "&lt;");
  string_ = strrep (string_, ">", "&gt;");
  
  escaped_string = string_;
  
endfunction