require "spec_helper"

RSpec.describe Hecoration do
	before do
		module Deco
			include Hecoration::Decoratable

			def deco
				decorator { |f|
					proc { |*args|
						["deco", self, f.bind(self).(*args)]
					}
				}
			end

			def deco2
				decorator { |f|
					proc { |*args|
						["deco2", self, f.bind(self).(*args)]
					}
				}
			end
		end
	end
	let(:class_){
		Class.new {
			extend Deco

			def hoge
			end

			def self.hoge
			end

			def self.method_added name
				@instance_method ||= name
			end

			def self.singleton_method_added name
				return if name == :singleton_method_added
				@singleton_method ||= name
			end
		}
	}
	let(:instance) { class_.new }

	context "Object#decorate_method" do
		using Hecoration
		it { expect {
			class_.decorate_method(:hoge) { |f| proc { } }
		}.not_to change{ class_.instance_exec { @instance_method } } }

		it { expect {
			class_.decorate_singleton_method(:hoge) { |f| proc { } }
		}.not_to change{ class_.instance_exec { @singleton_method } } }
	end

	context "Decorator#wrap" do
		before {
			class_.class_eval {
				+deco
				def imethod1
					:imethod1
				end

				+deco
				+deco
				def imethod2
					:imethod2
				end

				+deco
				+deco2
				def imethod3
					:imethod3
				end

				+deco
				def imethod4
					:imethod4
				end
				def imethod4
					:imethod4
				end

				+deco
				def self.cmethod1
					:cmethod1
				end

				+deco
				def plus a, b
					a + b
				end
			}
		}
		it { expect(class_.instance_exec { @instance_method }).to eq :imethod1 }
		it { expect(class_.instance_exec { @singleton_method }).to eq :cmethod1 }
		it { expect(instance.imethod1).to eq ["deco", instance, :imethod1] }
		it { expect(instance.imethod2).to eq ["deco", instance, ["deco", instance, :imethod2]] }
		it { expect(instance.imethod3).to eq ["deco", instance, ["deco2", instance, :imethod3]] }
		it { expect(instance.imethod4).to eq :imethod4 }
		it { expect(class_.cmethod1).to eq ["deco", class_, :cmethod1] }
		it { expect(instance.plus 1, 2).to eq ["deco", instance, 3] }
	end
end
