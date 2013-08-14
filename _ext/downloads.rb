module Awestruct
  module Extensions
    class Downloads

      def initialize(path, input_path, output_path_prefix)
        @path = path
        @input_path = input_path
        @output_path_prefix = output_path_prefix
      end

      def execute(site)
        # look for the input page
        site.pages.each do |page|
          if ( page.relative_source_path =~ /^#{@path}/ )
            puts "found matching page: " + page.relative_source_path    
            stable_jbds_page = generate_download_page(site, page.jbds_streams.first.stable_releases.versions.first)
            page.stable_jbds = stable_jbds_page.output_path 
            stable_jbt_page = generate_download_page(site, page.jbt_streams.first.stable_releases.versions.first)
            page.stable_jbt = stable_jbt_page.output_path 
          end
        end
      end

      def generate_download_page(site, version)
        page = site.engine.find_and_load_site_page( @input_path )
        page.output_path = File.join( @output_path_prefix + "-" + version.id + ".html" )
        page.product_name = version.name
        site.pages << page
        puts "Generated " + page.output_path
        page
      end
    end
  end
end
