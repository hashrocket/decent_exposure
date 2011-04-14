require 'helper'

describe DecentExposure do

  class Controller
    extend DecentExposure
    def self.helper_method(*args); end
    def self.hide_action(*args); end
    def self.before_filter(*args); end
    def memoizable(arg); arg; end
  end

  context 'classes extending DecentExposure' do
    subject { Controller }
    specify { should respond_to(:expose) }
    specify { should respond_to(:expose!) }
    specify { should respond_to(:default_exposure) }
  end

  context '.expose' do
    let(:controller) { Class.new(Controller){ expose(:resource) } }
    let(:instance) { controller.new }

    it 'creates a method with the given name' do
      instance.should respond_to(:resource)
    end

    it 'prevents the method from being a callable action' do
      controller.expects(:hide_action).with(:resources)
      controller.class_eval { expose(:resources) }
    end

    it 'declares the method as a helper method' do
      controller.expects(:helper_method).with(:resources)
      controller.class_eval { expose(:resources) }
    end

    context 'custom exposures' do
      before do
        controller.class_eval do
          expose(:resource) { memoizable("I'm a resource!") }
        end
      end

      it 'returns the result of the exposed block from the method' do
        instance.resource.should == "I'm a resource!"
      end

      it 'memoizes the value of the created method' do
        instance.expects(:memoizable).once.returns('value')
        2.times { instance.resource }
      end
    end

    context '.default_exposure' do
      let(:defaulted_controller) { Class.new(Controller) }
      let(:instance) { defaulted_controller.new }
      context 'when the default_exposure is overridden' do
        before do
          defaulted_controller.class_eval do
            default_exposure { 'default value' }
            expose(:default)
          end
        end
        it 'uses the overridden default_exposure' do
          instance.default.should == 'default value'
        end
      end

      context 'with named arguments' do
        it 'makes the named arguments available' do
          defaulted_controller.class_eval do
            default_exposure {|name| "I got: '#{name}'"}
            expose :default
          end
          instance.default.should == "I got: 'default'"
        end
      end
    end
  end

  context '.expose!' do
    let(:controller) { Class.new(Controller){ expose(:resource) } }
    let(:instance) { controller.new }

    it 'creates a method with the given name' do
      instance.should respond_to(:resource)
    end

    it 'prevents the method from being a callable action' do
      controller.expects(:hide_action).with(:resources)
      controller.class_eval { expose!(:resources) }
    end

    it 'declares the method as a helper method' do
      controller.expects(:helper_method).with(:resources)
      controller.class_eval { expose!(:resources) }
    end

    it 'adds a before filter to pre-cache the method' do
      controller.expects(:before_filter).with(:resources, {})
      controller.class_eval { expose!(:resources) }
    end

    it 'sends options along to before filter' do
      controller.expects(:before_filter).with(:resources, :only => [:index, :custom])
      controller.class_eval { expose!(:resources, :only => [:index, :custom]) }
    end
  end
end
