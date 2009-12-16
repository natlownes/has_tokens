module Mock
  class Token
    def initialize(token_expression, object)
      @object = object
      @expression = token_expression
    end
    
    def tokenize
      #  this is only a mock.  an actual implementation should ensure that the token expression
      #  isn't something like "destroy", for example
      begin
        self.send(@expression) || %{(#{@expression})}
      rescue
        %{(#{@expression})}
      end
    end
    
    # example tokens
    
    def sender
      @object.sender
    end
    
    def receiver
      @object.receiver
    end
    
    def magic_token
      "*****"
    end
    
    def sender_upcase
      @object.sender.upcase
    end
    
    def sender_reverse
      @object.sender.downcase
    end
  end
end