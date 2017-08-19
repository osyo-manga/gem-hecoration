require "hecoration/version"
# require "hecoration/decoratable"
require "unmixer"

module Hecoration
	module CoreRefine
		refine ::Method do
			def decorate &block
				name = self.name
				owner.prepend Module.new { define_method(name, &block) }
			end
		end

		refine ::UnboundMethod do
			def decorate &block
				name = self.name
				owner.prepend Module.new { define_method(name, &block) }
			end
		end
	end

	module_function def hook_method_added &block
		Module.new {
			define_method(:method_added){ |name|
				instance_exec name, &block
				super(name)
			}
			define_method(:singleton_method_added){ |name|
				singleton_class.instance_exec name, &block
				super(name)
			}
		}
	end

	class Decorator
		using ::Unmixer
		using ::Hecoration::CoreRefine

		def initialize target, &wrapper
			@target = target
			@wrapper = wrapper
		end

		def wrap &block
			wrapper = @wrapper
			target  = @target
			if block
				unextend = wrap_all
				begin
					@target.class_eval &block
				ensure
					unextend.call
				end
			else
				m = Hecoration.hook_method_added { |name|
					prepend Module.new { define_method(name, &wrapper) }
					target.unextend m
				}
				target.extend m
			end
		end
		alias_method :+@, :wrap

		def wrap_all
			wrapper = @wrapper
			m = Hecoration.hook_method_added { |name|
				prepend Module.new { define_method(name, &wrapper) }
			}
			@target.extend m
			proc { @target.unextend m }
		end

		def to_proc
			@wrapper
		end
	end

	module Decoratable
		def decorator &block
			Decorator.new self, &block
		end
	end

	module_function def decorator &block
		Decorator.new Object, &block
	end
end
