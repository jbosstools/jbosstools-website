require 'uri_helper'

module Awestruct
  module Extensions
    class Whatsnew
      
      @@whatsnew_minor_version_layout_path = "whatsnew_minor_version.html.haml"
      @@whatsnew_major_version_layout_path = "whatsnew_major_version.html.haml"
      
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
        site.whatsnew_minor_pages = Hash.new
        site.whatsnew_major_pages = Hash.new
        whatsnew_pages.each do |jbt_core_version, pages|
          puts " Building N&N page for #{jbt_core_version.to_s}"
          # minor version page
          minor_version_whatsnew_page = get_minor_version_whatsnew_page(site, @path_prefix, jbt_core_version.to_s)
          # major version page
          major_version_whatsnew_page = get_major_version_whatsnew_page(site, @path_prefix, get_major_version(jbt_core_version))
          # fill the major/minor version pages with individual components whatnew pages without touching their content!
          pages.sort{|x,y| x.feature_name <=> y.feature_name}.each do |page|
            minor_version_whatsnew_page.individual_pages << page
            major_version_whatsnew_page.components[page.feature_id] = Array.new if major_version_whatsnew_page.components[page.feature_id].nil?
            major_version_whatsnew_page.components[page.feature_id] << page
          end
        end
        # rename the page for the latest major version's N&N to /latest.html 
        latest_major_version = site.whatsnew_minor_pages.keys.sort{|x, y| y <=> x}.first
        puts " Latest major version is #{latest_major_version}"
        site.whatsnew_minor_pages[latest_major_version].output_path = File.join(@path_prefix, "latest.html")
        $LOG.debug "*** Done executing whatsnew extension...." if $LOG.debug?
      end
      
      def get_major_version_whatsnew_page(site, path_prefix, major_version)
        page = site.whatsnew_major_pages[major_version]
        if page.nil?
          page = create_page(@@whatsnew_major_version_layout_path, path_prefix, major_version.to_s + ".html")
          page.version = major_version
          page.components = Hash.new
          site.whatsnew_major_pages[major_version] = page
        end
        page
      end

      def get_minor_version_whatsnew_page(site, path_prefix, minor_version)
          page = create_page(@@whatsnew_minor_version_layout_path, path_prefix, minor_version.to_s + ".html")
          page.version = minor_version
          page.individual_pages = Array.new
          site.whatsnew_minor_pages[minor_version] = page
          page
      end
      
      def get_major_version(version)
        numbers = version.split(".")
        numbers[0..2].join('.')
      end
      
      def create_page(layout_path, *paths)
        path_glob = File.join( @site.config.layouts_dir, layout_path)
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