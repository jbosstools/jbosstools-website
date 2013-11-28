module Awestruct
  module Extensions
    module DownloadsHelper

      def init_download_tab_states(build)
        output = ""
        unless build.nil?
          if build.marketplace_install_url.nil?
            output << "$('#marketplace_tab').addClass('disabled');\n"
            output << "$('#marketplace_tab>a').removeAttr('data-toggle');\n"
          end
          if build.update_site_url.nil?
            output << "$('#update_site_tab').addClass('disabled');\n"
            output << "$('#update_site_tab>a').removeAttr('data-toggle');\n"
          end
          if build.zips.nil?
            output << "$('#zips_tab').addClass('disabled');\n"
            output << "$('#zips_tab>a').removeAttr('data-toggle');\n"
          end
          output << "$('#installation_tabs li:not(.disabled):first>a').tab('show');\n"
        end
        return output
      end
      
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
