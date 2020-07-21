class Lexer
  KEYWORDS = ["def", "class", "if", "true", "false", "nil"]

  def tokenize(code)
    # Cleanup code by remove extra line break
    code.chomp!

    # Current character position we're parsing
    character = 0

    # Collection of all parsed tokens in the form [:TOKEN_TYPE, value]
    tokens = []

    # Current indent level is the number of space in the last indent
    current_indent = 0

    # We keep track of the indentation levels we are in so that when
    # we dedent, we can check if we're on the correct leve.
    indent_stack = []

    # Scan one character at the time until you find something to parse.
    while character < code.size
      chunk = code[character..-1]

      # Matching standard tokens.

      # Mathing if, print, methods name, etc.
      if identifier = chunk[/\A([a-z]\w*)/, 1]
        # Keywords are special identifiers tagged with their own name,
        # 'if' will result in an [:IF, "if"] token

        if KEYWORDS.include?(identifier)
          tokens << [identifier.upcase.to_sym, identifier]
        # non-keywork identifier include method and variable names
        else
          tokens << [:IDENTIFIER, identifier]
        end

        # Skip what we just parsed
        character += identifier.size
      
      # Matching class names and constants  starting with a capital letter.
      elsif constant = chunk[/\A([A-Z]\w*)/, 1]
        tokens << [:CONSTANT, constant]
        character += constant.size      
      

      elsif number = chunk[/\A([0-9]+)/, 1]
        tokens << [:NUMBER, number.to_i]
        character += number.size            
      

      elsif string =  chunk[/\A"(.*?)"/, 1]
        tokens << [:STRING, string]
        character += string.size + 2
      

      elsif indent = chunk[/\A\:\n( +)/m, 1] # Matches ": <newline> <spaces>"
        # When we create a new block we expect the indent level to go up
        if indent.size <= current_indent
          raise "Bad indent level, got #{indent.size} indents, expected > #{current_indent}" 
        end

        # Adjust the current indentation level
        current_indent = indent.size
        indent_stack << current_indent
        tokens << [:INDENT, indent.size]

        character += indent.size + 2        
      

      # This elsif takes care of the two last cases
      # Case 2: We stay in the same block if the indent level (number of spaces) is the
      # same as current_indent.
      # Case 3: Close the current block, if indent level is lower than current_indent.
      elsif indent = chunk[/\A\n( *)/m, 1] # Matches "<newline> <spaces>"
        if indent.size == current_indent # Case 2
          # Nothing to do, we're still in the same block
          tokens << [:NEWLINE, "\n"]
        
        elsif indent.size < current_indent # Case 3
          while indent.size < current_indent
            indent_stack.pop
            current_indent = indent_stack.first || 0
            tokens << [:DEDENT, indent.size]
          end

          tokens << [:NEWLINE, "\n"]
        else # indent.size > current_indent, error!
          # Cannot increase indent level without using ":", so this is an error.
          raise "Missing ':'"
        end

        character += indent.size + 1

      # Match long operators such as ||, &&, ==, !=, <= and =>
      # One character long operators are matched by the catch all `else` at the bottom
      elsif operator = chunk[/\A(\|\||&&|==|!=|<=|>=)/, 1]
        tokens << [operator, operator]
        character += operator.size

      # Ignore whitespace
      elsif chunk.match(/\A /)
        character += 1
      
      # Catch all single characters
      # We treat all other single character as a Token:  Eg.: ( ) , . ! + - <
      else
        value = chunk[0, 1]
        tokens << [value, value]
        character += 1
      end
    end

    # Close all open blocks
    while indent = indent_stack.pop
      tokens << [:DEDENT, indent_stack.first || 0]
    end

    tokens
  end
end
