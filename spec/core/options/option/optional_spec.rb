require File.dirname(__FILE__) + '/../../../spec_helper'

describe "Rubinius::Options::Option#arg?" do
  it "returns true if the argument has form [ARG]" do
    opt = Rubinius::Options::Option.new nil, nil, "[ARG]", nil, nil
    opt.optional?.should be_true
  end

  it "returns false otherwise" do
    opt = Rubinius::Options::Option.new nil, nil, "ARG", nil, nil
    opt.optional?.should be_false
  end
end
