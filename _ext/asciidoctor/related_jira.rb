require 'asciidoctor'
require 'asciidoctor/extensions'
include ::Asciidoctor

module Awestruct
  module Extensions
    
    #
    # Renders a block with one or more links to JIRA issues, prefixed with "Related JIRA:" or "Related JIRAs:"
    #
    # eg: related_jira::JBIDE-12345[]
    #
    # Note the use of a double colon ('::') after the 'related_jira' macro name.
    #
    class RelatedJIRABlockMacro < Asciidoctor::Extensions::BlockMacroProcessor
      use_dsl

      named :related_jira
      parse_content_as :text

      
      def process parent, target, attrs
        #puts "Processing JIRA extension with target #{target} and attrs #{attrs}..."
        # split the target if multipe JIRA were provided
        jira_ids = target.split(',')
        html = %(<p>Related JIRA#{(jira_ids.length > 1) ? 's' : ''}: )
        jira_links = Array.new
        jira_jbide_uri_pattern = 'https://issues.jboss.org/browse/%s'
        jira_ids.each do |jira_id|
          jira_jbide_uri = jira_jbide_uri_pattern % jira_id
          jira_links << %(<a href="#{jira_jbide_uri}">#{jira_id.upcase}</a>)
        end
        html << jira_links.join(", ")
        html << ".</p>"
        create_pass_block parent, html, attrs, subs: nil
      end
    end
    
    #
    # Renders a link to the JIRA issue 
    #
    # eg: jira:JBIDE-12345[]
    #
    # Note the use of a single colon (':') after the 'jira' macro name.
    #
    class JIRAInlineMacro < Asciidoctor::Extensions::InlineMacroProcessor
      use_dsl

      named :jira
      parse_content_as :text

      def process parent, target, attrs
        #puts "Processing JIRA extension with target #{target} and attrs #{attrs}..."
        jira_jbide_uri_pattern = 'https://issues.jboss.org/browse/%s'
        jira_jbide_uri = jira_jbide_uri_pattern % target
        (create_anchor parent, %(#{target.upcase}), type: :link, target: jira_jbide_uri).render
      end
    end
    
  end
end