require File.join File.dirname(__FILE__), 'tweakruby'
require_relative 'feature'

Awestruct::Extensions::Pipeline.new do
  extension Awestruct::Extensions::DataDir.new

  # extension Awestruct::Extensions::Posts.new( '/news' ) 
  
  # The Indexifier simply scans all pages in the site for HTML pages ending not with index.html. 
  # When it finds matching pages, it replaces it's output path with one that uses a directory of the same name, 
  # and an index.html page.
  extension Awestruct::Extensions::Indexifier.new
  
  # Needs to be after Indexifier to get the linking correct; second argument caps changelog per guide
  extension Awestruct::Extensions::Feature::Index.new('/features', 15)

  
  helper Awestruct::Extensions::Partial
  
end

