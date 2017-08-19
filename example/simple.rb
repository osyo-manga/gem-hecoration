require "hecoration"

class X
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
		p "hello"
	end
end


