require "hecoration"

# define decorator
module Deco
	# define #decorator
	include Hecoration::Decoratable

	def deco
		# f is original instance method
		decorator { |f|
			# Wrapping method.
			proc { |*args|
				puts "decorating method"
				# Call original method
				f.bind(self).call *args
			}
		}
	end

	def logger
		decorator { |f|
			proc { |*args|
				puts "--- #{f.name} ---"
				puts "args:#{args}"
				puts "result:#{f.bind(self).call *args}"
			}
		}
	end
end

# Decorate class instance method.
class X
	extend Deco

	# Using Module#decorate_method
	using Hecoration

	def hello
		p "hello"
	end
	# decorate method
	decorate_method(:hello, &deco)
	# It is the same as the code
# 	define_method(:hello, &deco.call(instance_method(:hello)))

	# +@ is decorate, when next defined instance_method/class_method.
	+logger
	def initialize n
		@value = n
	end

	+deco
	+logger
	def add n
		@value += n
	end
end


x = X.new 3
# output:
# --- initialize ---
# args:[3]
# result:3

x.hello
# output:
# decorating method
# "hello"

x.add 5
# output:
# decorating method
# --- add ---
# args:[5]
# result:8



