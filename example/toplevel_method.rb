require "hecoration"

# Using Object#decorate_singleton_method
using Hecoration

def print_args
	proc { |f|
		proc { |*args|
			puts "args:#{args}"
			f.bind(self).call(*args)
		}
	}
end

def plus a, b
	a + b
end
# Decorate method
decorate_singleton_method(:plus, &print_args)

puts plus 1, 2
# output:
# args:[1, 2]
# 3

