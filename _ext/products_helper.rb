module Awestruct
  module Extensions
    module ProductsHelper
      
      def get_main_version(version)
        version.split(".")[0..2].join('.')
      end
      module_function :get_main_version
      
      def get_final_version(site, product_id, version) 
        main_version = get_main_version(version)
        final_version = main_version << ".Final"
        site.products[product_id].streams.each do |stream_id, product_versions|
          if product_versions.include? final_version
            return final_version
          end
        end
        #puts "   Final version for #{product_id} (#{version}): #{final_version} does not exist yet."
        nil
      end
      module_function :get_final_version
      
      def get_build_type(site, product_id, product_version)
        stream = site.products[product_id].streams.select{|stream_id, versions| versions[product_version] != nil}.values.first
        unless stream.nil?
          build_type = stream.select{|build_version, build_info| build_version == product_version}.values.first[:build_type]
          #puts "  #{product_id} #{product_version} build type: '#{build_type}'"
          return build_type
        end
        return nil
      end
      module_function :get_build_type
     
      def is_final_version(product_version)
        product_version.end_with? ".Final"  
      end
      module_function :is_final_version
      
      def is_product_version_active(site, product_id, product_version)
        unless site.products[product_id].nil? then
          site.products[product_id].streams.each do |stream_id, stream_versions|
            unless stream_versions[product_version].nil? then
              product_archived = stream_versions[product_version][:archived] ||= false
              #puts " #{product_id} #{product_version} active: #{!product_archived}"
              return !product_archived
            end
          end
        end
        #puts "  #{product_id} #{product_version} is not defined in products.yml - N&N content is considered as *active*"
        return true
      end
      module_function :is_product_version_active
      
    end
  end
end