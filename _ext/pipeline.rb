# JBoss.org extensions
require 'asciidoctor_extensions'
require 'wget_wrapper'
require 'js_minifier'
require 'css_minifier'
require 'html_minifier'
require 'file_merger'
#require 'less_config'
require 'breadcrumb'
#require 'symlinker'
#require 'relative'

# JBoss Tools custom 
require 'font_path'
require 'textile_plus'
require 'mytagger'
require 'mypaginator'
require 'events'
require 'features'
require 'whatsnew'
require 'whatsnew_helper'
require 'downloads'
require 'downloads_helper'
require 'myposts'
require 'videos'
require 'uri_helper'
require 'build_info'

Awestruct::Extensions::Pipeline.new do
  
  helper Awestruct::Extensions::Partial

  helper Awestruct::Extensions::Relative

  # JBoss.org extensions
  helper Awestruct::Extensions::Breadcrumb
  extension Awestruct::Extensions::WgetWrapper.new
  #transformer Awestruct::Extensions::JsMinifier.new
  #transformer Awestruct::Extensions::CssMinifier.new
  #transformer Awestruct::Extensions::HtmlMinifier.new
  extension Awestruct::Extensions::FileMerger.new
  #extension Awestruct::Extensions::LessConfig.new
  #extension Awestruct::Extensions::Symlinker.new
  
  # JBoss Tools custom 
  extension Awestruct::Extensions::AsciidoctorExtensions.new
  extension Awestruct::Extensions::BuildInfo.new
  extension Awestruct::Extensions::DataDir.new
  extension Awestruct::Extensions::MyPosts.new('/blog', :posts)
  extension Awestruct::Extensions::MyPaginator.new(:posts, '/blog/index', :per_page => 2 )
  extension Awestruct::Extensions::MyTagger.new( :posts, '/blog/index', '/blog/tags', :per_page=>10,
   :sanitize=>true )
  #extension Awestruct::Extensions::Indexifier.new
  # Needs to be after Indexifier to get the linking correct; 
  #extension Awestruct::Extensions::DataDir.new('/features')
  extension Awestruct::Extensions::Features.new('/features')
  # Needs to be after Indexifier to get the linking correct; 
  extension Awestruct::Extensions::Whatsnew.new('/documentation/_whatsnew', '/documentation/whatsnew')
  helper Awestruct::Extensions::WhatsnewHelper
  
  # Download needs to be after whatsnew, to link from download to whatsnew
  extension Awestruct::Extensions::Downloads.new
  helper Awestruct::Extensions::DownloadsHelper
  helper Awestruct::Extensions::URIHelper
  
  
  extension Awestruct::Extensions::Videos.new('/documentation/videos')

  extension Awestruct::Extensions::Events.new('/events')
  
  extension Awestruct::Extensions::Disqus.new()
  
  extension Awestruct::Extensions::Atomizer.new(:posts, '/blog/news.atom')
  
  helper Awestruct::Extensions::GoogleAnalytics
  
  
  
end

