module Awestruct
  module Extensions
    module DownloadsHelper

      def init_download_btn_states()
        labels = {:releases=>"Lastest Stable Release", :development_builds=>"Development Milestones", :nightly_builds=>"Nightly Builds", :archives=>"Archives"}
        output = ""
        labels.each_key do |key|
          unless site.downloadable_builds[:jbt_core][key].empty?
            site.downloadable_builds[:jbt_core][key].each do |build|
              if build.marketplace_install_url?
                output << "$('" + build.id + "_marketplace').addClass('active');\n"
              else
                output << "$('" + build.id + "_marketplace').addClass('disabled');\n"
              end
              if build.update_site_url?
              end
              if build.zips? && !build.zips.empty?
              end
            end
          end
        end
        puts output
        return output
      end
    end
  end
end
