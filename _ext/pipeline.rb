require 'wget_wrapper'
require 'js_minifier'
require 'css_minifier'
require 'html_minifier'
require 'font_path'
require 'textile_plus'
require 'mytagger'
require 'mypaginator'
require File.join File.dirname(__FILE__), 'tweakruby'
require_relative 'feature'
require_relative 'whatsnew'

Awestruct::Extensions::Pipeline.new do
  
  # JBoss.org extensions
  helper Awestruct::Extensions::Partial
  extension Awestruct::Extensions::WgetWrapper.new
  transformer Awestruct::Extensions::JsMinifier.new
  transformer Awestruct::Extensions::CssMinifier.new
  transformer Awestruct::Extensions::HtmlMinifier.new
  #extension Awestruct::Extensions::FileMerger.new
  extension Awestruct::Extensions::FontPath.new
  
  # JBoss Tools custom 
  extension Awestruct::Extensions::DataDir.new
  extension Awestruct::Extensions::DataDir.new('/whatsnew')
  extension Awestruct::Extensions::DataDir.new('/features')
  extension Awestruct::Extensions::Posts.new( '/blog', :posts )
  extension Awestruct::Extensions::MyPaginator.new(:posts, '/blog/index', :per_page => 2 )
  # extension Awestruct::Extensions::Indexifier.new
  # Needs to be after Indexifier to get the linking correct; 
  extension Awestruct::Extensions::Feature::Index.new('/features', 15)
  # Needs to be after Indexifier to get the linking correct; 
  extension Awestruct::Extensions::Whatsnew::Index.new('/whatsnew')
  
end

