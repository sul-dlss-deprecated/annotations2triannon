require 'rdf'
require 'rdf-vocab'

# Module designed to be a mixin for manifest and annotation list.
# The methods assume that the class including this module contains
# an #rdf method to access and RDF::Graph object.
module OpenAnnotationHarvest

  # Searches rdf graph to find RDF::Vocab::OA.Annotation
  # @return [Array<RDF::Graph>] for graphs of type RDF::Vocab::OA.Annotation
  def collect_open_annotations
    oa_graphs = []
    q = [nil, RDF.type, RDF::Vocab::OA.Annotation]
    # 'rdf' must be a method to access an RDF::Graph object
    rdf.query(q).each_subject do |s|
      oa_graphs << rdf_subject_graph(s)
    end
    oa_graphs
  end

  # @param subject [RDF::Resource] An RDF::Resource
  # @return [RDF::Graph] graph for 'subject' as the ?s in ?s ?p ?o
  def rdf_subject_graph(subject)
    g = RDF::Graph.new
    # 'rdf' must be a method to access an RDF::Graph object
    rdf.query([subject, nil, nil]) do |s,p,o|
      g << [s,p,o]
      g << rdf_subject_graph(o) if o.node?
      g << rdf_subject_graph(o) if o.uri?
    end
    g
  end

end

