require "hecoration"

class X
	def initialize name
		@name = name
	end

	# Using .decorator
	extend Hecoration::Decoratable

	def self.deco
		# Wrapping block
		decorator {
			puts "--- start ---"
			# Call original method
			super()
			puts "--- end ---"
		}
	end

	+deco
	# or
	# deco.wrap
	def hello
		p "hello, #{@name}"
	end


	def self.print_args
		# With arguments.
		decorator { |*args|
			puts "args:#{args}"
			super(*args)
		}
	end

	+print_args
	def add x
		@name = "#{@name}, #{x}"
	end
end

x = X.new "mami"

x.hello
# --- start ---
# "hello, mami"
# --- end ---


puts x.add "homu"
# output:
# args:["homu"]
# mami, homu
