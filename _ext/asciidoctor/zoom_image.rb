require 'asciidoctor'
require 'asciidoctor/extensions'
include ::Asciidoctor

module Awestruct
  module Extensions
    
    #
    # Renders a block with an image which can be click to display it full size in a bootstrap modal
    #
    # eg: lightbox_image::/path/to/image.png[optional title]
    #
    # See http://asciidoctor.org/docs/user-manual/#put-images-in-their-place
    #
    class ZoomImageBlockMacro < Asciidoctor::Extensions::BlockMacroProcessor
      use_dsl

      named :zoom_image
      parse_content_as :text

      
      def process parent, image_path, attrs
        img_id = image_path.gsub("/", "_").gsub("-", "_").gsub(".","_")
        # first, create image block with a link 
        attrs["target"] = image_path
        attrs["link"] = "##{img_id}"
        attrs["alt"] = attrs["text"]
        img_block_html = create_image_block(parent, attrs).render
        # need to insert the data-toggle="modal" attribute in the <a> element
        img_block_html = img_block_html.sub("<a", "<a data-toggle=\"modal\"")
        
        # then create the custom HTML block for the modal dialog, associated to the image above via 'img_id'
        attrs["link"] = nil # don't ask for surrounding link in next <img> block generation
        img_element_html = create_image_block(parent, attrs).render
        modal_dialog_html = %(
<div id="#{img_id}" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
<div class="modal-body center">
#{img_element_html}
<p>
#{attrs["alt"]}
<p>
</div>
<div class="modal-footer">
<button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
</div>
</div>)

        zoom_image_html_block = img_block_html << modal_dialog_html
        create_block parent, :pass, zoom_image_html_block, attrs
        
        
      end
    end
    
  end
end