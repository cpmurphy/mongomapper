require 'test_helper'

class PluginsTest < Test::Unit::TestCase
  should "default plugins to empty array" do
    Class.new { extend MongoMapper::Plugins }.plugins.should == []
  end

  context "ActiveSupport::Concern" do
    module MyConcern
      extend ActiveSupport::Concern

      included do
        attr_accessor :from_concern
      end

      module ClassMethods
        def class_foo
          'class_foo'
        end
      end

      module InstanceMethods
        def instance_foo
          'instance_foo'
        end
      end
    end

    setup do
      @document = Class.new do
        extend MongoMapper::Plugins
        plugin MyConcern
      end
    end

    should "include instance methods" do
      @document.new.instance_foo.should == 'instance_foo'
    end

    should "extend class methods" do
      @document.class_foo.should == 'class_foo'
    end

    should "pass model to configure" do
      @document.new.should respond_to(:from_concern)
    end

    should "add plugin to plugins" do
      @document.plugins.should include(MyConcern)
    end
  end

  context "deprecated plugin" do
    module DeprecatedPlugin
      def self.configure(model)
        model.class_eval { attr_accessor :from_configure }
      end

      module ClassMethods
        def class_foo
          'class_foo'
        end
      end

      module InstanceMethods
        def instance_foo
          'instance_foo'
        end
      end
    end

    setup do
      silence_stderr do
        @document = Class.new do
          extend MongoMapper::Plugins
          plugin DeprecatedPlugin
        end
      end
    end

    should "include instance methods" do
      @document.new.instance_foo.should == 'instance_foo'
    end

    should "extend class methods" do
      @document.class_foo.should == 'class_foo'
    end

    should "pass model to configure" do
      @document.new.should respond_to(:from_configure)
    end

    should "add plugin to plugins" do
      @document.plugins.should include(DeprecatedPlugin)
    end
  end
end