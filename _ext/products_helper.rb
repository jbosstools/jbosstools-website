module Awestruct
  module Extensions
    module ProductsHelper
      
      def get_main_version(version, include_revision = true)
        if include_revision
          identifiers = version.split(".")[0..2]
        else 
          identifiers = version.split(".")[0..1]
        end
        #puts " main version: #{identifiers}"
        identifiers.join('.')
      end
      module_function :get_main_version
      
      # checks if there's a .Final version matching the given product_version of the given product_id
      def has_higher_version(site, product_id, product_version)
        unless is_nightly_version(product_version)
          return get_higher_version(site, product_id, product_version) > product_version
        end
        false
      end
      module_function :has_higher_version
     
      def get_higher_version(site, product_id, product_version) 
        main_version = get_main_version(product_version, false)
        site.products[product_id].streams.each do |stream_id, product_versions|
          # locate the stream: ie, it contains the given version
          if product_versions.include? product_version
            # sort versions by name (except nightly), retain higher one
            higher_product_version = product_versions.keys.select{|p| get_main_version(p, false) == main_version && !is_nightly_version(p)}.sort{|p1, p2| p1 <=> p2}.last
            #puts " higher version for #{product_id} #{product_version} is #{higher_product_version}"
            return higher_product_version
          end
        end
        puts "   Final version for #{product_id} (#{version}): #{final_version} does not exist yet."
        nil
      end
      module_function :get_higher_version
      
      # Returns a build type based on the given version 
      def get_build_type(site, product_id, product_version)
        if is_final_version(product_version)
          return :stable
        elsif is_nightly_version(product_version)
          return :nightly
        else
          return :development
        end
      end
      module_function :get_build_type
      
      # Returns a build type label if provided in product.yml, nil otherwise
      def get_build_type_label(site, product_id, product_version)
        stream = site.products[product_id].streams.select{|stream_id, versions| versions[product_version] != nil}.values.first
        unless stream.nil?
          build_type_label = stream.select{|build_version, build_info| build_version == product_version}.values.first[:build_type]
          #puts "  #{product_id} #{product_version} build type: '#{build_type}'"
          return build_type_label
        end
        return nil
      end
      module_function :get_build_type_label
     
      def get_final_version(site, product_id, product_version)
        main_version = get_main_version(product_version)
        final_version = main_version << ".Final"
        site.products[product_id].streams.each do |stream_id, product_versions|
          if product_versions.include? final_version
            return final_version
          end
        end
        nil
      end
      module_function :get_final_version
            
      def is_final_version(product_version)
        product_version.end_with? ".Final"  
      end
      module_function :is_final_version
      
      def is_nightly_version(product_version)
        product_version.end_with? ".Nightly"  
      end
      module_function :is_nightly_version
      
      # returns true if the given product_id/product_version has no "archived: true" attribute or if it is a .Final version (even archived)
      def is_product_version_active(site, product_id, product_version)
        unless site.products[product_id].nil? then
          site.products[product_id].streams.each do |stream_id, stream_versions|
            unless stream_versions[product_version].nil? then
              product_archived = false
              # final versions are not considered archived
              product_archived = stream_versions[product_version][:archived] ||= false unless is_final_version(product_version)
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