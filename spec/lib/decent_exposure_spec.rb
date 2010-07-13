require 'helper'

describe DecentExposure do
  before do
    class Controller
      extend DecentExposure
      def self.helper_method(*args); end
      def self.hide_action(*args); end
      def memoizable(arg); arg; end
    end
  end

  context 'classes extending DecentExposure' do
    subject { Controller }
    specify { should respond_to(:expose) }
    specify { should respond_to(:default_exposure) }
  end

  context '.expose' do
    let(:instance) { Controller.new }

    it 'creates a method with the given name' do
      Controller.class_eval { expose(:my_resource) }
      instance.methods.should include('my_resource')
    end

    it 'prevents the method from being a callable action' do
      Controller.expects(:hide_action).with(:blerg)
      Controller.class_eval { expose(:blerg) }
    end

    it 'declares the method as a helper method' do
      Controller.expects(:helper_method).with(:blarg)
      Controller.class_eval { expose(:blarg) }
    end

    it 'returns the result of the exposed block from the method' do
      Controller.class_eval do
        expose(:resource) { memoizable("I'm a resource!") }
      end
      instance.resource.should == "I'm a resource!"
    end

    it 'memoizes the value of the created method' do
      instance.expects(:memoizable).once.returns('value')
      2.times { instance.resource }
    end

    context '.default_exposure' do
      context 'when the default_exposure is overridden' do
        before do
          Controller.class_eval do
            default_exposure { 'default value' }
            expose :resource
          end
        end
        it 'uses the overridden default_exposure' do
          instance.resource.should == 'default value'
        end
      end

      context 'with named arguments' do
        it 'makes the named arguments available' do
          Controller.class_eval do
            default_exposure {|name| "I gots me an #{name}"}
            expose :other_resource
          end
          instance.other_resource.should == 'I gots me an other_resource'
        end
      end
    end
  end
end
