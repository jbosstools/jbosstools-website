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
        nil
      end
      module_function :get_higher_version
      
      # Returns a build type based on the given version 
      def get_build_type(site, product_id, product_version)
        if is_stable_version(product_version)
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
        build_type_label = nil
        unless stream.nil?
          info = stream.select{|build_version, build_info| build_version == product_version}.values.first
          build_type_label = info[:build_type] unless (info[:archived] == true)
          #puts "  #{product_id} #{product_version} build type: '#{build_type_label}'"
        end
        return build_type_label
      end
      module_function :get_build_type_label
     
      def get_stable_version(site, product_id, product_version)
        final_version = get_main_version(product_version) << ".Final"
        ga_version = get_main_version(product_version) << ".GA"
        site.products[product_id].streams.each do |stream_id, product_versions|
          if product_versions.include? final_version 
            return final_version
          elsif product_versions.include? ga_version
            return ga_version
          end
        end
        nil
      end
      module_function :get_stable_version
            
      def is_stable_version(product_version)
        (product_version.end_with? ".Final") || (product_version.end_with? ".GA")
      end
      module_function :is_stable_version
      
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
              product_archived = stream_versions[product_version][:archived] ||= false unless is_stable_version(product_version)
              #puts " #{product_id} #{product_version} active: #{!product_archived}"
              return !product_archived
            end
          end
        end
        #puts "  #{product_id} #{product_version} is not defined in products.yml - N&N content is considered as *active*"
        return true
      end
      module_function :is_product_version_active
      
      # returns an 'info' structure for the given product id/version and the build_info found in products.yml
      def get_product_info(site, product_id, product_version) 
        site.products[product_id][:streams].each do |eclipse_id, eclipse_stream|
          eclipse_version = site.products[:eclipse][eclipse_id]
          if eclipse_version.nil?
            raise "Eclipse version '#{eclipse_id}' referenced in stream not defined in products.yml"
          end
          # for each Eclipse versions can have many product builds, each one with build info
          eclipse_stream.each do |build_version, build_info|
            if build_version == product_version
              return ProductsHelper.get_build_info(site, product_id, build_version, eclipse_version, build_info)
            end
          end
        end
        nil
      end
      module_function :get_product_info
      
      # returns an 'info' structure for the given product id/version and the build_info found in products.yml
      def get_build_info(site, product_id, product_version, eclipse_version, build_info) 
        info = OpenStruct.new
        info.name = site.products[product_id].name
        info.product_id = product_id
        info.version = product_version
        info.release_date = build_info["release_date"]
        info.eclipse_version = eclipse_version
        info.build_type = get_build_type(site, product_id, product_version) 
        info.build_type_label = get_build_type_label(site, product_id, product_version) 
        info.blog_announcement_url = build_info["blog_announcement_url"]
        info.release_notes_url = build_info["release_notes_url"]
        #info.supported_jbt_is_version = build_info["supported_jbt_is_version"]
        info.required_jbt_core_version = build_info["required_jbt_core_version"]
        info.required_devstudio_version = build_info["required_devstudio_version"]
        #info.supported_devstudio_is_version = build_info["supported_devstudio_is_version"]
        unless site.whatsnew_pages[product_id].nil? || site.whatsnew_pages[product_id][product_version].nil? then
          info.whatsnew_url = site.whatsnew_pages[product_id][product_version].output_path
        end
        info.installers = build_info["installers"]
        info.update_site_url = build_info["update_site_url"]
        info.marketplace_install_url = build_info["marketplace_install_url"]
        info.zips = build_info["zips"]
        info.archived = build_info["archived"] || false
        return info
      end
      module_function :get_build_info
      
    end
  end
end