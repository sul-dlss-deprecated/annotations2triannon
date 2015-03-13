require 'spec_helper'

describe Annotations2triannon::OpenAnnotation do

  let(:g1) {
    Annotations2triannon::OpenAnnotation.new RDF::Graph.new.from_ttl("
      <http://my.identifiers.com/oa_comment> a <http://www.w3.org/ns/oa#Annotation>;
      <http://www.w3.org/ns/oa#hasBody> [
      a <http://www.w3.org/2011/content#ContentAsText>,
      <http://purl.org/dc/dcmitype/Text>;
      <http://www.w3.org/2011/content#chars> \"I love this!\"
      ];
      <http://www.w3.org/ns/oa#hasTarget> <http://purl.stanford.edu/kq131cs7229>;
      <http://www.w3.org/ns/oa#motivatedBy> <http://www.w3.org/ns/oa#commenting> ;
      <http://www.w3.org/ns/oa#annotatedBy> <http://my.identifiers.com/contributor> . ")
  }

  let(:g2) {
    Annotations2triannon::OpenAnnotation.new RDF::Graph.new.from_jsonld(
      '{
        "@context": "http://www.w3.org/ns/oa-context-20130208.json",
        "@id": "http://my.identifiers.com/oa_bookmark",
        "@type": "oa:Annotation",
        "motivatedBy": "oa:bookmarking",
        "hasTarget": "http://purl.stanford.edu/kq131cs7229"
      }' )
  }

  let(:g3) {
    Annotations2triannon::OpenAnnotation.new RDF::Graph.new.from_jsonld(
      '{
        "@context": "http://www.w3.org/ns/oa-context-20130208.json",
        "@id": "http://my.identifiers.com/oa_empty",
        "@type": "oa:Annotation"
      }' )
  }

  context '#annotatedBy' do
    it 'returns an array' do
      expect(g1.annotatedBy).to be_a Array
      expect(g1.annotatedBy).not_to be_empty
      expect(g3.annotatedBy).to be_a Array
      expect(g3.annotatedBy).to be_empty
    end
  end

  context '#annotatedBy?' do
    it 'returns a boolean' do
      expect(g1.annotatedBy?).to be_truthy
      expect(g2.annotatedBy?).to be_falsy
      expect(g3.annotatedBy?).to be_falsy
    end
    it 'accepts a string URI' do
      uri = 'http://my.identifiers.com/contributor'
      expect(g1.annotatedBy? uri).to be_truthy
      expect(g2.annotatedBy? uri).to be_falsy
      expect(g3.annotatedBy? uri).to be_falsy
    end
    it 'accepts an Addressable::URI' do
      uri = 'http://my.identifiers.com/contributor'
      uri = Addressable::URI.parse(uri)
      expect(g1.annotatedBy? uri).to be_truthy
      expect(g2.annotatedBy? uri).to be_falsy
      expect(g3.annotatedBy? uri).to be_falsy
    end
    it 'accepts an RDF::URI' do
      uri = 'http://my.identifiers.com/contributor'
      uri = RDF::URI.parse(uri)
      expect(g1.annotatedBy? uri).to be_truthy
      expect(g2.annotatedBy? uri).to be_falsy
      expect(g3.annotatedBy? uri).to be_falsy
    end
  end

  context '#hasBody' do
    it 'returns an array' do
      expect(g1.hasBody).to be_a Array
      expect(g1.hasBody).not_to be_empty
      expect(g2.hasBody).to be_a Array
      expect(g2.hasBody).to be_empty
      expect(g3.hasBody).to be_a Array
      expect(g3.hasBody).to be_empty
    end
  end

  context '#hasBody?' do
    it 'returns a boolean' do
      expect(g1.hasBody?).to be_truthy
      expect(g2.hasBody?).to be_falsy  # note g1 and g2 are truthy here
      expect(g3.hasBody?).to be_falsy
    end
  end

  context '#hasTarget' do
    it 'returns an array' do
      expect(g1.hasTarget).to be_a Array
      expect(g1.hasTarget).not_to be_empty
      expect(g2.hasTarget).to be_a Array
      expect(g2.hasTarget).not_to be_empty
      expect(g3.hasTarget).to be_a Array
      expect(g3.hasTarget).to be_empty
    end
  end

  context '#hasTarget?' do
    it 'returns a boolean' do
      expect(g1.hasTarget?).to be_truthy
      expect(g2.hasTarget?).to be_truthy
      expect(g3.hasTarget?).to be_falsy
    end
  end

  context '#motivatedBy' do
    it 'returns an array' do
      expect(g1.motivatedBy).to be_a Array
      expect(g1.motivatedBy).not_to be_empty
      expect(g3.motivatedBy).to be_a Array
      expect(g3.motivatedBy).to be_empty
    end
  end

  context '#motivatedBy?' do
    it 'returns a boolean' do
      expect(g1.motivatedBy?).to be_truthy
      expect(g2.motivatedBy?).to be_truthy  # note g1 and g2 are truthy here
      expect(g3.motivatedBy?).to be_falsy
    end
    it 'accepts a string URI' do
      uri = 'http://www.w3.org/ns/oa#commenting'
      expect(g1.motivatedBy? uri).to be_truthy
      expect(g2.motivatedBy? uri).to be_falsy  # note g1 and g2 differ here
      expect(g3.motivatedBy? uri).to be_falsy
    end
    it 'accepts an Addressable::URI' do
      uri = Addressable::URI.parse('http://www.w3.org/ns/oa#commenting')
      expect(g1.motivatedBy? uri).to be_truthy
      expect(g2.motivatedBy? uri).to be_falsy  # note g1 and g2 differ here
      expect(g3.motivatedBy? uri).to be_falsy
    end
    it 'accepts an RDF::URI' do
      uri = RDF::URI.parse('http://www.w3.org/ns/oa#commenting')
      expect(g1.motivatedBy? uri).to be_truthy
      expect(g2.motivatedBy? uri).to be_falsy  # note g1 and g2 differ here
      expect(g3.motivatedBy? uri).to be_falsy
    end
  end

  context '#open_annotation?' do
    it 'returns a boolean' do
      expect(g1.open_annotation?).to be_truthy
      expect(g2.open_annotation?).to be_falsy  # note g1 and g2 are truthy here
      expect(g3.open_annotation?).to be_falsy
    end
  end

  context '#is_annotation?' do
    it 'returns a boolean' do
      expect(g1.is_annotation?).to be_truthy
      expect(g2.is_annotation?).to be_truthy
      expect(g3.is_annotation?).to be_truthy
    end
  end

end
