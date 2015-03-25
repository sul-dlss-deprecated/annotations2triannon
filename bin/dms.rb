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
manifests.each {|m| puts m.iri}

puts "\nAnnotation List counts:"
annotation_lists = iiif_navigator.annotation_lists;
annotation_lists.each_pair {|m,alist| puts "#{m} => #{alist.length}"}

puts "\nOpen Annotation counts:"
open_annotations = iiif_navigator.open_annotations;
open_annotations.each_pair do |m,alists|
  puts "\n#{m}"
  alists.each_pair do |alist, oa_arr|
    puts "\t#{alist}\t=> #{oa_arr.length}"
  end
end

# Find all annotations where the body is text
text_annotations = {}
manifest_keys = open_annotations.keys
manifest_keys.each do |mk|
  text_annotations[mk] = {}
  anno_list_keys = open_annotations[mk].keys
  anno_list_keys.each do |ak|
    anno_list = open_annotations[mk][ak]
    anno_text_list = anno_list.select {|oa| oa if oa.body_contentAsText? }
    text_annotations[mk][ak] = anno_text_list
  end
end

# text_anno_list = text_annotations.values.first.values.first
# oa = text_anno_list.sample(1).first
# puts oa.body_contentChars
# puts oa.to_jsonld_iiif
# puts oa.to_jsonld_oa
# binding.pry


tc = TriannonClient::TriannonClient.new
puts "\nText Annotation posts:"
text_annotations.each_pair do |m,alists|
  puts "\n#{m}"
  alists.each_pair do |alist, oa_arr|
    puts "Posting:\t#{alist}\t=> #{oa_arr.length}"
    oa_arr.each {|oa| tc.post_annotation(oa) }
  end
end



# For conversion of IIIF to OA context, see
# https://github.com/sul-dlss/triannon/blob/master/lib/triannon/graph.rb#L36-50
# https://jirasul.stanford.edu/jira/browse/DT-6


# These notes below are left here to document code that filters manifests and
# based on the RDF type of the manifest (vs. the RDF type for the manifest in
# the parent collection, which can differ from the manifest itself).

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

