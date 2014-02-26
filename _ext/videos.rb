require 'uri_helper'

module Awestruct
  module Extensions
    class Videos

      def initialize(path_prefix)
        @path_prefix = path_prefix
      end

      def execute(site)
        site.videos = Hash.new
        $LOG.debug "*** Executing videos extension...." if $LOG.debug?
        site.pages.each do |page|
          if page.relative_source_path =~ /^#{@path_prefix}\/.*\.adoc/ then
            $LOG.debug " Processing video " + page.title if $LOG.debug?
            site.videos[page.category] = Array.new if site.videos[page.category].nil?
            site.videos[page.category] << page
          end
        end
        $LOG.debug "*** Done executing videos extension...." if $LOG.debug?
      end
      
      def create_page(site, layout_path, path)
        path_glob = File.join( site.config.layouts_dir, layout_path)
        candidates = Dir[ path_glob ]
        return nil if candidates.empty?
        throw Exception.new( "too many choices for #{simple_path}" ) if candidates.size != 1
        page = site.engine.load_page( candidates[0] )
        page.output_path = path
        site.pages << page
        site.engine.set_urls([page])
        return page
      end
      
    end
  end
end