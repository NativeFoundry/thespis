require 'spec_helper'

describe Thespis::Runner do
  it "responds" do
    expect(Thespis::Runner.greet).to eq("Hello")
  end

  context "pulling from playbill" do
    it "returns an array" do
      expect(Thespis::Runner.pull_playbill("DC").class).to eql(Array)
    end
  end
end