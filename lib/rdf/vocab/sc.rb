# -*- encoding: utf-8 -*-
# This file generated manually from
# http://iiif.io/model/shared-canvas/1.0/index.html; it's likely incomplete!
require 'rdf'
module RDF
  class SC < RDF::StrictVocabulary("http://www.shared-canvas.org/ns/")

    # 2. Canvas Model
    # http://iiif.io/model/shared-canvas/1.0/index.html#CanvasIntro

    # 2.1 Canvas
    # http://iiif.io/model/shared-canvas/1.0/index.html#Canvas

    term :Canvas,
      label: 'Canvas'.freeze,
      comment: %(The Class for a Canvas, which is the digital surrogate for a physical page within the model.).freeze,
      'rdfs:isDefinedBy' => 'http://www.shared-canvas.org/ns/'.freeze,
      type: 'owl:Class'.freeze

    property :hasAnnotations,
      label: 'hasAnnotations'.freeze,
      comment: %(The relationship between a Canvas and a list of Annotations that target it or part of it. Each Canvas MAY have one or more lists of related annotations.).freeze,
      domain: 'http://www.shared-canvas.org/ns/Canvas'.freeze,
      range:  'http://www.shared-canvas.org/ns/AnnotationList'.freeze,
      'rdfs:isDefinedBy' => 'http://www.shared-canvas.org/ns/'.freeze,
      type: 'owl:ObjectProperty'.freeze

    # 2.2 Zone
    # http://iiif.io/model/shared-canvas/1.0/index.html#Zone

    term :Zone,
      label: 'Zone'.freeze,
      comment: %(Zones represent part of one or more Canvases).freeze,
      'rdfs:isDefinedBy' => 'http://www.shared-canvas.org/ns/'.freeze,
      type: 'owl:Class'.freeze

    property :naturalAngle,
      label: 'naturalAngle'.freeze,
      comment: %(The relationship between a Canvas and a list of Annotations that target it or part of it. Each Canvas MAY have one or more lists of related annotations.).freeze,
      domain: 'http://www.shared-canvas.org/ns/Zone'.freeze,
      range: 'rdfs:Literal'.freeze,
      'rdfs:isDefinedBy' => 'http://www.shared-canvas.org/ns/'.freeze,
      type: 'owl:DatatypeProperty'.freeze


    # 3. Annotations
    # http://iiif.io/model/shared-canvas/1.0/index.html#Annotation
    # Modeled by Open Annotations <http://www.w3.org/ns/oa#>

    # 3.1 Painting Motivation
    # http://iiif.io/model/shared-canvas/1.0/index.html#BasicAnnotation

    term :painting,
      label: 'painting'.freeze,
      comment: %(The motivation that represents the distinction between resources that should be painted onto the Canvas, rather than resources that are about the Canvas. If the target of the Annotation is not a Canvas or Zone, then the meaning is left to other communities to define.).freeze,
      'rdfs:isDefinedBy' => 'http://www.shared-canvas.org/ns/'.freeze,
      type: 'http://www.w3.org/ns/oa#Motivation'.freeze


    # 4. Ordering Model
    # http://iiif.io/model/shared-canvas/1.0/index.html#OrderingIntro
    # The Shared Canvas model starts from the Object Reuse and Exchange
    # specification, which provides a method for ordering based on Proxy nodes,
    # however we introduce a simpler method for the most common case of a
    # single, linear order.

    # 4.1. Ordered Aggregations
    # http://iiif.io/model/shared-canvas/1.0/index.html#OrderedAggregation
    # Nothing to model here; see ore:Aggregation and rdf:List.

    # 4.2. Sequences
    # http://iiif.io/model/shared-canvas/1.0/index.html#Sequence

    term :Sequence,
      label: 'Sequence'.freeze,
      comment: %(An ordered aggregation of Canvases for the purpose of rendering them in that order.).freeze,
      'rdfs:isDefinedBy' => 'http://www.shared-canvas.org/ns/'.freeze,
      subClassOf: 'http://www.openarchives.org/ore/terms/Aggregation'.freeze,
      type: 'owl:Class'.freeze

    property :hasContentRange,
      label: 'hasContentRange'.freeze,
      comment: %(A pointer to an sc:Range which contains the content bearing pages of the sequence. If sc:hasContentRange is not supplied, then it defaults to the entire Sequence.).freeze,
      domain: 'http://www.shared-canvas.org/ns/Sequence'.freeze,
      range:  'http://www.shared-canvas.org/ns/Range'.freeze,
      'rdfs:isDefinedBy' => 'http://www.shared-canvas.org/ns/'.freeze,
      type: "owl:ObjectProperty".freeze

    property :readingDirection,
      label: 'readingDirection'.freeze,
      comment: %("Left-to-Right" or "Right-to-Left" for the reading direction of this sequence for animating page viewers.).freeze,
      domain: 'http://www.shared-canvas.org/ns/Sequence'.freeze,
      range: 'rdfs:Literal'.freeze,
      'rdfs:isDefinedBy' => 'http://www.shared-canvas.org/ns/'.freeze,
      type: 'owl:DatatypeProperty'.freeze

    # 4.3. Ranges
    # http://iiif.io/model/shared-canvas/1.0/index.html#Range

    term :Range,
      label: 'Range'.freeze,
      comment: %(An ordered aggregation of Canvases for the purpose of rendering them in that order.).freeze,
      'rdfs:isDefinedBy' => 'http://www.shared-canvas.org/ns/'.freeze,
      subClassOf: 'http://www.openarchives.org/ore/terms/Aggregation'.freeze,
      type: 'owl:Class'.freeze


    # 5. Discovery Model
    # http://iiif.io/model/shared-canvas/1.0/index.html#DiscoveryIntro

    # 5.1. Annotation Lists

    term :AnnotationList,
      label: 'AnnotationList'.freeze,
      comment: %(An ordered aggregation of Annotations.).freeze,
      'rdfs:isDefinedBy' => 'http://www.shared-canvas.org/ns/'.freeze,
      type: 'owl:Class'.freeze

    property :forCanvas,
      label: 'forCanvas'.freeze,
      comment: %(The relationship between the AnnotationList and any Canvas that are the targets of the included Annotations.  Typically this relationship is used to describe the AnnotationList in a Manifest to allow clients to determine which lists should be retrieved.).freeze,
      domain: ['http://www.shared-canvas.org/ns/AnnotationList'.freeze, 'http://www.shared-canvas.org/ns/Layer'.freeze, 'http://www.shared-canvas.org/ns/Manifest'.freeze],
      range: 'http://www.shared-canvas.org/ns/Canvas'.freeze,
      'rdfs:isDefinedBy' => 'http://www.shared-canvas.org/ns/'.freeze,
      type: 'owl:ObjectProperty'.freeze

    property :forMotivation,
      label: 'forMotivation'.freeze,
      comment: %(A shortcut relationship that implies that all of the Annotations in the list have that particular Motivation. ).freeze,
      domain: ['http://www.shared-canvas.org/ns/AnnotationList'.freeze, 'http://www.shared-canvas.org/ns/Layer'.freeze],
      range: 'http://www.w3.org/ns/oa#Motivation'.freeze,
      'rdfs:isDefinedBy' => 'http://www.shared-canvas.org/ns/'.freeze,
      type: 'owl:ObjectProperty'.freeze


    # 5.2. Layers
    # http://iiif.io/model/shared-canvas/1.0/index.html#Layer

    term :Layer,
      label: 'Layer'.freeze,
      comment: %(An ordered aggregation of Annotations or Annotation Lists.).freeze,
      'rdfs:isDefinedBy' => 'http://www.shared-canvas.org/ns/'.freeze,
      type: 'owl:Class'.freeze

    # All of the properties of AnnotationList are also useful for Layer:
    # See sc:forCanvas and sc:forMotivation above.

    # 5.3. Manifests
    # http://iiif.io/model/shared-canvas/1.0/index.html#Manifest

    term :Manifest,
      label: 'Manifest'.freeze,
      comment: %(The Manifest is what ties everything together. It is an Aggregation of the Layers, AnnotationLists and Sequences that make up the description of the facsimile. As such the Manifest is representative of the Book, Newspaper, Scroll or whatever physical object is being represented in the facsimile. A Manifest MUST have an rdf:label giving a human readable name for it. This label is to be used for rendering purposes to inform the user what they are looking at.).freeze,
      'rdfs:isDefinedBy' => 'http://www.shared-canvas.org/ns/'.freeze,
      type: 'owl:Class'.freeze

    # sc:Manifest shares the sc:forCanvas property with sc:AnnotationList and sc:Layer.

    # 5.4. Collections
    # http://iiif.io/model/shared-canvas/1.0/index.html#Collection
    # Shared Canvas does not address collections of Manifests (or of other
    # Collections) directly. Ordered or regular ore:Aggregations are recommended
    # as the basis of describing collections in a manner that would be compliant
    # with the Shared Canvas guidelines.


    # 5.5. Services and Bibliographic Information
    # http://iiif.io/model/shared-canvas/1.0/index.html#Collection-Info

    property :hasRelatedService,
      label: 'hasRelatedService'.freeze,
      comment: %(The relationship between a resource in the Shared Canvas model and the endpoint for a related service.).freeze,
      domain: 'owl:Thing'.freeze, # ?
      range:  'owl:Thing'.freeze, # ?
      'rdfs:isDefinedBy' => 'http://www.shared-canvas.org/ns/'.freeze,
      type: 'owl:ObjectProperty'.freeze

    property :hasRelatedDescription,
      label: 'hasRelatedDescription'.freeze,
      comment: %(The relationship between a resource in the Shared Canvas model and a related description of the real world object.).freeze,
      domain: 'owl:Thing'.freeze, # ?
      range:  'owl:Thing'.freeze, # ?
      'rdfs:isDefinedBy' => 'http://www.shared-canvas.org/ns/'.freeze,
      type: 'owl:ObjectProperty'.freeze

    property :agentLabel,
      label: 'agentLabel'.freeze,
      comment: %(A name and possibly role of a person or organization associated with the physical object which is being represented by the Shared Canvas object. For example: "Froissart (author)").freeze,
      domain: 'owl:Thing'.freeze, # ?
      range:  'rdfs:Literal'.freeze,
      'rdfs:isDefinedBy' => 'http://www.shared-canvas.org/ns/'.freeze,
      type: 'owl:DatatypeProperty'.freeze

    property :dateLabel,
      label: 'dateLabel'.freeze,
      comment: %(A date or date range and possiby role associated with the physical object. For example: "Illustrated c. 1200").freeze,
      domain: 'owl:Thing'.freeze, # ?
      range:  'rdfs:Literal'.freeze,
      'rdfs:isDefinedBy' => 'http://www.shared-canvas.org/ns/'.freeze,
      type: 'owl:DatatypeProperty'.freeze

    property :locationLabel,
      label: 'locationLabel'.freeze,
      comment: %(A location and possibly role associated with the physical object. For example: "Paris, France (created)").freeze,
      domain: 'owl:Thing'.freeze, # ?
      range:  'rdfs:Literal'.freeze,
      'rdfs:isDefinedBy' => 'http://www.shared-canvas.org/ns/'.freeze,
      type: 'owl:DatatypeProperty'.freeze

    property :attributionLabel,
      label: 'attributionLabel'.freeze,
      comment: %(An attribution that must be displayed along with the resource. For example: "Held at A Library (NY)").freeze,
      domain: 'owl:Thing'.freeze, # ?
      range:  'rdfs:Literal'.freeze,
      'rdfs:isDefinedBy' => 'http://www.shared-canvas.org/ns/'.freeze,
      type: 'owl:DatatypeProperty'.freeze

    property :rightsLabel,
      label: 'rightsLabel'.freeze,
      comment: %(A rights or license statement, describing how the facsimile may be reused.).freeze,
      domain: 'owl:Thing'.freeze, # ?
      range:  'rdfs:Literal'.freeze,
      'rdfs:isDefinedBy' => 'http://www.shared-canvas.org/ns/'.freeze,
      type: 'owl:DatatypeProperty'.freeze

  end
end
