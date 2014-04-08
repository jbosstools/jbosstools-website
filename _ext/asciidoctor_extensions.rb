require 'asciidoctor'
require 'asciidoctor/extensions'
require 'asciidoctor/related_jira'
require 'asciidoctor/zoom_image'
include ::Asciidoctor

module Awestruct
  module Extensions
    class AsciidoctorExtensions
      
      def initialize()
        puts "Registering Asciidoctor extension(s)..."
        Asciidoctor::Extensions.register :jira do
          inline_macro JIRAInlineMacro
        end
        Asciidoctor::Extensions.register :related_jira do
          block_macro RelatedJIRABlockMacro
        end
        Asciidoctor::Extensions.register :lightbox_image do
          block_macro ZoomImageBlockMacro
        end
        
      end
      
      def execute(site)
      end
      
    end
    
    
  end
end
