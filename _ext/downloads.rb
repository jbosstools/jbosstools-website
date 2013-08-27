require 'awestruct/astruct'

module Awestruct
  module Extensions
    class Downloads

      def initialize(path, input_path, output_path_prefix)
        @path = path
        @input_path = input_path
        @output_path_prefix = output_path_prefix
      end

      def execute(site)
        @site = site
        # look for the input page
        site.pages.each do |page|
          if ( page.relative_source_path =~ /^#{@path}/ )
            jbds_family = page.jbds_families.select{|f| f.stable_releases?}.first
            jbt_family = page.jbt_families.select{|f| f.stable_releases?}.first
            stable_jbds_page = generate_stable_download_page(jbds_family, page.eclipse_versions)
            page.stable_jbds = stable_jbds_page.output_path
            stable_jbt_page = generate_stable_download_page(jbt_family, page.eclipse_versions)
            page.stable_jbt = stable_jbt_page.output_path
            stable_jbt_page.dev_pages = []
            page.jbt_families.each do |family|
              if family.development_builds?
                family.development_builds.each do |build|
                  dev_page = generate_development_build_download_page(build, family, page.eclipse_versions)
                  stable_jbt_page.dev_pages << dev_page.output_path
                end
              end
            end
            puts stable_jbt_page.output_path + " dev=" + stable_jbt_page.dev_pages.to_s
          end
        end
      end

      def generate_stable_download_page(family, eclipse_versions)
        build = family.stable_releases.first
        page = find_layout_page( @input_path )
        page.output_path = File.join( @output_path_prefix + "_" + build.id + ".html" )
        page.title = family.name + " " + build.version.to_s
        product = Product.new()
        product.name = family.name
        product.version = build.version
        product.status = "stable_build"
        product.release_date = build.release_date
        product.eclipse_version = eclipse_versions.select{|v| v.id == family.eclipse_requirement}.first
        blog_page = find_blog_announcement_page(build.blog_announcement)
        unless blog_page.nil?
          product.blog_announcement_url = blog_page.output_path
        end
        product.marketplace_install_url = family.marketplace_install_url
        product.marketplace_url = family.marketplace_url
        product.update_site_url = family.update_site_url
        product.zips= build.zips
        page.product = product 

        @site.pages << page
        puts "Generated " + page.output_path + " with title '" + page.title + "'"
        # puts " page product=" + page.product.to_s
        page
      end
      
      def find_blog_announcement_page(page_name)
        unless page_name.nil?
          puts "Looking for post page matching '" + page_name + "'"
          @site.posts.each do |post|
            puts " " + post.simple_name
            if post.simple_name.eql? page_name
              return post
            end
          end
          puts "Enable to find page for blog " + page_name
        end
        return nil
      end
      
      def generate_development_build_download_page(build, family, eclipse_versions)
        page = find_layout_page( @input_path )
        page.output_path = File.join( @output_path_prefix + "_" + family.id + "_dev.html" )
        product = Product.new()
        product.name = family.name
        product.status = "development_build"
        product.eclipse_version = eclipse_versions.select{|v| v.id == family.eclipse_requirement}.first
        product.zips= []
        page.product = product 
        @site.pages << page
        puts "Generated " + page.output_path
        # puts " page product=" + page.product.to_s
        page
      end
      
      def generate_nightly_build_download_page(version)
        page = find_layout_page( @input_path )
        page.output_path = File.join( @output_path_prefix + version.id + "_nightly.html" )
        product = Product.new()
        product.name = version.name
        product.status = "nightly_build"
        product.zips= []
        page.product = product 
        @site.pages << page
        puts "Generated " + page.output_path
        # puts " page product=" + page.product.to_s
        page.output_path
      end
      
      def find_layout_page(simple_path)
        # puts "Looking for layout page:" + simple_path + " in " + @site.config.layouts_dir.to_s
        path_glob = File.join( @site.config.layouts_dir, simple_path)
        candidates = Dir[ path_glob ]
        return nil if candidates.empty?
        throw Exception.new( "too many choices for #{simple_path}" ) if candidates.size != 1
        dir_pathname = Pathname.new( @site.config.dir )
        path_name = Pathname.new( candidates[0] )
        relative_path = path_name.relative_path_from( dir_pathname ).to_s
        @site.engine.load_page( candidates[0] )
        #puts " Found " + page.output_path.to_s
      end
    end

    class Product < Awestruct::AStruct
      
    end

  end
  
end
