#!/usr/bin/env ruby
require 'annotations2triannon'
CONFIG = Annotations2triannon.configuration


# https://jirasul.stanford.edu/jira/browse/DT-5
# Annotation lists:
# 1) http://dms-data.stanford.edu/data/manifests/BnF/jr903ng8662/list/
# 2) http://dms-data.stanford.edu/data/manifests/Stanford/kq131cs7229/list/
# 3) http://dms-data.stanford.edu/data/data/yale/yale_cs_annotations_for_stanford.json

# Stanford manifests associated with 1) and 2)
# 1) http://dms-data.stanford.edu/data/manifests/BnF/jr903ng8662/manifest.json
# 2) http://dms-data.stanford.edu/data/manifests/Stanford/kq131cs7229/manifest.json


IIIF_COLLECTION='http://dms-data.stanford.edu/data/manifests/collections/collection.json'

iiif_navigator = Annotations2triannon::IIIFNavigator.new(IIIF_COLLECTION);

# Explore the collection to resolve IIIF and Shared Canvas (SC) manifests.
iiif_manifests = []
sc_manifests = []

# Examine IIIF manifests in the collection
iiif_manifests.push(* iiif_navigator.iiif_manifests)
# A IIIF collection might contain a IIIF manifest that itself
# could be typed as an SC manifest.
tmp = iiif_manifests.select {|m| m if m.sc_manifest? }
tmp.each do |m|
  sc_manifests << Annotations2triannon::SharedCanvasManifest.new(m.iri.to_s)
end
iiif_manifests = iiif_manifests.select {|m| m if m.iiif_manifest? }

# Examine SC manifests in the collection
sc_manifests.push(* iiif_navigator.sc_manifests)
# A IIIF collection might contain an SC manifest that itself
# could be typed as a IIIF manifest.
iiif_manifests.push(* sc_manifests.select {|m| m if m.iiif_manifest? } )
tmp = sc_manifests.select {|m| m if m.iiif_manifest? }
tmp.each do |m|
  iiif_manifests << Annotations2triannon::IIIFManifest.new(m.iri.to_s)
end
sc_manifests = sc_manifests.select {|m| m if m.sc_manifest? }

# The collection should be now resolved into IIIF and SC manifests.

# Looking at examples of IIIF and SC manifests:
sc_manifest = sc_manifests.sample(1).first rescue nil
iiif_manifest = iiif_manifests.sample(1).first rescue nil


binding.pry



# to clarify the scope -- only annotations where the body is text, and not where the body is an image.



# There is one sc_manifest, which has open annotations and annotation lists
oa_graphs = sc_manifest.open_annotations
oa_graph = oa_graphs.sample(1).first rescue nil
# these might be all: openannotation:motivatedBy <http://www.shared-canvas.org/ns/painting>
puts oa_graph.to_ttl

oa_lists = sc_manifest.annotation_lists
oa_list = oa_lists.sample(1).first
oa_graphs = oa_list.open_annotations
oa_graph = oa_graphs.sample(1).first
puts oa_graph.to_ttl

binding.pry

