require "hecoration"

class X
	def initialize name
		@name = name
	end

	# Using .decorator
	extend Hecoration::Decoratable

	def self.deco
		# f is decorat instance_method
		decorator { |f|
			proc {
				puts "--- start ---"
				# Call original method
				f.bind(self).call
				puts "--- end ---"
			}
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
		decorator { |f|
			proc { |*args|
				puts "args:#{args}"
				f.bind(self).call(*args)
			}
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

