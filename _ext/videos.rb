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
    end
  end
end