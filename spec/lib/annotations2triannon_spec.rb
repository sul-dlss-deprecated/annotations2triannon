require 'spec_helper'

describe Annotations2triannon do

  describe ".configuration" do
    it "should be a configuration object" do
      expect(described_class.configuration).to be_a_kind_of Annotations2triannon::Configuration
    end
  end

  describe "#configure" do
    before :each do
      Annotations2triannon.configure do |config|
        config.debug = true
      end
    end
    it "returns a hash of options" do
      config = Annotations2triannon.configuration
      expect(config).to be_instance_of Annotations2triannon::Configuration
      expect(config.debug).to be_truthy
    end
    after :each do
      Annotations2triannon.reset
    end
  end

  describe ".reset" do
    before :each do
      Annotations2triannon.configure do |config|
        config.debug = true
      end
    end
    it "resets the configuration" do
      Annotations2triannon.reset
      config = Annotations2triannon.configuration
      expect(config).to be_instance_of Annotations2triannon::Configuration
      expect(config.debug).to be_falsey
    end
    after :each do
      Annotations2triannon.reset
    end
  end

end

