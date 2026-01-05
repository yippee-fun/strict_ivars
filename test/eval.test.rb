# frozen_string_literal: true

test "eval with included path" do
	assert_raises StrictIvars::NameError do
		eval <<~RUBY, binding, __FILE__, __LINE__ + 1
			@hello
		RUBY
	end
end

test "eval with excluded path" do
	refute_raises do
		eval <<~RUBY, binding, "./excluded.rb", __LINE__ + 1
			@hello
		RUBY
	end
end

test "eval with implicit path" do
	assert_raises StrictIvars::NameError do
		eval <<~RUBY, binding
			@hello
		RUBY
	end
end

test "eval with shorthand string interpolation" do
	assert_raises StrictIvars::NameError do
		eval <<~'RUBY', binding, __FILE__, __LINE__ + 1
			"hello #@name"
		RUBY
	end
end
