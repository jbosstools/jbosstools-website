module Awestruct
  module Extensions
    module WhatsnewHelper
      
      def get_main_version(version)
        version.split(".")[0..2].join('.')
      end
      module_function :get_main_version
      
      # Returns the list of pages whose version match the given version (minus the qualifier) 
      def get_related_whatsnew_pages(site, product_id, product_version)
        main_version = get_main_version(product_version)
        puts "Looking for whatsnew pages related with #{product_id}.#{product_version}..."
        result = site.whatsnew_pages[product_id].select{|version, p| (version.start_with? main_version) && (version != product_version)}
        puts " found #{result.length} pages"
        result
      end
      
      def get_final_version_whatsnew_page(site, product_id, product_version)
        main_version = get_main_version(product_version)
        final_version = main_version << ".Final"
        site.whatsnew_pages[product_id].values.select{|p| p.product_version == final_version}.first
      end

      def exists_final_version(site, product_id, product_version)
        #puts " Checking if final version for #{product_id}.#{product_version} exists: #{!(get_final_version_whatsnew_page(site, product_id, product_version).nil?)}"
        return !(get_final_version_whatsnew_page(site, product_id, product_version).nil?)
      end
      
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
      
      def is_final_version(product_version)
        product_version.end_with? ".Final"  
      end
      module_function :is_final_version
    end
  end
end

