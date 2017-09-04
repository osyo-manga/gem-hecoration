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
				:hoge
			end

			def deco
				:deco
			end

			def self.hoge
				:hoge
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

	context "Module#decorate_method" do

		shared_examples "デコレートする" do |result = :deco|
			it { expect(subject.call).to eq(:hoge) }

			it { is_expected.not_to change{ class_.singleton_class.ancestors } }
			it { is_expected.not_to change{ class_.instance_exec { @instance_method } } }
			it { is_expected.to change{ class_.new.hoge }.from(:hoge).to(result) }
			it { is_expected.to change{ class_.instance_method(:hoge) } }

			context "例外が発生した場合" do
				subject { proc {
					begin
						class_.decorate_method(:hoge) { raise }
					rescue
					end
				} }
				it { is_expected.not_to change{ class_.singleton_class.ancestors } }
			end
		end

		using Hecoration

		context "Proc を返した場合" do
			subject { proc { class_.decorate_method(:hoge) { |f| proc { :deco } } } }
			it_behaves_like "デコレートする"
		end

		context "UnboundMethod を返した場合" do
			subject { proc { class_.decorate_method(:hoge) { |f| class_.instance_method(:deco) } } }
			it_behaves_like "デコレートする"
		end

		context "Method を返した場合" do
			subject { proc { class_.decorate_method(:hoge) { |f| class_.new.method(:deco) } } }
			it_behaves_like "デコレートする"
		end

		context "nil を返した場合" do
			subject { proc { class_.decorate_method(:hoge) { |f| nil } } }
			it { expect(subject.call).to eq(:hoge) }
			it { is_expected.to_not change{ class_.instance_method(:hoge) } }
		end

		context "super() を呼び出した場合" do
			subject {
				Class.new(Class.new { def hoge; :super; end }){
					def hoge; end
					decorate_method(:hoge){ |f| proc { "deco:#{super()}" } }
				}.new.hoge
			}
			it { is_expected.to eq("deco:super") }
		end
	end

	context "Object#decorate_singleton_method" do
		using Hecoration
		subject { proc { class_.decorate_singleton_method(:hoge) { |f| proc { :deco } } } }

		it { expect(subject.call).to eq(:hoge) }
		it { is_expected.to change{ class_.hoge }.from(:hoge).to(:deco) }

		it { expect {
			class_.decorate_singleton_method(:hoge) { |f| proc { } }
		}.not_to change{ class_.instance_exec { @added } } }
	end

	context "Decorator#wrap_next_defined_method" do
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
		it { expect {
			class_.class_eval {
				+deco
			}
		}.to change { class_.singleton_class.ancestors } }
		it { expect {
			class_.class_eval {
				+deco
				def hoge; end
			}
		}.to_not change { class_.singleton_class.ancestors } }
	end
end
