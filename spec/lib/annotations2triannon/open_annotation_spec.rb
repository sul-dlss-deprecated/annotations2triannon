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
      <http://www.w3.org/ns/oa#motivatedBy> <http://www.w3.org/ns/oa#commenting> . ")
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
        "@id": "http://my.identifiers.com/oa_bookmark",
        "@type": "oa:Annotation",
        "hasTarget": "http://purl.stanford.edu/kq131cs7229"
      }' )
  }

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

end
