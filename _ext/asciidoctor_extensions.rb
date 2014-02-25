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
          inline_macro JIRAInlineMacro
        end
        Asciidoctor::Extensions.register :related_jira do
          block_macro RelatedJIRABlockMacro
        end
      end
      
      def execute(site)
      end
      
    end
    
    
  end
end
