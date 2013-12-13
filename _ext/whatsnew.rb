require 'uri_helper'

module Awestruct
  module Extensions
    module Whatsnew
      class Index
        
        @@transformers_registered = false
        
        def initialize(path_prefix)
          @path_prefix = path_prefix
        end

        def execute(site)
          $LOG.debug "*** Executing whatsnew extension...." if $LOG.debug?
          news_per_module = Hash.new
          
          site.pages.each do |page|
            if ( page.relative_source_path =~ /^#{@path_prefix}\/.*\.adoc/)
              puts " Processing N&N " + page.module_name +  " " + page.module_version 
              news_item = OpenStruct.new
              site.engine.set_urls([page])
              news_item.url = URIHelper.concat(site.base_url , page.url)
              news_item.module_id = page.module_id
              news_item.module_name = page.module_name
              news_item.module_version = page.module_version
              news_item.jbt_version = page.jbt_version
              news_item.content = page.content
              
              if(news_per_module[news_item.module_id] == nil) 
                news_per_module[news_item.module_id] = Array.new
              end
              news_per_module[news_item.module_id] << news_item
            end
          end
          
          site.news_per_module = news_per_module
        
          $LOG.debug "*** Done executing whatsnew extension...." if $LOG.debug?
          
        end
      end

    end
  end
end