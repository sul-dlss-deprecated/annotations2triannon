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


  describe 'has constants:' do
    it 'CONTENT vocabulary for http://www.w3.org/2011/content#' do
      const = Annotations2triannon::OpenAnnotation::CONTENT
      expect(const).to eql RDF::Vocab::CNT
    end
    it 'OA vocabulary for http://www.w3.org/ns/oa#' do
      const = Annotations2triannon::OpenAnnotation::OA
      expect(const).to eql RDF::Vocab::OA
    end
    it 'IIIF_CONTEXT for http://iiif.io/api/presentation/2/context.json' do
      const = Annotations2triannon::OpenAnnotation::IIIF_CONTEXT
      expect(const).to be_instance_of String
      expect(const).to include('http://iiif.io/api/presentation/2/context.json')
    end
    it 'OA_CONTEXT for http://www.w3.org/ns/oa.jsonld' do
      const = Annotations2triannon::OpenAnnotation::OA_CONTEXT
      expect(const).to be_instance_of String
      expect(const).to include('http://www.w3.org/ns/oa.jsonld')
    end
  end

  context '#id' do
    it 'returns an RDF::URI' do
      expect(g1.id).to be_a RDF::URI
      expect(g2.id).to be_a RDF::URI
      expect(g3.id).to be_a RDF::URI
    end
  end

  context '#new' do
    let(:g) { RDF::Graph.new }
    context 'for default init' do
      it 'sets the #id as an RDF::URI of a UUID' do
        oa = Annotations2triannon::OpenAnnotation.new
        expect(oa.id).to be_a RDF::URI
        expect(UUID.validate(oa.id)).to be true
      end
      it 'sets the #graph as an RDF::Graph' do
        oa = Annotations2triannon::OpenAnnotation.new
        expect(oa.graph).to be_a RDF::Graph
      end
      it 'the #graph is an open annotation' do
        oa = Annotations2triannon::OpenAnnotation.new
        expect(oa.is_annotation?).to be true
      end
    end
    context 'for init with an RDF::Graph' do
      it 'accepts an empty RDF::Graph' do
        oa = Annotations2triannon::OpenAnnotation.new(g)
        expect(oa.graph).to be_a RDF::Graph
      end
      it 'ensures an empty RDF::Graph is an open annotation' do
        oa = Annotations2triannon::OpenAnnotation.new(g)
        expect(oa.is_annotation?).to be true
      end
      it 'ensures a graph with an RDF.type is also an open annotation' do
        id = RDF::URI.parse(UUID.generate)
        g << [id, RDF.type, RDF::Vocab::SKOS.Concept]
        oa = Annotations2triannon::OpenAnnotation.new(g)
        expect(oa.is_annotation?).to be true
      end
    end
    context 'for init with an ID' do
      it 'accepts a nil ID and sets the #id as an RDF::URI of a UUID' do
        oa = Annotations2triannon::OpenAnnotation.new(g, nil)
        expect(oa.id).to be_a RDF::URI
        expect(UUID.validate(oa.id)).to be true
      end
      it 'accepts a String ID and parses it as an RDF::URI' do
        id = 'abc'
        oa = Annotations2triannon::OpenAnnotation.new(g, id)
        expect(oa.id).to be_a RDF::URI
        expect(oa.id).to eql RDF::URI.parse(id)
      end
      it 'accepts an RDF::URI and parses it as an RDF::URI' do
        id = RDF::URI.parse('abc')
        oa = Annotations2triannon::OpenAnnotation.new(g, id)
        expect(oa.id).to be_a RDF::URI
        expect(oa.id).to eql id
      end
      it 'accepts a UUID and parses it as an RDF::URI' do
        id = UUID.generate
        oa = Annotations2triannon::OpenAnnotation.new(g, id)
        expect(oa.id).to be_a RDF::URI
        expect(oa.id).to eql RDF::URI.parse(id)
      end
      it 'does NOT accept an empty String ID' do
        expect{Annotations2triannon::OpenAnnotation.new(g, '')}.to raise_error
      end
    end
  end

  context '#graph' do
    it 'returns an RDF::Graph' do
      expect(g1.graph).to be_a RDF::Graph
      expect(g2.graph).to be_a RDF::Graph
      expect(g3.graph).to be_a RDF::Graph
    end
  end

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
    uri = 'http://www.w3.org/ns/oa#commenting'
    def expect_motivatedBy(uri)
      expect(g1.motivatedBy uri).not_to be_empty
      expect(g2.motivatedBy uri).to be_empty  # note g1 and g2 differ here
      expect(g3.motivatedBy uri).to be_empty
    end
    it 'returns an array' do
      expect(g1.motivatedBy).to be_a Array
      expect(g1.motivatedBy).not_to be_empty
      expect(g3.motivatedBy).to be_a Array
      expect(g3.motivatedBy).to be_empty
    end
    it 'accepts a string URI' do
      expect_motivatedBy uri
    end
    it 'accepts an Addressable::URI' do
      expect_motivatedBy Addressable::URI.parse(uri)
    end
    it 'accepts an RDF::URI' do
      expect_motivatedBy RDF::URI.parse(uri)
    end
  end

  context '#motivatedBy?' do
    uri = 'http://www.w3.org/ns/oa#commenting'
    def expect_motivatedBy?(uri)
      expect(g1.motivatedBy? uri).to be_truthy
      expect(g2.motivatedBy? uri).to be_falsy  # note g1 and g2 differ here
      expect(g3.motivatedBy? uri).to be_falsy
    end
    it 'returns a boolean' do
      expect(g1.motivatedBy?).to be_truthy
      expect(g2.motivatedBy?).to be_truthy  # note g1 and g2 are truthy here
      expect(g3.motivatedBy?).to be_falsy
    end
    it 'accepts a string URI' do
      expect_motivatedBy? uri
    end
    it 'accepts an Addressable::URI' do
      expect_motivatedBy? Addressable::URI.parse(uri)
    end
    it 'accepts an RDF::URI' do
      expect_motivatedBy? RDF::URI.parse(uri)
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
