module Awestruct
  module Extensions
    module Products_Helper

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

      # checks if there's a a higher version of the same type for the product
      def has_higher_version(site, product_id, product_version, build_type)
        unless is_nightly_version(product_version) || is_unreleased_version(site, product_id, product_version)
          return get_higher_version(site, product_id, product_version, build_type) > product_version
        end
        false
      end
      module_function :has_higher_version

      # returns the higher version in the stream of the given product_id / product_version / build_type,
      # or nil if the given product_version is unknown (ie, the stream could not be found)
      def get_higher_version(site, product_id, product_version, build_type)
        main_version = get_main_version(product_version, false)
        site.products[product_id].streams.each do |stream_id, product_versions|
          # locate the stream: ie, it contains the given version
          if product_versions.include? product_version
            # sort versions by name (except nightly), retain higher one
            higher_product_version = product_versions.keys.
              select{|p| get_main_version(p, false) == main_version &&
                (get_build_type(site, product_id, p) == build_type || get_build_type(site, product_id, p) == :stable) &&
                !is_nightly_version(p) &&
                !product_versions[p].nil? &&
                !product_versions[p].release_date.nil?}.
              sort{|p1, p2| p1 <=> p2}.last
            puts " higher version for #{product_id}.#{product_version} (#{build_type}) is #{higher_product_version}"
            return higher_product_version
          end
        end
        #puts "higher version for #{product_id}/#{product_version} is unknown"
        nil
      end
      module_function :get_higher_version

      # Returns a build type based on the product version
      def get_build_type(site, product_id, product_version)
        if is_nightly_version(product_version)
          return :nightly
        elsif is_unreleased_version(site, product_id, product_version)
          return :unreleased
        elsif is_stable_version(product_version)
          return :stable
        else
          return :development
        end
      end
      module_function :get_build_type

      # Returns a build type label if provided in products.yml, or 'nil' if the product is archived or has a higher version
      # of the same type in the same stream
      def get_build_type_label(site, product_id, product_version, build_type, archived)
        if has_higher_version(site, product_id, product_version, build_type)
          build_type_label = nil
          puts "  No specific build type for #{product_id} #{product_version} since it is archived or outdated."
        else
          build_type_label = build_type
          puts "  Build type for #{product_id} #{product_version}: '#{build_type_label}'"
        end
        return build_type_label
      end
      module_function :get_build_type_label

      def is_unreleased_version(site, product_id, product_version)
        site.products[product_id].streams.each do |stream_id, product_versions|
          if (product_versions.include? product_version)
            #puts "Release date for #{product_version}: #{product_versions[product_version].release_date}" unless product_versions[product_version].nil?
            return false unless product_versions[product_version].nil? || product_versions[product_version].release_date.nil?
          end
        end
        true
      end
      module_function :is_unreleased_version

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

      # returns an 'info' structure for the given product id/version and the build_info found in products.yml
      def get_product_info(site, product_id, product_version)
        site.products[product_id][:streams].each do |eclipse_id, eclipse_stream|
          eclipse_version = site.products[:eclipse][eclipse_id]
          if eclipse_version.nil?
            raise "Eclipse version '#{eclipse_id}' referenced in stream not defined in products.yml"
          end
          # each Eclipse versions can have many product builds, each one with build info
          eclipse_stream.each do |build_version, build_info|
            if build_version == product_version
              return Products_Helper.get_build_info(site, product_id, build_version, eclipse_version, build_info)
            end
          end
        end
        # return a product info for an "unreleased/coming soon" product because it is unknown
        get_build_info(site, product_id, product_version, nil, nil)
      end
      module_function :get_product_info

      # returns an 'info' structure for the given product id/version and the build_info found in products.yml
      def get_build_info(site, product_id, product_version, eclipse_version, build_info)
        info = OpenStruct.new
        info.name = site.products[product_id].name
        info.product_id = product_id
        info.product_name = site.products[product_id].name
        info.version = product_version
        info.archived = (build_info[:archived] unless build_info.nil?) || false
        info.release_date = build_info["release_date"] unless (build_info.nil? || !build_info.has_key?("release_date"))
        #puts " Release date: #{info.version}: #{info.release_date}"
        info.renamed_as = build_info["renamed_as"] unless build_info.nil?
        info.eclipse_version = eclipse_version
        info.build_type = get_build_type(site, product_id, product_version)
        info.build_type_label = get_build_type_label(site, product_id, product_version, info.build_type, info.archived)
        info.blog_announcement_url = build_info["blog_announcement_url"] unless build_info.nil?
        info.release_notes_url = build_info["release_notes_url"] unless build_info.nil?
        #info.supported_jbt_is_version = build_info["supported_jbt_is_version"] unless build_info.nil?
        info.required_jbt_core_version = build_info["required_jbt_core_version"] unless build_info.nil?
        info.required_devstudio_version = build_info["required_devstudio_version"] unless build_info.nil?
        #info.supported_devstudio_is_version = build_info["supported_devstudio_is_version"] unless build_info.nil?
        unless site.whatsnew_pages[product_id].nil? || site.whatsnew_pages[product_id][product_version].nil? then
          info.whatsnew_url = site.whatsnew_pages[product_id][product_version].output_path
        end
        info.installers = build_info["installers"] unless build_info.nil?
        info.update_site_url = build_info["update_site_url"] unless build_info.nil?
        info.marketplace_url = build_info["marketplace_url"] unless build_info.nil?
        info.marketplace_install_url = build_info["marketplace_install_url"] unless build_info.nil?
        info.zips = build_info["zips"] unless build_info.nil?
        #info.archived = build_info["archived"] unless build_info.nil?
        return info
      end
      module_function :get_build_info

    end
  end
end
