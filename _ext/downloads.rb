require 'awestruct/astruct'

module Awestruct
  module Extensions
    class Downloads

      def initialize(index_path, output_path_prefix, layout_paths)
        @index_path = index_path
        @output_path_prefix = output_path_prefix
        @layout_paths = layout_paths
      end

      # generates synthetic pages for all downloadable versions of JBDS and JBT (stable, dev, nightly and older)
      def execute(site)
        # look for the input page (relative_source_path should match something like '/downloads' as configured in pipeline.rb)
        site.pages.each do |page|
          if ( page.relative_source_path =~ /^#{@index_path}/ )
            build_download_pages(site, page)
          end
        end
      end

      def build_download_pages(site, page)
        downloadable_builds = Hash.new
        # scan all families and generate arrays of 'downloadable products' for each stream
        site.product_families.each do |f|
          eclipse_version = site.eclipse_versions.select{|v| v.id == f.eclipse_requirement}.first
          for stream_type in [:jbds, :jbt_core, :jbt_is]
            stream = f.streams[stream_type]
            stream_name = site.products[stream_type].name
            for build_type in [:stable_releases, :development_builds, :nightly_builds]
              downloadable_builds[stream_type] = Hash.new if downloadable_builds[stream_type].nil?
              downloadable_builds[stream_type][build_type] = Array.new if downloadable_builds[stream_type][build_type].nil?
              downloadable_build = generate_downloadable_build(site, stream_name, stream[build_type], eclipse_version)
              unless downloadable_build.nil?
                downloadable_builds[stream_type][build_type] << downloadable_build 
                puts "Downloadable build: " +  downloadable_build.to_s
              end
            end
          end
        end
        # split current vs archived stable versions for each type of product
        # then, generate 1 download page per product
        # (each page will provide all downloadable versions at once).
        site.downloads_pages = Hash.new
        for stream_type in [:jbds, :jbt_core, :jbt_is]
          downloadable_builds[stream_type][:archives] = downloadable_builds[stream_type][:stable_releases].drop(1)
          downloadable_builds[stream_type][:stable_releases] = Array.[](downloadable_builds[stream_type][:stable_releases].first)
          download_page = generate_download_page(site, stream_type)
          site.pages << download_page unless download_page.nil?
          site.downloads_pages[stream_type] = download_page unless download_page.nil?
        end
        site.downloadable_builds = downloadable_builds
      end

      def generate_download_page(site, stream_type)
        product_name = site.products[stream_type].name
        layout_path = @layout_paths[stream_type]
        page = find_layout_page(site, layout_path)
        page.stream_type = stream_type
        page.output_path = File.join( @output_path_prefix + stream_type.to_s + ".html" )
        page.title = product_name
        puts "Generated download page " + page.title + " at " + page.output_path
        return page
      end
      
      def generate_downloadable_build(site, stream_name, build, eclipse_version)
        unless build.nil?
          if build.is_a? Array
            build.each do |b|
              return generate_downloadable_build(site, stream_name, b, eclipse_version)
            end
          else
            product = Product.new(build, stream_name, eclipse_version)
            blog_announcement_page = find_blog_announcement_page(site, build.blog_announcement)
            product.blog_announcement_url = blog_announcement_page.output_path unless blog_announcement_page.nil?
            return product
          end
        end 
          
        return nil
      end
      
      def find_blog_announcement_page(site, blog_announcement_page_name)
        unless blog_announcement_page_name.nil? || blog_announcement_page_name.empty?
          puts "Looking for post page matching '" + blog_announcement_page_name.to_s + "'"
          site.posts.each do |post|
            puts " " + post.simple_name
            if post.simple_name.eql? blog_announcement_page_name
              return post
            end
          end
          puts "Enable to find page for blog " + blog_announcement_page_name.to_s
        end
        return nil
      end
      
      def find_layout_page(site, simple_path)
        # puts "Looking for layout page:" + simple_path + " in " + @site.config.layouts_dir.to_s
        path_glob = File.join( site.config.layouts_dir, simple_path)
        candidates = Dir[ path_glob ]
        return nil if candidates.empty?
        throw Exception.new( "too many choices for #{simple_path}" ) if candidates.size != 1
        dir_pathname = Pathname.new( site.config.dir )
        path_name = Pathname.new( candidates[0] )
        relative_path = path_name.relative_path_from( dir_pathname ).to_s
        site.engine.load_page( candidates[0] )
        #puts " Found " + page.output_path.to_s
      end
    end

    class Product
      
      attr_accessor :id
      attr_accessor :name
      attr_accessor :version
      attr_accessor :release_date
      attr_accessor :eclipse_version
      attr_accessor :marketplace_install_url
      attr_accessor :marketplace_url
      attr_accessor :update_site_url
      attr_accessor :zips
      attr_accessor :blog_announcement_url
      
      def initialize(build, stream_name, eclipse_version) 
        @id = build.id
        @name = stream_name.to_s
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
        output << "(" + @name + ")" unless @name.nil?
        output << "\n Marketplace: " + @marketplace_url unless @marketplace_url.nil?
        output << "\n Updatesite: " + @update_site_url unless @update_site_url.nil?
        output << "\n Zips: " + @zips.to_s unless @zips.nil?
        return output
      end 
      
    end

  end
  
end
