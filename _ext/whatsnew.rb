require 'uri_helper'

module Awestruct
  module Extensions
    class Whatsnew
      
      @@whatsnew_merged_layout_path = "whatsnew_single_version.html.haml"
      
      def initialize(path_prefix)
        @path_prefix = path_prefix
      end

      def execute(site)
        @site = site
        $LOG.debug "*** Executing whatsnew extension...." if $LOG.debug?
        whatsnew_pages = Hash.new
        #site.whatsnew_pages = whatsnew_pages
        site.pages.each do |page|
          if page.relative_source_path =~ /^#{@path_prefix}\/.*\.adoc/ then
            $LOG.debug " Processing N&N " + page.feature_id.to_s +  " " + page.feature_version.to_s if $LOG.debug?
            #puts " Processing N&N for " + page.feature_id.to_s + " " + page.feature_version
            ## What's new page structure per module and version
            site.engine.set_urls([page])
            page.feature_name = site.modules[page.feature_id].name
            if whatsnew_pages[page.jbt_core_version].nil? then
              whatsnew_pages[page.jbt_core_version] = Array.new
            end
            whatsnew_pages[page.jbt_core_version] << page
          end
        end
        # showing all component whatsnew per product version on a single page
        site.whatsnew_aggregated_pages = Hash.new
        whatsnew_pages.each do |jbt_core_version, pages|
          puts " " + jbt_core_version.to_s
          whatsnew_aggregated_page = create_page(@path_prefix, jbt_core_version.to_s + ".html")
          #whatsnew_aggregated_page.title = jbt_core_version.to_s
          whatsnew_aggregated_page.jbt_core_version = jbt_core_version
          whatsnew_aggregated_page.individual_pages = Array.new
          pages.sort{|x,y| x.feature_name <=> y.feature_name}.each do |page|
            whatsnew_aggregated_page.individual_pages << page
          end
          site.whatsnew_aggregated_pages[jbt_core_version] = whatsnew_aggregated_page
        end
        
        $LOG.debug "*** Done executing whatsnew extension...." if $LOG.debug?
      end
      
      def get_main_version(version)
        numbers = version.split(".")
        numbers[0..2].join('.')
      end
      
      def create_page(*paths)
        path_glob = File.join( @site.config.layouts_dir, @@whatsnew_merged_layout_path)
        candidates = Dir[ path_glob ]
        return nil if candidates.empty?
        throw Exception.new( "too many choices for #{simple_path}" ) if candidates.size != 1
        whatsnew_page = @site.engine.load_page( candidates[0] )
        whatsnew_page.output_path = File.join(paths)
        puts " Added page " + whatsnew_page.output_path
        @site.pages << whatsnew_page
        return whatsnew_page
      end
    end
  end
end