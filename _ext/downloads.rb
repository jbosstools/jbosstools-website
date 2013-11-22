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
        # look for the input page (relative_source_path should match something like '/downloads' as configured in pipeline.rb)
        site.pages.each do |page|
          if ( page.relative_source_path =~ /^#{@@index_path}/ )
            #puts "Running downloads extension on '" + page.to_s + "'"
            build_download_pages(page)
          end
        end
        $LOG.debug "*** Done executing downloads extension." if $LOG.debug?
      end

      def build_download_pages(page)
        @site.downloadable_builds = Hash.new
        # scan all families and generate arrays of 'downloadable products' for each stream
        @site.product_families.each do |product_family|
          eclipse_version = @site.eclipse_versions.select{|v| v.id == product_family.eclipse_requirement}.first
          for stream_type in [:jbds, :jbt_core, :jbt_is]
            for build_type in [:stable_releases, :development_builds, :nightly_builds]
              @site.downloadable_builds[stream_type] = Hash.new if @site.downloadable_builds[stream_type].nil?
              @site.downloadable_builds[stream_type][build_type] = Array.new if @site.downloadable_builds[stream_type][build_type].nil?
              unless product_family.streams[stream_type][build_type].nil?
                product_family.streams[stream_type][build_type].each do |build|
                  downloadable_build = generate_downloadable_build(build, product_family, stream_type, build_type, eclipse_version)
                  unless downloadable_build.nil?
                    @site.downloadable_builds[stream_type][build_type] << downloadable_build 
                    #puts "Downloadable build: " +  downloadable_build.to_s + " (" + build_type.to_s + ")"
                  end
                end
              end
            end
            # copy the lastest stable build in its own entry in the map. The single latest release is stored in an array, too
            @site.downloadable_builds[stream_type][:latest_release] = [@site.downloadable_builds[stream_type][:stable_releases].first] unless 
              (@site.downloadable_builds[stream_type][:stable_releases].nil? || @site.downloadable_builds[stream_type][:stable_releases].empty?)
            unless @site.downloadable_builds[stream_type][:latest_release].nil?
              @site.downloadable_builds[stream_type][:latest_release].first.type = :latest_release
            end
          end
        end
        # split current vs archived stable versions for each type of product
        # then, generate 1 download page per product
        # (each page will provide all downloadable versions at once).
        @site.download_pages = Hash.new
        for stream_type in [:jbds, :jbt_core, :jbt_is]
          @site.download_pages[stream_type] = []
          # generate a page for each dev/nightly build and the latest stable build, too.
          for build_type in [:latest_release, :development_builds, :nightly_builds]
            @site.download_pages[stream_type] << generate_single_version_download_pages(stream_type, build_type)
          end
          # generate a single long page for all stable (ie archives) versions
          @site.download_pages[stream_type] << generate_all_versions_downloads_page(stream_type)
          # flatten the array of download pages
          @site.download_pages[stream_type] = @site.download_pages[stream_type].flatten(2)
          puts "** generated pages for stream " + stream_type.to_s + " ** "
          @site.download_pages[stream_type].each do |page|
            puts " " + page.title + " -> " + page.output_path unless page.nil?
          end
        end
      end

      def generate_single_version_download_pages(stream_type, build_type)
        download_pages=[]
        @site.downloadable_builds[stream_type][build_type].each do |build|
          unless @@download_page_metadata[build.type].nil?
            page_path_fragment = @@download_page_metadata[build.type][:page_path_fragment] 
            page_subtitle = @@download_page_metadata[build.type][:page_title]
          end
          page_path_fragment ||= build.id
          page_subtitle ||= build.name + " version " + build.version.to_s
          download_page = generate_download_page(:single_version, stream_type, page_path_fragment)
          download_page.title = page_subtitle
          download_page.current_build = build
          download_pages << download_page
        end
        return download_pages
      end

      def generate_all_versions_downloads_page(stream_type)
        puts "Generating download page for all versions of " + stream_type.to_s 
        download_page = generate_download_page(:all_versions, stream_type, @@download_page_metadata[:all_releases][:page_path_fragment])
        download_page.stable_releases = @site.downloadable_builds[stream_type][:stable_releases]
        download_page.all_versions = @site.downloadable_builds[stream_type]
        download_page.title = @@download_page_metadata[:all_releases][:page_title]
        return download_page
      end
    
      def generate_download_page(layout_type, stream_type, page_path_fragment)
        layout_path = @@layout_paths[layout_type]
        page = find_layout_page(layout_path)
        page.stream_type = stream_type
        page.output_path = File.join( @@output_path_prefix + stream_type.to_s + "/" + page_path_fragment + ".html" )
        puts "  -> generated download page at " + page.output_path
        @site.pages << page
        return page
      end
      
      def generate_downloadable_build(build, product_family, stream_type, build_type, eclipse_version)
        puts "Generating downloadable build for " + stream_type.to_s + "/" + build_type.to_s + " using " + product_family.to_s
        product = Product.new(build, build_type, @site.products[stream_type], eclipse_version)
        blog_announcement_page = find_blog_announcement_page(build.blog_announcement)
        product.blog_announcement_url = blog_announcement_page.output_path unless blog_announcement_page.nil?
        return product
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

    class Product
      
      attr_accessor :id
      attr_accessor :name
      attr_accessor :type
      attr_accessor :stream_id
      attr_accessor :version
      attr_accessor :release_date
      attr_accessor :eclipse_version
      attr_accessor :marketplace_install_url
      attr_accessor :marketplace_url
      attr_accessor :update_site_url
      attr_accessor :zips
      attr_accessor :blog_announcement_url
      attr_accessor :output_path
      
      
      def initialize(build, build_type, stream, eclipse_version) 
        @id = build.id
        @name = stream.name
        @type = build_type
        @version = build.version
        @release_date = build.release_date.to_s unless build.release_date.nil?
        @eclipse_version = eclipse_version
        @marketplace_install_url = build.marketplace_install_url.to_s unless (build.marketplace_install_url.nil? || build.marketplace_install_url.empty?) 
        @marketplace_url = build.marketplace_url.to_s unless (build.marketplace_url.nil? || build.marketplace_url.empty?)
        @update_site_url = build.update_site_url.to_s unless (build.update_site_url.nil? || build.update_site_url.empty?)
        @zips= build.zips unless (build.zips.nil? || build.zips.empty?)
      end
      
      def to_s
        output = @id + " "
        output << "(" + @name +  ":" + @type.to_s + ")" 
        #output << "\n Marketplace: " + @marketplace_url unless @marketplace_url.nil?
        #output << "\n Updatesite: " + @update_site_url unless @update_site_url.nil?
        #output << "\n Zips: " + @zips.to_s unless @zips.nil?
        return output
      end 
      
    end

  end
  
end
