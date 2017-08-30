require "hecoration"

module Deco
	include Hecoration::Decoratable

	def print_args
		decorator { |f|
			proc { |*args|
				p "args : #{args}"
				f.bind(self).call *args
			}
		}
	end

	def memoize
		cache = {}
		decorator { |f|
			proc { |*args|
				cache[args] = f.bind(self).call *args unless cache.has_key? args
				cache[args]
			}
		}
	end
end

class X
	extend Deco

	+print_args
	def plus a, b
		a + b
	end
	
	+memoize
	def fibonacci n
		n > 1 ? fibonacci(n - 2) + fibonacci(n - 1) : n
	end
	# or
# 	decorate_method(:fibonacci, &memoize)
end

x = X.new

p x.plus 1, 2
# output:
# "args : [1, 2]"
# 3


p X.new.fibonacci 50
# => 12586269025

