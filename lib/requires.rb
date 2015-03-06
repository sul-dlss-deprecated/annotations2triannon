require 'dotenv'
Dotenv.load

require 'pry'
require 'pry-doc'
require 'ruby-progressbar'

require 'addressable/uri'
require 'json'
require 'rest-client'
require 'uuid'

require 'linkeddata'
require 'rdf/iiif'
require_relative 'rdf/vocab/oa.rb'
require_relative 'rdf/vocab/sc.rb'

require_relative 'open_annotation_harvest'

require_relative 'annotations2triannon/configuration'
require_relative 'annotations2triannon/resource'
require_relative 'annotations2triannon/manifest'
require_relative 'annotations2triannon/annotation_list'
require_relative 'annotations2triannon/iiif_collection'
require_relative 'annotations2triannon/iiif_manifest'
require_relative 'annotations2triannon/iiif_annotation_list'
require_relative 'annotations2triannon/shared_canvas_manifest'
require_relative 'annotations2triannon/shared_canvas_annotation_list'
require_relative 'annotations2triannon/open_annotation'
require_relative 'annotations2triannon/triannon_client'

require_relative 'annotations2triannon/iiif_navigator'
require_relative 'annotations2triannon/revs'

