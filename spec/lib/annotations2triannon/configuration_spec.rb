require "spec_helper"

module Annotations2triannon

  describe Configuration do

    describe '#debug' do
      it 'default value is false' do
        ENV['DEBUG'] = nil
        config = Configuration.new
        expect(config.debug).to be false
      end
    end
    describe '#debug=' do
      it 'can set value' do
        ENV['DEBUG'] = nil
        config = Configuration.new
        expect(config.debug).to be false
        config.debug = true
        expect(config.debug).to be_truthy
      end
    end

    describe '#limit_random' do
      it 'default value is false' do
        ENV['ANNO_LIMIT_RANDOM'] = nil
        config = Configuration.new
        expect(config.limit_random).to be false
      end
    end
    describe '#limit_random=' do
      it 'can set value' do
        ENV['ANNO_LIMIT_RANDOM'] = nil
        config = Configuration.new
        expect(config.limit_random).to be false
        config.limit_random = true
        expect(config.limit_random).to be true
      end
    end

    describe '#limit_manifests' do
      it 'default value is zero' do
        ENV['ANNO_LIMIT_MANIFESTS'] = nil
        config = Configuration.new
        expect(config.limit_manifests).to eql(0)
      end
    end
    describe '#limit_manifests=' do
      it 'can set value' do
        ENV['ANNO_LIMIT_MANIFESTS'] = nil
        config = Configuration.new
        expect(config.limit_manifests).to eql(0)
        config.limit_manifests = 10
        expect(config.limit_manifests).to eql(10)
      end
    end

    describe '#limit_annolists' do
      it 'default value is zero' do
        ENV['ANNO_LIMIT_ANNOLISTS'] = nil
        config = Configuration.new
        expect(config.limit_annolists).to eql(0)
      end
    end
    describe '#limit_annolists=' do
      it 'can set value' do
        ENV['ANNO_LIMIT_ANNOLISTS'] = nil
        config = Configuration.new
        expect(config.limit_annolists).to eql(0)
        config.limit_annolists = 10
        expect(config.limit_annolists).to eql(10)
      end
    end

    describe '#limit_openannos' do
      it 'default value is zero' do
        ENV['ANNO_LIMIT_OPENANNOS'] = nil
        config = Configuration.new
        expect(config.limit_openannos).to eql(0)
      end
    end
    describe '#limit_openannos=' do
      it 'can set value' do
        ENV['ANNO_LIMIT_OPENANNOS'] = nil
        config = Configuration.new
        expect(config.limit_openannos).to eql(0)
        config.limit_openannos = 10
        expect(config.limit_openannos).to eql(10)
      end
    end

    describe '#array_sampler' do
      it 'returns input array when limit=0, regardless of sampling method' do
        config = Configuration.new
        array = [*0..10]
        limit = 0
        config.limit_random = false
        expect(config.array_sampler(array,limit)).to eql(array)
        config.limit_random = true
        expect(config.array_sampler(array,limit)).to eql(array)
      end
      it 'returns array subset when limit>0, regardless of sampling method' do
        config = Configuration.new
        array = [*0..10]
        limit = 5
        config.limit_random = false
        samples = config.array_sampler(array,limit)
        expect(samples.length).to eql(limit)
        expect(samples.length < array.length).to be true
        config.limit_random = true
        samples = config.array_sampler(array,limit)
        expect(samples.length).to eql(limit)
        expect(samples.length < array.length).to be true
      end
      it 'returns array[0..(limit-1)] when limit>0, without random sampling' do
        config = Configuration.new
        array = [*0..10]
        limit = 5
        config.limit_random = false
        samples = config.array_sampler(array,limit)
        expect(samples.length).to eql(limit)
        expect(samples).to eql(array[0..(limit-1)])
      end
      it 'returns random array subset when limit>0, with random sampling' do
        config = Configuration.new
        array = [*0..100]
        limit = 5
        config.limit_random = true
        samples = config.array_sampler(array,limit)
        expect(samples.length).to eql(limit)
        expect(samples).not_to eql(array[0..(limit-1)])
      end
    end

  end
end
