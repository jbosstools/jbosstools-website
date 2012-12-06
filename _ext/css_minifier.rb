require 'cssminify'

##
#
# Awestruct::Extensions:CssMinifier is a transformer type of awestruct extension.
# If configured in project pipeline and site.yml, it will compress CSS files.
#
# Required installed gems:
# - cssminify
#
# Configuration:
#
# 1. configure the extension in the project pipeline.rb:
#    - add css_minifier dependency:
#
#      require 'css_minifier'
#
#    - put the extension initialization in the initialization itself:
#
#      transformer Awestruct::Extensions::CssMinifier.new
#
# 2. In your site.yml add:
#
#    css_minifier: enabled
#
#    This setting is optional and defaults to 'enabled', it's useful when using different configurations
#    for different runtime profiles.
#
##
module Awestruct
  module Extensions
    class CssMinifier

      def transform(site, page, input)

        # Checking if 'css_minifier' setting is provided and whether it's enabled.
        # By default, if it's not provided, we imply it's enabled.
        if !site.css_minifier.nil? && !site.css_minifier.to_s.eql?("enabled")
          return input
        end

        # Test if it's a CSS file.
        ext = File.extname(page.output_path)
        if !ext.empty?
          ext_txt = ext[1..-1]
          if ext_txt == "css"
            print "minifying css #{page.output_path} \n"
            input = CSSminify.compress(input)
          end
        end

        input
      end
    end
  end
end
