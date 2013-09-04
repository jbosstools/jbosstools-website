require 'pathname'

# workaround for relative() until https://github.com/awestruct/awestruct/pull/318 is incorporated
# + support for passing relative paths through and allow for root being a different dir by using relative("images/test.png", "/features")
module Awestruct
  module Extensions
    module Relative

      def relative(href, root = nil, p = page)
        begin
          result = href
          root = root.nil? ? p.output_path : root

          # Ignore absolute links
          if href.start_with?("http://") || href.start_with?("https://")
            result = href
          elsif href.start_with?("/")
            result = Pathname.new(href).relative_path_from(Pathname.new(File.dirname(root))).to_s
          end
          #puts "relative(#{href},#{p.output_path})=>#{result}"
          result
        rescue Exception => e
          $LOG.error "#{e}" if $LOG.error?
          $LOG.error "#{e.backtrace.join("\n")}" if $LOG.error?
        end
      end

    end
  end
end
