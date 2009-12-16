module Mock
  class Parser
    def initialize(opts={})
      @scanner = %r{\(\w+\)}
      @tokenizer = opts[:tokenizer]
    end
    
    def parse(text="", opts={})
      return text unless opts[:object]
      str = text.dup
      expressions = extract_expressions(text)
      expressions.each do |expression|
        str.gsub!(expression, parse_expression(expression, opts[:object]))
      end
      str
    end
    
    def parse_expression(token_expression, object)
      token = @tokenizer.new(strip_token_identifiers(token_expression), object)
      return token.tokenize
    end
    
    def extract_expressions(str)
      str.scan(@scanner).map {|f| f }
    end
    
    private
    
    def strip_token_identifiers(str)
      str.gsub(%r{^\(|\)$}, "")
    end
    
  end
end
    