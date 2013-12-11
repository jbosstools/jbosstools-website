module Awestruct
  module Extensions
    module URIHelper
   
      # concatenates all given elements to the base, by adding a '/' inbetween if none exists. 
      def self.concat(base, *elements)
        result = String.new(base)
        elements.each do |element|
          result = result + ((result.end_with?('/') || element.start_with?('/')) ? "" : "/") + element
        end
        return result
      end   
      
      def join(base, *elements)
        URIHelper.concat(base, *elements)
      end
    end
  end
end
