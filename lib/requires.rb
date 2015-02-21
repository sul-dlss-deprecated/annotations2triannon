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
require 'rdf/open_annotation'

require_relative 'annotations2triannon/configuration'
require_relative 'annotations2triannon/resource'
require_relative 'annotations2triannon/iiif_collection'
require_relative 'annotations2triannon/iiif_manifest'
require_relative 'annotations2triannon/shared_canvas_manifest'
require_relative 'annotations2triannon/shared_canvas_annotations'
require_relative 'annotations2triannon/open_annotation'
require_relative 'annotations2triannon/triannon_client'

require_relative 'annotations2triannon/dms_collection'
require_relative 'annotations2triannon/revs'

