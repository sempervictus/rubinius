require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/fixtures/classes'

describe "Module#const_get" do

  it "returns the constant with the given name" do
    ModuleSpecs.const_get(:Basic).should == ModuleSpecs::Basic
    ModuleSpecs.const_get("Child").should == ModuleSpecs::Child
  end

  extended_on :rubinius do
    it "returns the value of the constant when a scoped constant name" do
      ModuleSpecs.const_get("Super::SuperChild").should == ModuleSpecs::Super::SuperChild

      lambda {
        ModuleSpecs.const_get("Super::NonExistingConstantName")
      }.should raise_error(NameError)
    end
  end

  it "returns the top-level constant with the given name" do
    ModuleSpecs.const_get(:TopLevelConst).should == TopLevelConst
  end

  it "raises a NameError when there is no constant with the given name" do
    lambda { ModuleSpecs.const_get("NotExistant") }.should raise_error(NameError)
  end

  it "tries to convert the given name to a string using to_str" do
    (o = mock('Parent')).should_receive(:to_str).and_return("Parent")
    ModuleSpecs.const_get(o).should == ModuleSpecs::Parent
  end

  it "raises a TypeError when the given name can't be converted to string using to_str" do
    o = mock('123')
    lambda { ModuleSpecs.const_get(o) }.should raise_error(TypeError)

    o.should_receive(:to_str).and_return(123)
    lambda { ModuleSpecs.const_get(o) }.should raise_error(TypeError)
  end
end
