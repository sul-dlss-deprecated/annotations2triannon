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

# Additional PURL manifest
# http://purl.stanford.edu/jr903ng8662/iiif/manifest.json

# Mirador viewer
# http://sul-reader-test.stanford.edu/m2/#6c45932d-2276-4699-9203-a9133181c2a1



IIIF_COLLECTION='http://dms-data.stanford.edu/data/manifests/collections/collection.json'
puts "\nCollection:\n#{IIIF_COLLECTION}"

iiif_navigator = Annotations2triannon::IIIFNavigator.new(IIIF_COLLECTION);

puts "\nManifests:"
manifests = iiif_navigator.manifests;
manifests.each {|m| puts m.iri.to_s}
# http://dms-data.stanford.edu/data/manifests/BnF/jr903ng8662/manifest.json
# http://dms-data.stanford.edu/data/manifests/Stanford/kq131cs7229/manifest.json

puts "\nAnnotation List counts:"
annotation_lists = iiif_navigator.annotation_lists;
annotation_lists.each_pair {|manifest,alist| puts "#{manifest} => #{alist.length}"}
# http://dms-data.stanford.edu/data/manifests/BnF/jr903ng8662/manifest.json => 72
# http://dms-data.stanford.edu/data/manifests/Stanford/kq131cs7229/manifest.json => 0

puts "\nOpen Annotation counts:"
open_annotations = iiif_navigator.open_annotations;
open_annotations.each_pair do |manifest,alists|
  puts "\n#{manifest}"
  alists.each_pair do |alist, oa_arr|
    puts "\t#{alist}\t=> #{oa_arr.length}"
  end
end

manifest_key = open_annotations.keys.sample(1).first
anno_list_key = open_annotations[manifest_key].keys.sample(1).first
anno_list = open_annotations[manifest_key][anno_list_key]

open_annos = anno_list.collect {|oa| Annotations2triannon::OpenAnnotation.new(oa) }
open_anno = open_annos.sample(1).first
puts open_anno.to_ttl

open_anno.is_annotation?
open_anno.open_annotation?


binding.pry

# to clarify the scope -- only annotations where the body is text, and not where the body is an image.

# # There is one sc_manifest, which has open annotations and annotation lists
# oa_graphs = sc_manifest.open_annotations
# oa_graph = oa_graphs.sample(1).first rescue nil
# # these might be all: openannotation:motivatedBy <http://www.shared-canvas.org/ns/painting>
# puts oa_graph.to_ttl

# oa_lists = sc_manifest.annotation_lists
# oa_list = oa_lists.sample(1).first
# oa_graphs = oa_list.open_annotations
# oa_graph = oa_graphs.sample(1).first
# puts oa_graph.to_ttl

# binding.pry





# # Explore the collection to resolve IIIF and Shared Canvas (SC) manifests.
# iiif_manifests = []
# sc_manifests = []

# # Examine IIIF manifests in the collection
# iiif_manifests.push(* iiif_navigator.iiif_manifests)
# # A IIIF collection might contain a IIIF manifest that itself
# # could be typed as an SC manifest.
# tmp = iiif_manifests.select {|m| m if m.sc_manifest? }
# tmp.each do |m|
#   sc_manifests << Annotations2triannon::SharedCanvasManifest.new(m.iri.to_s)
# end
# iiif_manifests = iiif_manifests.select {|m| m if m.iiif_manifest? }

# # Examine SC manifests in the collection
# sc_manifests.push(* iiif_navigator.sc_manifests)
# # A IIIF collection might contain an SC manifest that itself
# # could be typed as a IIIF manifest.
# iiif_manifests.push(* sc_manifests.select {|m| m if m.iiif_manifest? } )
# tmp = sc_manifests.select {|m| m if m.iiif_manifest? }
# tmp.each do |m|
#   iiif_manifests << Annotations2triannon::IIIFManifest.new(m.iri.to_s)
# end
# sc_manifests = sc_manifests.select {|m| m if m.sc_manifest? }

# # The collection should be now resolved into IIIF and SC manifests.

# # Looking at examples of IIIF and SC manifests:
# sc_manifest = sc_manifests.sample(1).first rescue nil
# # iiif_manifest = iiif_manifests.sample(1).first rescue nil
# # There are no IIIF manifests in this data?

