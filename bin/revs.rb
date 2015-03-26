#!/usr/bin/env ruby

ENV['REVS_ENABLED'] = 'true'

require 'annotations2triannon'
CONFIG = Annotations2triannon.configuration

revs = Annotations2triannon::Revs.new

tc = TriannonClient::TriannonClient.new
puts "\nRevs open annotation posts:"
revs.open_annotations.each do |oa|
  binding.pry
  tc.post_annotation(oa.to_jsonld_oa)
end


