##
#
# Awestruct::Extensions:FontPath is a classic type of awestruct extension.
# If configured in project pipeline and site.yml, it will configure the Compass http_fonts_path property based on a site property.
#
# Configuration:
#
# 1. configure the extension in the project pipeline.rb:
#    - add font_path dependency:
#
#      require 'font_path'
#
#    - put the extension initialization in the initialization itself:
#
#      extension Awestruct::Extensions::FontPath.new
#
# 2. This is an example site.yml configuration:
#
#    fonts_url: http://static.jboss.org/theme/fonts
#
##
module Awestruct
  module Extensions
    class FontPath

      def execute(site)
        if !site.theme_fonts_url.nil?
          Compass.configuration.http_fonts_path = site.theme_fonts_url
        end
      end
			
    end
  end
end
