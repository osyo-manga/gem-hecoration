require "hecoration"

extend Hecoration::Decoratable

def deco
	# Wrapping block
	decorator { |f|
		proc {
			puts "--- start ---"
			# Call original method
			f.bind(self).call
			puts "--- end ---"
		}
	}
end

# Wrap method when next defined method.
# Must be call #rebind(Object)
+deco.rebind(Object)
def hello
	puts "hello"
end

hello
# output:
# --- start ---
# hello
# --- end ---


def print_args
	# With arguments.
	decorator { |f|
		proc { |*args|
			puts "args:#{args}"
			f.bind(self).call(*args)
		}
	}
end

+print_args.rebind(Object)
def plus a, b
	a + b
end

puts plus 1, 2
# output:
# args:[1, 2]
# 3

