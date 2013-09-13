module Awestruct
  module Extensions
    module DownloadsHelper

      def init_download_tab_states(stream_type)
        labels = {:stable_releases=>"Lastest Stable Release", :development_builds=>"Development Milestones", :nightly_builds=>"Nightly Builds", :archives=>"Archives"}
        output = "$('#downloadable_versions_tabs a:first').tab('show');\n"
        labels.each_key do |key|
          unless site.downloadable_builds[stream_type][key].empty?
            site.downloadable_builds[stream_type][key].each do |build|
              if build.marketplace_install_url.nil?
                output << "$('#" + build.id + "_marketplace_tab').addClass('disabled');\n"
                output << "$('#" + build.id + "_marketplace_tab>a').removeAttr('data-toggle');\n"
              end
              if build.update_site_url.nil?
                output << "$('#" + build.id + "_update_site_tab').addClass('disabled');\n"
                output << "$('#" + build.id + "_update_site_tab>a').removeAttr('data-toggle');\n"
              end
              if build.zips.nil?
                output << "$('#" + build.id + "_zips_tab').addClass('disabled');\n"
                output << "$('#" + build.id + "_zips_tab>a').removeAttr('data-toggle');\n"
              end
              output << "$('#" + build.id + "_tabs li:not(.disabled):first>a').tab('show');\n"
              
            end
          end
        end
        puts output
        return output
      end
    end
  end
end
