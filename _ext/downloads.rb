require 'awestruct/astruct'

module Awestruct
  module Extensions
    class Downloads

      @@index_path = "/downloads/index.html"
      @@output_path_prefix = "/downloads/"
      @@layout_paths = {:single_version => "download_single_version.html.haml", :all_versions => "download_all_versions.html.haml"}
      @@download_page_metadata = {:latest_release=>{:page_path_fragment=>"latest", :page_title=>"Latest Stable"} ,
          :all_releases=>{:page_path_fragment=>"allversions", :page_title=>"All Versions"}}
      @@build_types = {:stable => [".GA", ".Final"], :development=>[".Alpha", ".Beta", ".CR"], :nightly=>["nightly"]}

      def initialize()
      end

      # generates synthetic pages for all downloadable versions of JBDS and JBT (stable, dev, nightly and older)
      def execute(site)
        $LOG.debug "*** Executing downloads extension..." if $LOG.debug?
        @site = site
        @site.download_pages = Hash.new
        @site.download_perma_links = Hash.new #permalinks per active eclipse stream.
        @site.all_versions_download_pages = Hash.new
        @site.latest_stable_builds_download_pages = Hash.new
        # generate a page for each dev/nightly/stable build per product until a version with a stable build is found 
        # (thus, skipping older product streams),
        # then 1 page for all stable builds (only) per product
        for product in [:devstudio, :devstudio_is, :jbt_core, :jbt_is]
          @site.download_pages[product] = Hash.new
          @site.download_perma_links[product] = Hash.new #permalinks per active eclipse stream.
          if site.products[product].nil? then
            next
          end
          # each product (DevStudio, etc.) is splitted on many Eclipse versions (Luna, etc)
          site.products[product][:streams].each do |eclipse_id, eclipse_stream|
            eclipse_version = site.products[:eclipse][eclipse_id]
            #permalinks per active eclipse stream.
            @site.download_perma_links[product][eclipse_id] = Hash.new if eclipse_version.active
            @site.download_pages[product][eclipse_id] = Array.new
            #permalinks for "stable.html", "development.html", etc. 
            puts "Processing " + eclipse_version.full_name + " stream (active: " + eclipse_version.active.to_s + ")..."
            # for each Eclipse versions can have many product builds, each one with build info
            eclipse_stream.each do |build_version, build_info|
              build_type = guess_build_type(build_version) 
              build_info.name = site.products[product].name
              build_info.version = build_version
              build_info.eclipse_version = eclipse_version
              build_info.build_type = build_type
              build_info.blog_announcement_url = (defined? build_version.blog_announcement) ? find_blog_announcement_path(build_version.blog_announcement) : nil
              build_info.update_site_url = (defined? build_version.update_site_url) ? build_version.update_site_url : nil
              build_info.marketplace_install_url = (defined? build_version.marketplace_install_url) ? build_version.marketplace_install_url : nil
              puts "  update site:" + build_info.update_site_url.to_s + " marketplace_install_url=" + build_info.marketplace_install_url.to_s
              if eclipse_version.active && @site.download_perma_links[product][eclipse_id][build_type].nil? then
                permalink_page = generate_single_version_download_page(product, eclipse_version, 
                      build_type.to_s, build_info, build_version)
                @site.download_perma_links[product][eclipse_id][build_type] = permalink_page
                @site.pages << permalink_page 
                if @site.latest_stable_builds_download_pages[product].nil? && build_type == :stable then
                  @site.latest_stable_builds_download_pages[product] = permalink_page
                end
              end
              # build regular download page
              download_page = generate_single_version_download_page(product, eclipse_version, 
                    build_version.to_s, build_info, build_version)
              @site.pages << download_page 
              @site.download_pages[product][eclipse_id] << download_page 
            end
          end
          all_versions_page = generate_all_versions_downloads_page(product)
          @site.pages << all_versions_page
          @site.all_versions_download_pages[product] = all_versions_page
          #puts "*** Download permalinks for " + product.to_s + ": " + @site.download_perma_links[product].to_s
        end
        $LOG.debug "*** Done with downloads extension." if $LOG.debug?
      end

      def generate_single_version_download_page(product, eclipse_version, page_path_fragment, build_info, build_version)
        page_title ||= @site.products[product].name + " " + build_version.to_s
        product_path_fragment = @site.products[product].url_path_fragment
        path = @@output_path_prefix + product_path_fragment + "/" + eclipse_version.url_path_fragment + "/" + page_path_fragment + ".html"
        page = generate_download_page(:single_version, path)
        page.title = page_title
        page.build_info = build_info
        page.product = product
        page.eclipse_version = eclipse_version
        #puts "  generated download page at '" + page.output_path + "' with title '" + page.title + "'"
        page
      end

      def generate_all_versions_downloads_page(product)
        product_path_fragment = @site.products[product].url_path_fragment
        path = @@output_path_prefix + product_path_fragment + "/" + @@download_page_metadata[:all_releases][:page_path_fragment] + ".html"
        download_page = generate_download_page(:all_versions, path)
        download_page.title = @site.products[product].name + " - " + @@download_page_metadata[:all_releases][:page_title]
        download_page.product = product
        #puts " generated download page at '" + download_page.output_path + "' with title '" + download_page.title + "'"
        download_page
      end
    
      def generate_download_page(layout_type, path)
        layout_path = @@layout_paths[layout_type]
        page = find_layout_page(layout_path)
        page.output_path = File.join(path)
        @site.pages << page
        return page
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
