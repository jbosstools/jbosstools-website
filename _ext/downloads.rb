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
        downloads = Hash.new
        page.families.each do |f|
          eclipse_version = page.eclipse_versions.select{|v| v.id == f.eclipse_requirement}.first
          for stream_type in [:jbds, :jbt_core, :jbt_is]
            stream = f.streams[stream_type]
            for build_type in [:releases, :development_builds, :nightly_builds]
              downloads[stream_type] = Hash.new if downloads[stream_type].nil?
              downloads[stream_type][build_type] = Array.new if downloads[stream_type][build_type].nil?
              build = generate_download_page(site, @layout_paths[stream_type], stream, 
                          stream[build_type], eclipse_version)
              downloads[stream_type][build_type] << build unless build.nil?
            end
          end
        end
        for stream_type in [:jbds, :jbt_core, :jbt_is]
          # move all but first release in :archives
          downloads[stream_type][:archives] = downloads[stream_type][:releases].drop(1)
          downloads[stream_type][:releases] = Array.[](downloads[stream_type][:releases].first)
          puts stream_type.to_s 
          puts " release: " + downloads[stream_type][:releases].to_s
          puts " archives: " + downloads[stream_type][:archives].to_s
        end
        puts "Downloads: " + downloads.to_s
        site.downloads = downloads
      end
      
      def generate_download_page(site, layout_path, stream, build, eclipse_version)
        unless build.nil?
          if build.is_a? Array
            build.each do |b|
              return generate_download_page(site, layout_path, stream, b, eclipse_version)
            end
          else
            page = find_layout_page(site, layout_path)
            page.output_path = File.join( @output_path_prefix + build.id + ".html" )
            page.title = stream.name + " " + build.version.to_s
            product = Product.new()
            product.build_id = build.id
            product.name = stream.name
            product.version = build.version
            product.release_date = build.release_date
            product.eclipse_version = eclipse_version
            blog_announcement_page = find_blog_announcement_page(site, build.blog_announcement)
            unless blog_announcement_page.nil?
              product.blog_announcement_url = blog_announcement_page.output_path
            end
            product.marketplace_install_url = build.marketplace_install_url
            product.marketplace_url = build.marketplace_url
            product.update_site_url = build.update_site_url
            product.zips= build.zips
            product.url = site.base_url + page.output_path
            page.product = product 

            site.pages << page
            puts "Generated " + page.output_path + " with title '" + page.title + "'"
            # puts " page product=" + page.product.to_s
            return product
          end
        end 
          
        return nil
      end
      
      def find_blog_announcement_page(site, blog_announcement_page_name)
        unless blog_announcement_page_name.nil?
          puts "Looking for post page matching '" + blog_announcement_page_name + "'"
          site.posts.each do |post|
            puts " " + post.simple_name
            if post.simple_name.eql? blog_announcement_page_name
              return post
            end
          end
          puts "Enable to find page for blog " + blog_announcement_page_name
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

    class Product < Awestruct::AStruct
      
    end

  end
  
end
