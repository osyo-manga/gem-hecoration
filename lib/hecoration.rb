require "unmixer"

module Hecoration
	module Refine
		refine Object do
			using Unmixer

			def silent_eval &block
				m = Module.new {
					[
						:method_added, :singleton_method_added
					].each { |name|
						define_method(name){ |*| }
					}
				}
				singleton_class.prepend m

				begin
					instance_exec &block
				ensure
					singleton_class.unprepend m
				end
			end
		end

		refine Module do
			def decorate_method name, &block
				new_method = block.call(instance_method(name))
				if Method === new_method || UnboundMethod === new_method
					define_method(name, new_method)
				elsif new_method.respond_to? :to_proc
					define_method(name, &new_method)
				else
					name
				end
			end
		end

		refine Object do
			def decorate_singleton_method name, &block
				singleton_class.decorate_method(name, &block)
			end
		end
	end
	include Refine


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
		using Refine
		using Unmixer

		def initialize target, &wrapper
			@target  = target
			@wrapper = wrapper
		end

		def wrap_next_defined_method
			wrapper = @wrapper
			target  = @target
			m = Hecoration.hook_method_added { |name|
				target.singleton_class.unprepend m
				silent_eval { decorate_method(name, &wrapper) }
			}
			# NOTE: hook_method_added の優先度を一番高くするため prepend する
			target.singleton_class.prepend m
		end
		alias_method :+@, :wrap_next_defined_method

		def rebind klass
			Decorator.new klass, &@wrapper
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
end
