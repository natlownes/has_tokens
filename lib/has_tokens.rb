module Forthill
  module Has
    module Tokens
      def self.included(ar_base)
        ar_base.extend(ClassMethods)
      end
    
      module ClassMethods
        def has_tokens(opts={})
          # ex.  :in => [:body], :parser => Honk::Parser.new(:tokenizer => Honk::Token)
          # Parser should implement instance methods: extract_expressions(String) and parse(String, :object => some_object)
          raise("#{opts[:parser].class.name} doesn't respond to 'parse' method") unless opts[:parser].respond_to?(:parse)
          write_inheritable_attribute(:tokenizable_attributes, (opts[:in] || []))
          write_inheritable_attribute(:token_parser, opts[:parser])
          include Forthill::Has::Tokens::InstanceMethods
          validate            :all_tokens_return_values
          alias_method_chain  :before_save, :token_insertion
        end #has_tokens
      end #ClassMethods
      
      module InstanceMethods
        
        def has_tokens_in?(field)
          return false if self[field].blank?
          !parser_extract_expressions(self[field.to_sym]).empty?
        end
        
        def tokenize(field)
          parser_parse(self[field])
        end
        
        def tokenized
          tokenized_attributes.keys
        end
        
        def tokenized?
          return false if self.new_record?
          !self.class.read_inheritable_attribute(:tokenizable_attributes).any? {|field| has_tokens_in?(field) }
        end
        
        private
        
        def tokenized_attributes
          @tokenized_attributes ||= {}
        end
        
        def all_tokens_return_values
          fields_having_tokens().each do |field|
            str = parser_parse(self[field])
            expressions = parser_extract_expressions(str)
            unless expressions.empty?
              self.errors.add(field, "token.tokenizing.error")
            end
          end
        end
        
        def before_save_with_token_insertion
          if !tokenized?
            fields = fields_having_tokens()
            fields.each do |field|
              original_value = self[field]
              self[field] = self.tokenize(field)
              # no tokens left, all tokens converted, 
              if !has_tokens_in?(field)
                tokenized_attributes[field] = original_value
              end
            end
          end
          before_save_without_token_insertion
        end
      end #before_save_with_token_insertion
      
      def fields_having_tokens
        fields = self.class.read_inheritable_attribute(:tokenizable_attributes)
        fields.select {|field| !self[field].blank? }
      end
      
      def parser_extract_expressions(str)
        self.class.read_inheritable_attribute(:token_parser).extract_expressions(str)
      end
      
      def parser_parse(str)
        self.class.read_inheritable_attribute(:token_parser).parse(str, :object => self)
      end
      
    end # Tokens
  end # Has
end #fh
ActiveRecord::Base.send(:include, Forthill::Has::Tokens)