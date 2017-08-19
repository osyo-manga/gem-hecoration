require "hecoration"

def deco
	# Wrapping block
	Hecoration.decorator {
		puts "--- start ---"
		# Call original method
		super()
		puts "--- end ---"
	}
end

# Wrap method when next defined method.
# NOTE: Top level method is non thread safe.
# Because, Object.method_added/Object.singleton_method is defined.
+deco
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
	Hecoration.decorator { |*args|
		puts "args:#{args}"
		super(*args)
	}
end

+print_args
def plus a, b
	a + b
end

puts plus 1, 2
# output:
# args:[1, 2]
# 3

