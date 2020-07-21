
require 'test/unit'
extend Test::Unit::Assertions

require_relative '../lexer.rb'

code = <<-CODE
if 1:
  print "..."
  if false:
    pass  
  print "done!"
print "The End"
CODE

tokens = [
  [:IF, "if"], [:NUMBER, 1],
  [:INDENT, 2],
  [:IDENTIFIER, "print"], [:STRING, "..."], [:NEWLINE, "\n"],
  [:IF, "if"], [:FALSE, "false"],
  [:INDENT, 4],
  [:IDENTIFIER, "pass"],
  [:DEDENT, 2], [:NEWLINE, "\n"],
  [:IDENTIFIER, "print"],
  [:STRING, "done!"],
  [:DEDENT, 0], [:NEWLINE, "\n"],
  [:IDENTIFIER, "print"], [:STRING, "The End"]
]

assert_equal tokens, Lexer.new.tokenize(code)
