if !ActiveRecord::Base.connected?
  ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')
  load "#{File.dirname(__FILE__)}/../schema/test_schema.rb"      
end

class Message < ActiveRecord::Base
  has_tokens :in => [:body], :parser => Mock::Parser.new(:tokenizer => Mock::Token)
end