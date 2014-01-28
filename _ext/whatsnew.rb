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
          if page.relative_source_path =~ /^#{@path_prefix}\/.*\.adoc/ && !page.product_id.nil? && !page.product_version.nil? then
            $LOG.debug "  Processing N&N " + page.component_id.to_s +  " " + page.component_version.to_s if $LOG.debug?
            site.engine.set_urls([page])
            if whatsnew_pages[page.product_id].nil? then
              whatsnew_pages[page.product_id] = Hash.new
            end
            if whatsnew_pages[page.product_id][page.product_version].nil? then
              whatsnew_pages[page.product_id][page.product_version] = Array.new
            end
            whatsnew_pages[page.product_id][page.product_version] << page
          end
        end
        # showing all component whatsnew per product version on a single page
        site.whatsnew_pages = Hash.new
        whatsnew_pages.each do |product_id, pages_per_version|
          product_url_path_fragment = site.products[product_id].url_path_fragment
          # minor version pages
          pages_per_version.each do |product_version, pages|
            product_name = site.products[product_id].name
            if site.whatsnew_pages[product_id].nil? then
              site.whatsnew_pages[product_id] = Hash.new
            end
            product_major_version = get_major_version(product_version)
            if product_defined(product_id, product_version) then
              # use the minor version page layout to build a page for the minor version summary
              whatsnew_page = get_minor_version_whatsnew_page(product_id, product_version, product_url_path_fragment)
              whatsnew_summary_page = nil
            elsif product_defined(product_id, product_major_version) then
              # use the major version page layout to build a page for the minor version summary
              whatsnew_page = get_major_version_whatsnew_page(product_id, product_version, product_major_version, product_url_path_fragment)
              whatsnew_summary_page = get_major_version_whatsnew_page(product_id, product_major_version, product_major_version, product_url_path_fragment)
            else 
              puts "Sorry, #{product_id} version #{product_version} or #{product_major_version} is not defined in products.yml"
            end
            # fill the major/minor version pages with individual components whatnew pages without touching their content!
            pages.sort{|x,y| x.feature_name <=> y.feature_name}.each do |page|
              add_page(whatsnew_page, page)
              add_page(whatsnew_summary_page, page)
            end
          end
          
          
          # rename the page for the latest major version's N&N to /latest.html 
          unless site.whatsnew_pages[product_id].nil?
            latest_version = site.whatsnew_pages[product_id].keys.sort{|x, y| y <=> x}.first
            # if latest version is final
            if latest_version.end_with? ".Final" then
              site.whatsnew_pages[product_id][latest_version][latest_version].output_path = File.join(@path_prefix, product_url_path_fragment, "latest.html")
              puts " Latest version is #{latest_version} at #{site.whatsnew_pages[product_id][latest_version][latest_version].output_path}"
              site.latest_whatsnew_path = site.whatsnew_pages[product_id][latest_version][latest_version].output_path
            else
              # otherwise..
              site.whatsnew_pages[product_id][latest_version].output_path = File.join(@path_prefix, product_url_path_fragment, "latest.html")
              puts " Latest version is #{latest_version} at #{site.whatsnew_pages[product_id][latest_version].output_path}"
              site.latest_whatsnew_path = site.whatsnew_pages[product_id][latest_version].output_path
            end
          end
        end
        
        
        $LOG.debug "*** Done executing whatsnew extension...." if $LOG.debug?
      end
      
      def add_page(whatsnew_page, component_page)
        unless whatsnew_page.nil?
          if whatsnew_page.component_pages[component_page.component_id].nil?
            whatsnew_page.component_pages[component_page.component_id] = Array.new
          end
          whatsnew_page.component_pages[component_page.component_id] << component_page 
        end
      end
      
      def get_major_version(version)
        numbers = version.split(".")
        numbers[0..2].join('.') + ".Final"
      end
      
      def product_defined(product_id, product_version)
        unless @site.products[product_id].nil? then
          @site.products[product_id].streams.each do |stream_id, stream_versions|
            unless stream_versions[product_version].nil? then
              return true
            end
          end
        end
        puts "  #{product_id} #{product_version} is not defined in products.yml - skipping the N&N content."
        return false
      end
      
      def get_major_version_whatsnew_page(product_id, product_version, product_major_version, product_url_path_fragment)
        @site.whatsnew_pages[product_id][product_major_version] = Hash.new if @site.whatsnew_pages[product_id][product_major_version].nil?
        if @site.whatsnew_pages[product_id][product_major_version][product_version].nil? then
          puts "  building N&N page for #{product_id} #{product_major_version} / #{product_version}"
          page = create_page(@@whatsnew_major_version_layout_path, @path_prefix, product_url_path_fragment, product_version)
          page.product_id = product_id
          page.product_version = product_version
          page.product_major_version = product_major_version
          page.component_pages = Hash.new
          # see downloads.rb for symbols
          page.build_type=:stable
          @site.whatsnew_pages[product_id][product_major_version][product_version] = page
        end
        @site.whatsnew_pages[product_id][product_major_version][product_version]
      end

      def get_minor_version_whatsnew_page(product_id, product_version, product_url_path_fragment)
        puts "  building N&N page for #{product_id} #{product_version}"
        page = create_page(@@whatsnew_minor_version_layout_path, @path_prefix, product_url_path_fragment, product_version)
        page.product_id = product_id
        page.product_version = product_version
        page.component_pages = Hash.new
        # see downloads.rb for symbols
        page.build_type=:development
        @site.whatsnew_pages[product_id][product_version] = page
        page
      end
      
      def create_page(layout_path, *paths)
        path_glob = File.join( @site.config.layouts_dir, layout_path)
        candidates = Dir[ path_glob ]
        return nil if candidates.empty?
        throw Exception.new( "too many choices for #{simple_path}" ) if candidates.size != 1
        page = @site.engine.load_page( candidates[0] )
        page.output_path = File.join(paths) + ".html"
        puts "    added page at #{page.output_path}"
        @site.pages << page
        @site.engine.set_urls([page])
        return page
      end
    end
  end
end