module Awestruct
  module Extensions
    module Events
      class Index
        
        def initialize(path_prefix)
          @path_prefix = path_prefix
        end

        def execute(site)
          @site = site
          $LOG.debug "*** Executing events extension...." if $LOG.debug?
          site.events = Array.new
          site.pages.each do |page|
            if page.relative_source_path =~ /^#{@path_prefix}\/.*\.adoc/ ||
               page.relative_source_path =~ /^#{@path_prefix}\/.*\.md/ then
               site.events << page
            end
          end
        end
      end
    end
  end
end