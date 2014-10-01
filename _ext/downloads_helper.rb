module Awestruct
  module Extensions
    module DownloadsHelper

      def init_all_download_tabs_states(downloadable_builds)
        output = ""
        downloadable_builds.each do |type,builds|  
          builds.each do |build|
            $LOG.debug "*** Generating JS script for download tabs states of " + build.to_s if $LOG.debug?
            output << init_download_tab_states(build)
          end
        end
        return output
      end
      
    end
  end
end
