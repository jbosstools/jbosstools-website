require 'awestruct/astruct'

module Awestruct
  module Extensions
    class Downloads

      @@index_path = "/downloads/index.html"
      @@output_path_prefix = "/downloads/"
      @@download_single_version_layout_path = "download_single_version.html.haml"
      @@downloads_per_product_layout_path = "downloads_per_product_summary.html.haml"
      @@downloads_per_eclipse_stream_layout_path = "downloads_per_eclipse_stream_summary.html.haml"
      @@build_types = {:stable => [".GA", ".Final"], :development=>[".Alpha", ".Beta", ".CR"], :nightly=>["nightly", "Nightly"]}

      def initialize()
      end

      # generates synthetic pages for all downloadable versions of JBDS and JBT (stable, dev, nightly and older)
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
              info = OpenStruct.new
              build_type = guess_build_type(build_version) 
              info.name = site.products[product_id].name
              info.product_id = product_id
              info.version = build_version
              info.release_date = build_info["release_date"]
              info.eclipse_version = eclipse_version
              info.build_type = build_type
              info.blog_announcement_url = build_info["blog_announcement_url"]
              info.release_notes_url = build_info["release_notes_url"]
              info.supported_jbt_is_version = build_info["supported_jbt_is_version"]
              info.required_jbt_core_version = build_info["required_jbt_core_version"]
              info.required_devstudio_version = build_info["required_devstudio_version"]
              info.supported_devstudio_is_version = build_info["supported_devstudio_is_version"]
              info.whatsnew_url = get_whatsnew_page_output_path(product_id, build_version) 
              info.update_site_url = build_info["update_site_url"]
              info.marketplace_install_url = build_info["marketplace_install_url"]
              info.zips = build_info["zips"]
              info.active = build_info["active"]
              # finally, build regular download page
              download_page = generate_download_page(product_id, eclipse_version, 
                    build_version.to_s, info)
              
              # used to provide links to download .Final versions on /downloads
              # and links to latest builds per type on /download/<product_id>
              if info.active && @site.latest_builds_download_pages[product_id][build_type].nil? then
                @site.latest_builds_download_pages[product_id][build_type] = download_page
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
            #puts " Checking #{product_id} / #{eclipse_stream}"
            download_pages_per_eclipse_stream[product_id][eclipse_stream] = Hash.new
            product_versions.each do |product_version, product_info| 
              build_type = guess_build_type(product_version)
              if download_pages_per_eclipse_stream[product_id][eclipse_stream][build_type].nil? || 
                  download_pages_per_eclipse_stream[product_id][eclipse_stream][build_type] < product_version then
                download_pages_per_eclipse_stream[product_id][eclipse_stream][build_type] = product_version
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
              summary_page.build_versions[build_type] = download_pages_per_eclipse_stream[product_id][eclipse_stream][build_type] unless download_pages_per_eclipse_stream[product_id][eclipse_stream][build_type].nil?
            end
          end
        end
        $LOG.debug "*** Done with downloads extension." if $LOG.debug?
      end
      
      def get_whatsnew_page_output_path(product_id, product_version)
        unless @site.whatsnew_pages[product_id].nil? || @site.whatsnew_pages[product_id][product_version].nil? then
          return @site.whatsnew_pages[product_id][product_version].output_path
        end
        return nil
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

      def guess_build_type(build_version)
        @@build_types.each do |type, suffixes| 
          unless suffixes.select{|suffix| build_version.include? suffix}.first.nil?
            return type
          end
        end
        puts "Unable to determine build type for #{build_version}, assuming :development, then.."
        return :development
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
