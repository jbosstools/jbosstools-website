require 'uglifier'

##
#
# Awestruct::Extensions:JsMinifier is a transformer type of awestruct extension.
# If configured in project pipeline and site.yml, it will compress javascript files.
#
# Required installed gems:
# - uglifier (this has a runtime dependency on execjs)
# - therubyracer
#
# Configuration:
#
# 1. configure the extension in the project pipeline.rb:
#    - add js_minifier dependency:
#
#      require 'js_minifier'
#
#    - put the extension initialization in the initialization itself:
#
#      transformer Awestruct::Extensions::JsMinifier.new
#
# 2. In your site.yml add:
#
#    js_minifier: enabled
#
#    This setting is optional and defaults to 'enabled', it's useful when using different configurations
#    for different runtime profiles.
#
##
module Awestruct
  module Extensions
    class JsMinifier

      def transform(site, page, input)

        # Checking if 'js_minifier' setting is provided and whether it's enabled.
        # By default, if it's not provided, we imply it's enabled.
        if !site.js_minifier.nil? && !site.js_minifier.to_s.eql?("enabled")
          return input
        end

        # Test if it's a javascript file.
        ext = File.extname(page.output_path)
        if !ext.empty?
          ext_txt = ext[1..-1]
          if ext_txt == "js"
            print "minifying javascript #{page.output_path} \n"
            input = Uglifier.new.compile(input)
          end
        end

        input
      end
    end
  end
end
