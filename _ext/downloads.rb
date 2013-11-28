require 'awestruct/astruct'

module Awestruct
  module Extensions
    class Downloads


      @@index_path = "/downloads/index.html"
      @@output_path_prefix = "/downloads/"
      @@layout_paths = {:single_version => "download_single_version.html.haml", :all_versions => "download_all_versions.html.haml"}
      @@download_page_metadata = {:latest_release=>{:page_path_fragment=>"latest", :page_title=>"Latest Stable"} ,
          :all_releases=>{:page_path_fragment=>"allversions", :page_title=>"All Versions"}}


      def initialize()
      end

      # generates synthetic pages for all downloadable versions of JBDS and JBT (stable, dev, nightly and older)
      def execute(site)
        $LOG.debug "*** Executing downloads extension..." if $LOG.debug?
        @site = site
        @site.active_download_pages = Hash.new
        @site.all_download_pages = Hash.new
        # generate a page for each dev/nightly/stable build per product until a version with a stable build is found 
        # (thus, skipping older product streams),
        # then 1 page for all stable builds (only) per product
        for product_type in [:devstudio, :devstudio_is, :jbt_core, :jbt_is]
          @site.active_download_pages[product_type] = Array.new 
          @site.all_download_pages[product_type] = Array.new
          if site.products[product_type].nil? then
            next
          end
          stable_build_found = false
          site.products[product_type][:streams].each do |eclipse_stream|
            eclipse_version = site.products[:eclipse][eclipse_stream[0]]
            #puts "Eclipse version: " + eclipse_version.to_s
            # :stable in last position to be sure we grab dev/nightly builds before breaking the loop
            for build_type in [:development, :nightly,:stable] 
              if eclipse_stream[1][build_type].nil? || eclipse_stream[1][build_type].first.nil? then
                next
              end
              build_info = eclipse_stream[1][build_type].first
              #puts " Product build: " + build_info.to_s
              build_info[1].name = site.products[product_type].name
              build_info[1].version = build_info[0]
              #build_info[1].marketplace_url = eclipse_stream[1][:marketplace_url]
              #build_info[1].download_url = eclipse_stream[1][:download_url]
              build_info[1].eclipse_version = eclipse_version
              build_info[1].build_type = build_type
              
              unless stable_build_found then
                page_path_fragment = (build_type == :stable) ? "stable" : build_info[1].version.to_s
                download_page = generate_single_version_download_page(product_type, eclipse_version, 
                      page_path_fragment, build_info[1])
                @site.active_download_pages[product_type] << download_page 
                @site.pages << download_page 
                if build_type == :stable then
                  stable_build_found = true
                end
              end
              
              if build_type == :stable then
                page_path_fragment = build_info[1].version.to_s
                download_page = generate_single_version_download_page(product_type, eclipse_version, 
                      page_path_fragment, build_info[1])
                @site.pages << download_page 
                @site.all_download_pages[product_type] << download_page 
              end
            end
          end
          all_versions_page = generate_all_versions_downloads_page(product_type)
          @site.pages << all_versions_page
          @site.active_download_pages[product_type] << all_versions_page
        end
        $LOG.debug "*** Done with downloads extension." if $LOG.debug?
      end

      def generate_single_version_download_page(product, eclipse_version, page_path_fragment, build_info)
        page_subtitle ||= @site.products[product].name + " version " + build_info.version.to_s
        product_path_fragment = @site.products[product].url_path
        download_page = generate_download_page(:single_version, product_path_fragment, page_path_fragment)
        download_page.title = page_subtitle
        download_page.build_info = build_info
        download_page.product = product
        puts " generated download page at '" + download_page.output_path + "' with title '" + download_page.title + "'"
        download_page
      end

      def generate_all_versions_downloads_page(product)
        product_path_fragment = @site.products[product].url_path
        download_page = generate_download_page(:all_versions, product_path_fragment, @@download_page_metadata[:all_releases][:page_path_fragment])
        download_page.title = @@download_page_metadata[:all_releases][:page_title]
        download_page.product = product
        puts " generated download page at '" + download_page.output_path + "' with title '" + download_page.title + "'"
        download_page
      end
    
      def generate_download_page(layout_type, product_path_fragment, page_path_fragment)
        layout_path = @@layout_paths[layout_type]
        page = find_layout_page(layout_path)
        page.output_path = File.join( @@output_path_prefix + product_path_fragment + "/" + page_path_fragment + ".html" )
        @site.pages << page
        return page
      end
      
      def find_blog_announcement_page(blog_announcement_page_name)
        unless blog_announcement_page_name.nil? || blog_announcement_page_name.empty?
          #puts "Looking for post page matching '" + blog_announcement_page_name.to_s + "'"
          @site.posts.each do |post|
            #puts " " + post.simple_name
            if post.simple_name.eql? blog_announcement_page_name
              return post
            end
          end
          puts "Unable to find page for blog " + blog_announcement_page_name.to_s
        end
        return nil
      end
      
      def find_layout_page(simple_path)
        #puts "Looking for layout page:" + simple_path + " in " + @site.config.layouts_dir.to_s
        path_glob = File.join( @site.config.layouts_dir, simple_path)
        candidates = Dir[ path_glob ]
        return nil if candidates.empty?
        throw Exception.new( "too many choices for #{simple_path}" ) if candidates.size != 1
        #dir_pathname = Pathname.new( @site.config.dir )
        #path_name = Pathname.new( candidates[0] )
        #relative_path = path_name.relative_path_from( dir_pathname ).to_s
        @site.engine.load_page( candidates[0] )
        #puts " Found " + page.output_path.to_s
      end
    end

    
  end
  
end
