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
	deco = proc { |f|
		proc {
			puts "--- deco ---"
			# Call original method
			f.bind(self).call
			puts "--- end ---"
		}
	}
	decorate_method(:hello1, &deco)
	# It is the same as the code
# 	define_method(:hello1, &deco.call(instance_method(:hello1)))

	#==================================
	# define method with decorate

	# Using .decorator
	extend Hecoration::Decoratable

	# Define decorator
	# .decorator return Hecoration::Decorator.new self, &block
	# self is adding .method_added/.singleton_method_added
 	# f is original instance_method
	deco = decorator { |f|
		proc {
			puts "--- deco ---"
			# Call original method
			f.bind(self).call
			puts "--- end ---"
		}
	}

	# +@ is decorate, when next defined instance_method/class_method.
	# added self.method_added and self.singleton_method_added
	+deco
	def hello2
		p "hello2"
	end
	# removed self.method_added and self.singleton_method_added
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


