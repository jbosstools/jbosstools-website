# JBoss.org extensions
require 'wget_wrapper'
require 'js_minifier'
require 'css_minifier'
require 'html_minifier'
require 'file_merger'
require 'less_config'

# JBoss Tools custom 
require 'font_path'
require 'textile_plus'
require 'mytagger'
require 'mypaginator'
require 'feature'
require 'whatsnew'
require 'downloads'


Awestruct::Extensions::Pipeline.new do
  
  helper Awestruct::Extensions::Partial
  
  # JBoss.org extensions
  extension Awestruct::Extensions::WgetWrapper.new
  transformer Awestruct::Extensions::JsMinifier.new
  transformer Awestruct::Extensions::CssMinifier.new
  transformer Awestruct::Extensions::HtmlMinifier.new
  extension Awestruct::Extensions::FileMerger.new
  extension Awestruct::Extensions::LessConfig.new
  
  # JBoss Tools custom 
  extension Awestruct::Extensions::DataDir.new
  extension Awestruct::Extensions::DataDir.new('/whatsnew')
  extension Awestruct::Extensions::DataDir.new('/features')
  extension Awestruct::Extensions::Posts.new( '/blog', :posts )
  extension Awestruct::Extensions::MyPaginator.new(:posts, '/blog/index', :per_page => 2 )
  extension Awestruct::Extensions::MyTagger.new( :posts, '/blog/index', '/blog/tags', :per_page=>10,
   :sanitize=>true )
  extension Awestruct::Extensions::Downloads.new('/downloads/index.html', '/downloads/download', '/downloads/download')
   
  
  # extension Awestruct::Extensions::Indexifier.new
  # Needs to be after Indexifier to get the linking correct; 
  extension Awestruct::Extensions::Feature::Index.new('/features', 15)
  # Needs to be after Indexifier to get the linking correct; 
  extension Awestruct::Extensions::Whatsnew::Index.new('/whatsnew')
  
  extension Awestruct::Extensions::Disqus.new()
  
end

