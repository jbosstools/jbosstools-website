
Awestruct::Extensions::Pipeline.new do
  extension Awestruct::Extensions::DataDir.new
  
  # extension Awestruct::Extensions::Posts.new( '/news' ) 
  # The Indexifier simply scans all pages in the site for HTML pages ending not with index.html. 
  # When it finds matching pages, it replaces it's output path with one that uses a directory of the same name, 
  # and an index.html page.
  #extension Awestruct::Extensions::Indexifier.new
  
  helper Awestruct::Extensions::Partial
  
end

