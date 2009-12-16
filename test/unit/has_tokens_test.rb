require 'rubygems'
require "#{File.dirname(__FILE__)}/../../init"
Dir[File.dirname(__FILE__) + "/../mocks/**/*.rb"].each {|path| require path }
require 'test/unit'

#  TEST MODEL
# class Message < ActiveRecord::Base
#   has_tokens :in => [:body], :parser => Mock::Parser.new(:tokenizer => Mock::Token)
# end

class HasTokenTest < Test::Unit::TestCase
  def setup
    #  just a note:  the mock parser for this test looks for terms inbetween parenthesis - 
    #  the one in FTT uses uses {}.  just to diffuse any potential confusion
    @message = Message.create do |m|
      m.sender = "Some Name"
      m.receiver = "Another Name"
      m.body = %{
        Oh, hello (receiver),
        
        Maybe you'd like some of this magic dust I've got: (magic_token).
        Here's my name in all caps incase you'd like to use it in a reply where you're frustrated: (sender_upcase)
        
        Sincerely your pal FOR LIFE,
        (sender)
      }
    end
    
    @tokenized_body = %{
      Oh, hello Another Name,
      
      Maybe you'd like some of this magic dust I've got: *****.
      Here's my name in all caps incase you'd like to use it in a reply where you're frustrated: SOME NAME
      
      Sincerely your pal FOR LIFE,
      Another Name
    }
    
    @untokenized_body = %{
      Dear (receiver),
      
      Honk.  (magic_token).
      
      Your pal.
      (sender)
    }
    
    @body_with_non_existent_tokens = %{
      Actually, I guess this should be left up to the Token implementation.  Well, here it is to demonstrate for (clarity).
    }
  end
  
  def test_presence_of_has_tokens_methods
    assert @message.respond_to?(:tokenized)
    assert @message.respond_to?(:tokenized?)
    assert @message.respond_to?(:before_save_without_token_insertion)
    assert @message.respond_to?(:has_tokens_in?)
  end
  
  def test_tracking_of_tokenized_fields
    assert @message.tokenized.include?(:body)
  end
  
  def test_has_tokens_in
    message = Message.new do |m|
      m.body = @untokenized_body
      m.sender = "Ghostface"
      m.receiver = "RZA"
    end
    assert message.has_tokens_in?(:body)
    assert message.save
    assert !message.has_tokens_in?(:body)
  end
  
  def test_token_validation_all_tokens_return_values
    message = Message.new do |m|
      m.body = @body_with_non_existent_tokens
      m.sender = "Ghostface"
      m.receiver = "RZA"
    end
    
    assert !message.save
    assert !message.errors.empty?
    assert_equal "token.tokenizing.error", message.errors.on(:body)
    # one token not found - message body not tokenized
    assert !message.tokenized?
    assert !message.tokenized.include?(:body)
    assert @body_with_non_existent_tokens, message.body
  end
  
  def test_message_tokenized
    assert @message.tokenized?
    # new objects are not tokenized until before save
    assert !Message.new.tokenized?
  end
  
  def test_tokenized_field_tokenization
    assert @tokenized_body, @message.body
  end
  
  def test_tokenizing_on_nil_values
    message = Message.new
    assert message.save
  end
  
end
