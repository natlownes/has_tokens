has_tokens:  An ActiveRecord plugin for very simple "tokening"
==============================

Evaluates tokens and replaces them with output that you implement.  See test/mocks for an example implementation and some comments.

usage example:
`
	class Message < ActiveRecord::Base
	  has_tokens :in => [:body], :parser => Mock::Parser.new(:tokenizer => Mock::Token)
	end
`

Plugin adds a before_save callback to that model that'll use your parser and tokenizer to replace your tokens with
whatever values your Token returns.  Also adds instance methods to your ActiveRecord object:

`
	has_tokens_in?(field)
	tokenize(field) - output the evaluated text field
	tokenized - array of fields that have been tokenized successfully
	tokenized? - have all relevant fields been tokenized?
`

Your parser is expected to implement instance methods: parse and extract_expressions

