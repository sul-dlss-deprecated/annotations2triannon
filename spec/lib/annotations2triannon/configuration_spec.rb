require "spec_helper"

module Annotations2triannon

  describe Configuration do

    describe '#debug' do
      it 'default value is false' do
        ENV['DEBUG'] = nil
        config = Configuration.new
        expect(config.debug).to be_falsey
      end
    end

    describe '#debug=' do
      it 'can set value' do
        config = Configuration.new
        config.debug = true
        expect(config.debug).to be_truthy
      end
    end

  end
end
