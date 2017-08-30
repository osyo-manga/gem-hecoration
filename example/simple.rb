require "hecoration"

class X
	#==================================
	# decorate defined method

	# Using Module#decorate_method
	using Hecoration

	def hello1
		p "hello1"
	end

	# decorate #hello1
	# f is original instance_method
	decorate_method(:hello1){ |f|
		proc {
			puts "--- deco ---"
			# Call original method
			f.bind(self).call
			puts "--- end ---"
		}
	}

	#==================================
	# define method with decorate

	# Using .decorator
	extend Hecoration::Decoratable

	# Define decorator
 	# f is original instance_method
	deco = decorator { |f|
		proc {
			puts "--- deco ---"
			# Call original method
			f.bind(self).call
			puts "--- end ---"
		}
	}

	# +@ is decorate, when next defined method.
	+deco
	def hello2
		p "hello2"
	end
end

x = X.new

x.hello1
# output:
# --- deco ---
# "hello1"
# --- end ---


x.hello2
# output:
# --- deco ---
# "hello2"
# --- end ---


