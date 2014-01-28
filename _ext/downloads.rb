require 'awestruct/astruct'

module Awestruct
  module Extensions
    class Downloads

      @@index_path = "/downloads/index.html"
      @@output_path_prefix = "/downloads/"
      @@layout_path = "download_any_version.html.haml"
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
        @site.latest_stable_builds_download_pages = Hash.new

        # generate a page for each dev/nightly/stable build per product until a version with a stable build is found 
        # (thus, skipping older product streams),
        # then 1 page for all stable builds (only) per product
        for product_id in [:devstudio, :devstudio_is, :jbt_core, :jbt_is]
          @site.download_pages[product_id] = Array.new
          if site.products[product_id].nil? then
            next
          end
          # each product (DevStudio, etc.) is splitted on many Eclipse versions (Luna, etc)
          site.products[product_id][:streams].each do |eclipse_id, eclipse_stream|
            eclipse_version = site.products[:eclipse][eclipse_id]
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
              info.whatsnew_url = get_whatsnew_page_output_path(product_id, build_version) #build_info["whatsnew_url"]
              info.update_site_url = build_info["update_site_url"]
              info.marketplace_install_url = build_info["marketplace_install_url"]
              info.zips = build_info["zips"]
              info.active = build_info["active"]
              # finally, build regular download page
              download_page = generate_download_page(product_id, eclipse_version, 
                    build_version.to_s, info)
              
              # used to provide links to download .Final versions on /downloads
              if info.active && @site.latest_stable_builds_download_pages[product_id].nil? && 
                  build_type == :stable then
                @site.latest_stable_builds_download_pages[product_id] = download_page
              end
                    
              
            end
          end
          #puts "*** Download permalinks for " + product_id.to_s + ": " + @site.download_perma_links[product_id].to_s
        end
        $LOG.debug "*** Done with downloads extension." if $LOG.debug?
      end
      
      def get_whatsnew_page_output_path(product_id, product_version)
        whatsnew_aggregated_page_output_path = nil
        unless @site.whatsnew_pages[product_id].nil?
          if product_version.end_with?(".Final") && !@site.whatsnew_pages[product_id][product_version].nil? then
            whatsnew_aggregated_page = @site.whatsnew_pages[product_id][product_version][product_version]
          elsif !product_version.end_with?(".Final")
            whatsnew_aggregated_page = @site.whatsnew_pages[product_id][product_version]
          end
          unless whatsnew_aggregated_page.nil?
            whatsnew_aggregated_page_output_path = whatsnew_aggregated_page.output_path
          end
        end
        whatsnew_aggregated_page_output_path
      end

      def generate_download_page(product_id, eclipse_version, page_path_fragment, build_info)
        page_title ||= @site.products[product_id].name + " " + build_info.version.to_s
        product_path_fragment = @site.products[product_id].url_path_fragment
        path = @@output_path_prefix + product_path_fragment + "/" + eclipse_version.url_path_fragment + "/" + page_path_fragment + ".html"
        download_page = find_layout_page(@@layout_path)
        download_page.output_path = File.join(path)
        download_page.title = page_title
        download_page.build_info = build_info
        download_page.product_id = product_id
        download_page.eclipse_version = eclipse_version
        @site.download_pages[product_id] << download_page 
        @site.pages << download_page
        #puts "  generated download page at '" + page.output_path + "' with title '" + page.title + "'"
        download_page
      end

      def guess_build_type(build_version)
        @@build_types.each do |type, suffixes| 
          unless suffixes.select{|suffix| build_version.include? suffix}.first.nil?
            return type
          end
        end
        puts "Unable to determine build type for " + build_version + ", assuming :development, then.."
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
