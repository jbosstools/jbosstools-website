require 'uri_helper'
require 'whatsnew_helper'
require 'products_helper'

module Awestruct
  module Extensions
    class Whatsnew
      
      @@whatsnew_layout_path = "whatsnew_aggregated.html.haml"
      @@whatsnew_overview_layout_path = "whatsnew_overview.html.haml"
      
      def initialize(source_path_prefix, target_path_prefix)
        puts "Initializing Whatsnew"
        @source_path_prefix = source_path_prefix
        @target_path_prefix = target_path_prefix
      end

      def execute(site)
        $LOG.debug "*** Executing whatsnew extension...." if $LOG.debug?
        whatsnew_data = Hash.new
        Dir[ "#{site.dir}/#{@source_path_prefix}/*" ].each do |entry|
          if ( File.directory?( entry ) )
            data_key = File.basename( entry )
            data_map = {}
            Dir[ "#{entry}/*" ].each do |chunk|
              key = File.basename( chunk ).to_sym
              chunk_page = site.engine.load_page( chunk )
              data_map[ key ] = chunk_page
            end
            whatsnew_data[data_key.to_sym] = data_map 
          end
        end
        # grouping all components' N&N pages per product id and product version
        site.whatsnew_pages = Hash.new
        whatsnew_data.each do |component_id, component_pages|
          # treat .adoc pages
          component_pages.select{|key, component_page| File.extname(key.to_s) == ".adoc"}.each do |key, component_page|
            if site.whatsnew_pages[component_page.product_id].nil? then
              site.whatsnew_pages[component_page.product_id] = Hash.new
            end
            whatsnew_page = get_whatsnew_page(site, component_page.product_id, component_page.product_version)
            add_component_page(whatsnew_page, component_page)
            # now, deal with *.Final* versions if they exist in site.products
            unless ProductsHelper.is_stable_version(component_page.component_version)
              product_stable_version = ProductsHelper.get_stable_version(site, component_page.product_id, component_page.product_version)
              #puts " stable version of #{component_page.product_id} #{component_page.product_version}: #{product_stable_version}"
              unless product_stable_version.nil? 
                whatsnew_final_page = get_whatsnew_page(site, component_page.product_id, product_stable_version)
                add_component_page(whatsnew_final_page, component_page)
              end
            end
          end
          # treat other pages (ie, images)
          component_pages.select{|key, page| File.extname(key.to_s) != ".adoc"}.each do |key, component_page|
            add_extra_content(site, component_page.source_path)
          end
        end
        $LOG.debug "*** Done executing whatsnew extension...." if $LOG.debug?
      end
      
      def add_component_page(whatsnew_page, component_page)  
        if whatsnew_page.component_news[component_page.component_id].nil?
          whatsnew_page.component_news[component_page.component_id] = Array.new
        end
        whatsnew_page.component_news[component_page.component_id] << component_page 
        # set page.output_path to @target_path_prefix to have correct relative path to images in the rendered HTML puput
        if component_page.output_path.include? @source_path_prefix
          output_path = component_page.output_path
          output_path[@source_path_prefix] = @target_path_prefix
          component_page.output_path = output_path
        end
      end
      
      def add_extra_content(site, location)
        if ( File.directory?( location ) )
          Dir[ "#{location}/*" ].each do |chunk|
            if File.directory?(chunk) 
              add_extra_content(site, chunk)
            else
              page = site.engine.load_page(chunk)
              output_path = page.output_path
              output_path[@source_path_prefix] = @target_path_prefix
              page.output_path = output_path
              site.pages << page
            end
          end
        end
      end

      def get_whatsnew_page(site, product_id, product_version)
        site.whatsnew_pages[product_id] = Hash.new if site.whatsnew_pages[product_id].nil?
        if site.whatsnew_pages[product_id][product_version].nil? then
          product_url_path_fragment = site.products[product_id].url_path_fragment
          product_active = ProductsHelper.is_product_version_active(site, product_id, product_version)
          puts "  building  N&N page for #{product_id} #{product_version}"
          page = create_page(site, @@whatsnew_layout_path, @target_path_prefix, product_url_path_fragment, product_version)
          page.build_info = ProductsHelper.get_product_info(site, product_id, product_version)
          page.product_id = product_id
          page.product_name = site.products[product_id].name
          page.product_version = product_version
          page.component_news = Hash.new
          page.product_active = product_active
          # see downloads.rb for symbols
          page.build_type= ProductsHelper.get_build_type(site, product_id, product_version)
          page.build_type_label= ProductsHelper.get_build_type_label(site, product_id, product_version)
          site.whatsnew_pages[product_id][product_version] = page
        end
        site.whatsnew_pages[product_id][product_version]
      end

      def create_page(site, layout_path, *paths)
        path_glob = File.join(site.config.layouts_dir, layout_path)
        candidates = Dir[ path_glob ]
        return nil if candidates.empty?
        throw Exception.new( "too many choices for #{simple_path}" ) if candidates.size != 1
        page = site.engine.load_page( candidates[0] )
        page.output_path = File.join(paths) + ((paths.last.end_with? ".html") ? "" : ".html")
        #puts "    added page at #{page.output_path}"
        site.pages << page
        site.engine.set_urls([page])
        page
      end
    end
  end
end