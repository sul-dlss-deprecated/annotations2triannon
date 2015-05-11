#!/usr/bin/env ruby
require 'annotations2triannon'
CONFIG = Annotations2triannon.configuration


# TODO: add CLI interface for arguments to modify:
# - reporting annotation counts (default=true)
# - posting annotations to triannon (default=true)

# TODO: Abstract this DMS script into a generic CLI that takes an
# additional set of arguments to process any of the following:
# - IIIF collection URI
# - IIIF manifest URI
# - IIIF annotation list URI



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


def dump_json(filename, data)
  File.open(filename,'w') do |f|
    f.write(JSON.pretty_generate(data))
  end
end

def report_anno_counts(annos, anno_count_file)
  anno_count_data = {}
  annos.each_pair do |m,alists|
    puts "\n#{m}"
    anno_count_data[m] = {}
    alists.each_pair do |alist, oa_arr|
      puts "\t#{alist}\t=> #{oa_arr.length}"
      anno_count_data[m][alist] = oa_arr.length
    end
  end
  # persist the anno counts
  dump_json(anno_count_file, anno_count_data)
  puts "\nAnnotation counts saved to: #{anno_count_file}"
end


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
anno_count_file = File.join(CONFIG.log_path, 'dms_annotation_counts.json')
open_annotations = iiif_navigator.open_annotations;
report_anno_counts(open_annotations, anno_count_file)


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
puts "\nOpen Annotations with ContextAsText body:"
anno_count_file = File.join(CONFIG.log_path, 'dms_annotation_text_counts.json')
report_anno_counts(text_annotations, anno_count_file)


# text_anno_list = text_annotations.values.first.values.first
# oa = text_anno_list.sample(1).first
# puts oa.body_contentChars
# puts oa.to_jsonld_iiif
# puts oa.to_jsonld_oa
# binding.pry


# -----------------------------------------------------------------------
# POST annotations to triannon and track the triannon URIs

tc = TriannonClient::TriannonClient.new

# cleanup any prior annotations in triannon
puts "\nText Annotation cleanup:"
anno_tracking_file = File.join(CONFIG.log_path, 'dms_annotation_tracking.json')
if File.exists? anno_tracking_file
  if File.size(anno_tracking_file).to_i > 0
    anno_tracking = JSON.parse( File.read(anno_tracking_file) )
    anno_tracking.each_pair do |manifest_uri,anno_lists|
      puts "\n#{manifest_uri}"
      anno_lists.each_pair do |anno_list_uri, anno_list|
        puts "Removing:\t#{anno_list_uri}\t=> #{anno_list.length}"
        anno_list.each do |anno_data|
          success = tc.delete_annotation(anno_data['uri'])
          CONFIG.logger.error("FAILURE to delete #{anno_data['uri']}") unless success
        end
      end
    end
  else
    puts "Nothing to delete."
  end
else
  puts "Nothing to delete."
end


puts "\nText Annotation posts:"
anno_tracking = {}
text_annotations.each_pair do |m,anno_lists|
  puts "\n#{m}"
  anno_tracking[m] = {}
  anno_lists.each_pair do |anno_list_uri, anno_list|
    puts "Posting:\t#{anno_list_uri}\t=> #{anno_list.length}"
    anno_tracking[m][anno_list_uri] = []
    anno_list.each do |oa|
      response = tc.post_annotation(oa.to_jsonld_oa)
      # parse the response into an RDF::Graph
      graph = tc.response2graph(response)
      # query the graph to extract the annotation URI
      uri = tc.annotation_uri(graph)
      if uri
        anno_data = {
          uri: uri,
          chars: oa.body_contentChars.first
        }
        anno_tracking[m][anno_list_uri].push(anno_data)
      end
    end
  end
end

# persist the anno_tracking data
File.open(anno_tracking_file,'w') do |f|
  f.write(JSON.pretty_generate(anno_tracking))
end
puts "Annotation records saved to: #{anno_tracking_file}"


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

