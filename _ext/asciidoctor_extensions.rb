require 'asciidoctor'
require 'asciidoctor/extensions'
require 'asciidoctor/related_jira'
include ::Asciidoctor

module Awestruct
  module Extensions
    class AsciidoctorExtensions
      
      def initialize()
        puts "Registering Asciidoctor extension(s)..."
        Asciidoctor::Extensions.register :jira do
          block_macro RelatedJIRABlockMacro
          inline_macro RelatedJIRAInlineMacro
        end
      end
      
      def execute(site)
      end
      
    end
    
    
  end
end
