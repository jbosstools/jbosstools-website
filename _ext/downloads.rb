require 'awestruct/astruct'
require 'products_helper'

module Awestruct
  module Extensions
    class Downloads

      @@index_path = "/downloads/index.html"
      @@output_path_prefix = "/downloads/"
      @@download_single_version_layout_path = "download_single_version.html.haml"
      @@downloads_per_product_layout_path = "downloads_per_product_summary.html.haml"
      @@downloads_per_eclipse_stream_layout_path = "downloads_per_eclipse_stream_summary.html.haml"
      #@@build_types = {:stable => [".GA", ".Final"], :development=>[".Alpha", ".Beta", ".CR"], :nightly=>["nightly", "Nightly"]}

      def initialize()
      end

      # generates synthetic pages for all downloadable versions of devstudio and JBT (stable, dev, nightly and older)
      def execute(site)
        $LOG.debug "*** Executing downloads extension..." if $LOG.debug?
        # making these labels available in layouts, too.
        site.labels = {:stable=>"Stable", :development=>"Development", :nightly=>"Nightly"}
        @site = site
        @site.download_pages = Hash.new
        @site.latest_builds_download_pages = Hash.new

        # generate a page for each dev/nightly/stable build per product until a version with a stable build is found 
        # (thus, skipping older product streams),
        # then 1 page for all stable builds (only) per product
        for product_id in [:devstudio, :devstudio_is, :jbt_core, :jbt_is]
          @site.download_pages[product_id] = Hash.new
          @site.latest_builds_download_pages[product_id] = Hash.new
          if site.products[product_id].nil? then
            next
          end
          # each product (DevStudio, etc.) is splitted on many Eclipse versions (Luna, etc)
          site.products[product_id][:streams].each do |eclipse_id, eclipse_stream|
            eclipse_version = site.products[:eclipse][eclipse_id]
            if eclipse_version.nil?
              raise "Eclipse version '#{eclipse_id}' referenced in stream not defined in products.yml"
            end
            # for each Eclipse versions can have many product builds, each one with build info
            eclipse_stream.each do |build_version, build_info|
              product_info = ProductsHelper.get_build_info(site, product_id, build_version, eclipse_version, build_info)
              download_page = generate_download_page(product_id, eclipse_version, 
                    build_version.to_s, product_info)
              
              # used to provide links to download .Final versions on /downloads
              # and links to latest builds per type on /download/<product_id>
              if (!product_info.build_type_label.nil? && 
                  (@site.latest_builds_download_pages[product_id][product_info.build_type_label].nil? || 
                    (@site.latest_builds_download_pages[product_id][product_info.build_type_label].build_info.version <=> download_page.build_info.version) == -1 ))
                @site.latest_builds_download_pages[product_id][product_info.build_type_label] = download_page
              end
            end
          end
        end
        # link jbt_core to jbt_is using links from jbt_is to jbt_core, using the latest version of jbt_is
        for product_id in [:jbt_is]
          site.download_pages[product_id].each do |product_version, download_page|
            required_jbt_core_version = download_page.build_info.required_jbt_core_version
            # look-up jbt_core download page
            unless required_jbt_core_version.nil?
              jbt_core_download_page = site.download_pages[:jbt_core][required_jbt_core_version]
              if (!jbt_core_download_page.nil? && (jbt_core_download_page.build_info.supported_jbt_is_version.nil? || 
                 (jbt_core_download_page.build_info.supported_jbt_is_version <=> product_version) == -1 ))
                #puts "linking jbt_is #{product_version} to jbt_core #{required_jbt_core_version}"
                jbt_core_download_page.build_info.supported_jbt_is_version = product_version
              end
            end
          end
        end
        
        # link devstudio_core to devstudio_is using links from devstudio_is to devstudio_core, using the latest version of devstudio_is
        for product_id in [:devstudio_is]
          site.download_pages[product_id].each do |product_version, download_page|
            required_devstudio_version = download_page.build_info.required_devstudio_version
            # look-up devstudio download page
            unless required_devstudio_version.nil?
              devstudio_download_page = site.download_pages[:devstudio][required_devstudio_version]
              if (!devstudio_download_page.nil? && (devstudio_download_page.build_info.supported_devstudio_is_version.nil? || 
                 (devstudio_download_page.build_info.supported_devstudio_is_version <=> product_version) == -1 ))
                #puts "linking devstudio_is #{product_version} to devstudio #{required_devstudio_version}"
                devstudio_download_page.build_info.supported_devstudio_is_version = product_version
              end
            end
          end
        end
        
        # building download page per Eclipse streams (eg: /downloads/jbosstools/kepler)
        download_pages_per_product = Hash.new
        download_pages_per_eclipse_stream = Hash.new
        for product_id in [:devstudio, :devstudio_is, :jbt_core, :jbt_is]
          download_pages_per_product[product_id] = Hash.new
          download_pages_per_eclipse_stream[product_id] = Hash.new
          site.products[product_id].streams.each do |eclipse_stream, product_versions|
            download_pages_per_eclipse_stream[product_id][eclipse_stream] = Hash.new
            product_versions.each do |product_version, product_info| 
              # the real build type, not the one for the labels
              build_info = ProductsHelper.get_build_info(site, product_id, product_version, eclipse_stream, product_info) 
              build_type = build_info.build_type
              if (download_pages_per_eclipse_stream[product_id][eclipse_stream][build_type].nil? || 
                  download_pages_per_eclipse_stream[product_id][eclipse_stream][build_type].version < product_version)  then
                  #puts "  Adding build type #{product_version} as latest #{build_type} version of #{product_id} / #{eclipse_stream}"
                download_pages_per_eclipse_stream[product_id][eclipse_stream][build_type] = build_info
              end
            end
          end
        end
        # generate actual summary pages for downloads per product, then per product and version
        for product_id in [:devstudio, :devstudio_is, :jbt_core, :jbt_is]
          #puts " Last releases for #{product_id}: #{@site.latest_builds_download_pages[product_id]}"
          summary_page = generate_download_per_product_page(product_id)
          summary_page.build_versions = Hash.new
          for build_type in [:stable, :development, :nightly]
            summary_page.build_versions[build_type] = @site.latest_builds_download_pages[product_id][build_type]
          end
          
          site.products[product_id].streams.each do |eclipse_stream, product_versions|
            #puts " Last releases for #{product_id} / #{eclipse_stream}: #{download_pages_per_eclipse_stream[product_id][eclipse_stream]}"
            summary_page = generate_download_per_eclipse_stream_page(product_id, eclipse_stream)
            summary_page.build_versions = Hash.new
            for build_type in [:stable, :development, :nightly]
              if !download_pages_per_eclipse_stream[product_id][eclipse_stream][build_type].nil?
                #puts "  Using #{download_pages_per_eclipse_stream[product_id][eclipse_stream][build_type].version} as latest #{build_type} version of #{product_id} / #{eclipse_stream}"
                summary_page.build_versions[build_type] = download_pages_per_eclipse_stream[product_id][eclipse_stream][build_type]
              end
            end
          end
        end
        $LOG.debug "*** Done with downloads extension." if $LOG.debug?
      end
      
      def generate_download_page(product_id, eclipse_version, page_path_fragment, build_info)
        page_title ||= @site.products[product_id].name + " " + build_info.version.to_s
        product_path_fragment = @site.products[product_id].url_path_fragment
        path = @@output_path_prefix + product_path_fragment + "/" + eclipse_version.url_path_fragment + "/" + page_path_fragment + ".html"
        download_page = find_layout_page(@@download_single_version_layout_path)
        download_page.output_path = File.join(path)
        download_page.title = page_title
        download_page.build_info = build_info
        download_page.product_id = product_id
        download_page.eclipse_version = eclipse_version
        @site.download_pages[product_id][build_info.version] = download_page 
        @site.pages << download_page
        #puts "  generated download page at '#{download_page.output_path}' with title '#{download_page.title}'"
        download_page
      end
      
      def generate_download_per_eclipse_stream_page(product_id, eclipse_stream)
        eclipse_version = @site.products.eclipse[eclipse_stream]
        page_title ||= eclipse_version.full_name
        product_path_fragment = @site.products[product_id].url_path_fragment
        path = @@output_path_prefix + product_path_fragment + "/" + eclipse_version.url_path_fragment + "/index.html"
        download_page = find_layout_page(@@downloads_per_eclipse_stream_layout_path)
        download_page.output_path = File.join(path)
        download_page.title = page_title
        download_page.product_id = product_id
        download_page.eclipse_version = eclipse_version
        @site.pages << download_page
        #puts "  generated download page at '#{download_page.output_path}' with title '#{download_page.title}'"
        download_page
      end

      def generate_download_per_product_page(product_id)
        page_title ||= @site.products[product_id].name
        product_path_fragment = @site.products[product_id].url_path_fragment
        path = @@output_path_prefix + product_path_fragment + "/index.html"
        download_page = find_layout_page(@@downloads_per_product_layout_path)
        download_page.output_path = File.join(path)
        download_page.title = page_title
        download_page.product_id = product_id
        @site.pages << download_page
        #puts "  generated download page at '#{download_page.output_path}' with title '#{download_page.title}'"
        download_page
      end

      def find_blog_announcement_path(blog_announcement_page_name)
        unless blog_announcement_page_name.nil? || blog_announcement_page_name.empty?
          #puts "Looking for post page matching '" + blog_announcement_page_name.to_s + "'"
          @site.posts.each do |post|
            #puts " " + post.simple_name
            if post.simple_name.eql? blog_announcement_page_name
              return post.output_path
            end
          end
          puts "Unable to find page for blog " + blog_announcement_page_name.to_s
        end
        return nil
      end
      
      def find_layout_page(simple_path)
        path_glob = File.join( @site.config.layouts_dir, simple_path)
        candidates = Dir[ path_glob ]
        return nil if candidates.empty?
        throw Exception.new( "too many choices for #{simple_path}" ) if candidates.size != 1
        @site.engine.load_page( candidates[0] )
      end
    end

    
  end
  
end
