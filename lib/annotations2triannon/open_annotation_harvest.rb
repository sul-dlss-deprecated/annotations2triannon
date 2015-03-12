require 'rdf'
require 'rdf-vocab'

# Module designed to be a mixin for manifest and annotation list.
module OpenAnnotationHarvest

  # @param rdf [RDF::Graph] a graph to search for RDF::Vocab::OA.Annotation
  # @return [Array<RDF::Graph>] for graphs of type RDF::Vocab::OA.Annotation
  def collect_open_annotations(rdf)
    oa_graphs = []
    q = [nil, RDF.type, RDF::Vocab::OA.Annotation]
    rdf.query(q).each_subject do |subject|
      g = RDF::Graph.new
      rdf.query([subject, nil, nil]) do |s,p,o|
        g << [s,p,o]
        g << rdf_expand_blank_nodes(o) if o.node?
      end
      oa_graphs << g
    end
    oa_graphs
  end

  # @param object [RDF::Node] An RDF blank node
  # @return [RDF::Graph] graph of recursive resolution for a blank node
  def rdf_expand_blank_nodes(object)
    g = RDF::Graph.new
    if object.node?
      rdf.query([object, nil, nil]) do |s,p,o|
        g << [s,p,o]
        g << rdf_expand_blank_nodes(o) if o.node?
      end
    end
    g
  end

end

