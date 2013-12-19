require 'uri_helper'

module Awestruct
  module Extensions
    module Whatsnew
      class Index
        
        @@layout_path = "whatsnew.html.haml"
        
        def initialize(path_prefix)
          @path_prefix = path_prefix
        end

        def execute(site)
          @site = site
          $LOG.debug "*** Executing whatsnew extension...." if $LOG.debug?
          whatsnews = Hash.new
          site.whatsnews = whatsnews
          site.pages.each do |page|
            if page.relative_source_path =~ /^#{@path_prefix}\/.*\.adoc/ then
              unless site.features[page.feature_id].nil?
                $LOG.debug " Processing N&N " + page.feature_id.to_s +  " " + page.feature_version.to_s if $LOG.debug?
                puts " Processing N&N for " + page.feature_id.to_s + " " + page.feature_version
                whatsnew = OpenStruct.new
                site.engine.set_urls([page])
                whatsnew.url = URIHelper.concat(site.base_url, page.url)
                whatsnew.feature_id = page.feature_id
                whatsnew.feature_name = page.feature_name
                whatsnew.feature_version = page.feature_version
                #whatsnew.jbt_version = page.jbt_version
                #whatsnew.content = page.content
                if whatsnews[whatsnew.feature_id].nil? then 
                  whatsnews[whatsnew.feature_id] = Hash.new
                  whatsnews[whatsnew.feature_id][:details] = Array.new
                  whatsnews[whatsnew.feature_id][:merged] = Hash.new
                end
                whatsnews[whatsnew.feature_id][:details] << whatsnew
                main_version = get_main_version(whatsnew.feature_version)
                if whatsnews[whatsnew.feature_id][:merged][main_version].nil? then
                  #puts " Adding " + page.feature_id + " version " + main_version
                  whatsnew_page = create_page(page.feature_id, main_version + ".html")
                  whatsnew_page.feature_version = main_version
                  whatsnew_page.feature_id = page.feature_id
                  whatsnew_page.title = " What's New in " + main_version
                  whatsnews[whatsnew.feature_id][:merged][main_version] = whatsnew_page
                  # TODO: how to append page.content into whatsnew_page.content at the right location ?
                  #generate front-matter + content in raw_content ?
                  #puts page.content
                  whatsnews[whatsnew.feature_id][:merged][main_version].items = Array.new
                end
                #puts " Page content: #{page.content[0..10]}..."
                whatsnews[whatsnew.feature_id][:merged][main_version].items << page.content
              end
            end
            # sort the hashes by their key in reversed order (more recent versions come first)
            whatsnews.each do |feature_id, feature_whatsnew|
              feature_whatsnew[:merged].each do |version, whatsnew_page|
                whatsnew_page.items.sort!.reverse!
              end
            end
            
          end
          $LOG.debug "*** Done executing whatsnew extension...." if $LOG.debug?
        end
        
        def get_main_version(version)
          numbers = version.split(".")
          numbers[0..2].join('.')
        end
        
        def create_page(*paths)
          path_glob = File.join( @site.config.layouts_dir, @@layout_path)
          candidates = Dir[ path_glob ]
          return nil if candidates.empty?
          throw Exception.new( "too many choices for #{simple_path}" ) if candidates.size != 1
          whatsnew_page = @site.engine.load_page( candidates[0] )
          whatsnew_page.output_path = File.join(@path_prefix, paths)
          #whatsnew_page.create_context("foo!")
          #whatsnew_page.rendered_content
          #puts " Added page " + whatsnew_page.output_path
          @site.pages << whatsnew_page
          return whatsnew_page
        end
      end
    end
  end
end