require "spec_helper"

RSpec.describe Hecoration::Decoratable do
	let(:class_){
		Class.new {
			extend Hecoration::Decoratable
			def self.deco
				decorator { |*args|
					["deco", self, super(*args)]
				}
			end

			def self.deco2
				decorator { |*args|
					["deco2", self, super(*args)]
				}
			end
		}
	}
	subject(:instance) { class_.new }

	context "#wrap" do
		context "引数がない場合" do
			before do
				class_.class_eval {
					deco.wrap
					def test
						:test
					end

					deco.wrap; deco.wrap
					def test2
						:test2
					end

					deco.wrap; deco2.wrap
					def test3
						:test3
					end

					deco.wrap
					def self.test
						:self_test
					end

					deco.wrap
					deco.wrap
					def self.test2
						:self_test2
					end

					deco.wrap; deco2.wrap
					def self.test3
						:self_test3
					end
				}
			end
			it { expect(instance.test).to  eq ["deco", instance, :test] }
			it { expect(instance.test2).to eq ["deco", instance, ["deco", instance, :test2]] }
			it { expect(instance.test3).to eq ["deco", instance, ["deco2", instance, :test3]] }
			it { expect(class_.test).to    eq ["deco", class_, :self_test] }
			it { expect(class_.test2).to   eq ["deco", class_, ["deco", class_, :self_test2]] }
			it { expect(class_.test3).to   eq ["deco", class_, ["deco2", class_, :self_test3]] }
		end

		context "block を渡した場合" do
			before do
				class_.class_eval {
					deco.wrap {
						def test1 a
							"test1:#{a}"
						end

						def test2 a
							"test2:#{a}"
						end

						def self.test3 a
							"test3:#{a}"
						end
					}
					def test4 a
						"test4:#{a}"
					end
				}
			end

			it { expect(instance.test1(42)).to eq ["deco", instance, "test1:42"] }
			it { expect(instance.test2(42)).to eq ["deco", instance, "test2:42"] }
			it { expect(class_.test3(42)).to   eq ["deco", class_,   "test3:42"] }
			it { expect(instance.test4(42)).to eq "test4:42" }
		end

		context "method_added と singleton_method_added を定義している場合" do
			before do
				class_.class_eval {
					def self.method_added name
						@result ||= []
						@result << name
						super(name)
					end

					def self.singleton_method_added name
						return if name == :singleton_method_added
						@result ||= []
						@result << name
						super(name)
					end

					def test
					end

					deco.wrap
					def test2
					end

					deco.wrap
					def self.test3
					end
				}
			end
			it { expect(class_.class_eval{@result}).to eq [:test, :test2, :test3] }
			it { expect(class_.class_eval{@result}).to eq [:test, :test2, :test3] }
		end

		context "ブロック内で例外が発生した場合" do
			before do
				class_.class_eval {
					begin
						deco.wrap {
							def test1 a
								"test1:#{a}"
							end
							raise
						}
					rescue
					end
					def test2 a
						"test2:#{a}"
					end
				}
			end
			it { expect(instance.test1(42)).to eq ["deco", instance, "test1:42"] }
			it { expect(instance.test2(42)).to eq "test2:42" }
		end
	end
end

RSpec.describe Hecoration::CoreRefine do
	using Hecoration::CoreRefine
	
	let(:class_){
		Class.new {
			extend Hecoration::Decoratable
			def self.deco
				decorator { |a|
					["deco", super(a)]
				}
			end

			def self.test a
				"test:#{a}"
			end

			def test2 a
				"test2:#{a}"
			end
		}
	}

	context "Method#decorate" do
		subject { class_.test(42) }
		context "block を渡した場合" do
			before do
				class_.method(:test).decorate { |a| ["block", super(a)] }
			end
			it { is_expected.to eq ["block", "test:42"] }
		end

		context "Decorator を渡した場合" do
			before do
				class_.method(:test).decorate &class_.deco
			end
			it { is_expected.to eq ["deco", "test:42"] }
		end

		# TODO: 2回ラップしたら2回ラップされてほしい
		xcontext "2回ラップした場合" do
			before do
				class_.method(:test).decorate &class_.deco
				class_.method(:test).decorate &class_.deco
			end
			it { is_expected.to eq ["deco", "test:42"] }
		end
	end

	context "UnboundMethod#decorate" do
		subject { class_.new.test2(42) }

		context "block を渡した場合" do
			before do
				class_.instance_method(:test2).decorate { |a| ["block", super(a)] }
			end
			it { is_expected.to eq ["block", "test2:42"] }
		end

		context "Decorator を渡した場合" do
			before do
				class_.instance_method(:test2).decorate &class_.deco
			end
			it { is_expected.to eq ["deco", "test2:42"] }
		end
	end
end
