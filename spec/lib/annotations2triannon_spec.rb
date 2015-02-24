require 'spec_helper'

describe Annotations2triannon do
  describe ".configuration" do
    it "should be a configuration object" do
      expect(described_class.configuration).to be_a_kind_of Annotations2triannon::Configuration
    end
  end
end
