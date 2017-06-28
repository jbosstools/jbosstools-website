require 'products_helper'

require 'git'

module Awestruct
  module Extensions
    module WhatsnewHelper

      def last_commit_or_modifed_date (file)
        repo = Git.open('.')
        repo.log(1).object('./' + file).first.date
      end
      
      # returns the list of pages that will appear in the sidenavbar
      def get_active_whatsnew_pages(site, product_id, product_version) 
        site.whatsnew_pages[product_id].values.select{|p| !p.build_info.archived && (is_stable_version(p.build_info.version) || !exists_stable_version_whatsnew_page(site, p.build_info.product_id, p.build_info.version))}
      end
      
      # Returns the list of pages whose version match the given version (minus the qualifier)
      # want 4.4.x, not 4.4.x.y so use false
      def get_related_whatsnew_pages(site, product_id, product_version)
        main_version = get_main_version(product_version,false)
        site.whatsnew_pages[product_id].select{|version, p| (version.start_with? main_version) && (version != product_version)}
      end
      
      # want 4.4.x, not 4.4.x.y so use false
      def get_stable_version_whatsnew_page(site, product_id, product_version)
        main_version = get_main_version(product_version,false)
        final_version = main_version << ".Final"
        site.whatsnew_pages[product_id][final_version]
      end

      def get_current_version_whatsnew_page(site, product_id, product_version)
        site.whatsnew_pages[product_id][product_version]
      end
      
      def get_aggregate_whatsnew_page(site, product_id, product_version)
        aggregate_whatsnew_page = get_stable_version_whatsnew_page(site, product_id, product_version)
        if aggregate_whatsnew_page.nil?
          aggregate_whatsnew_page = get_current_version_whatsnew_page(site, product_id, product_version)
        end
        #puts "aggregate_whatsnew_page for #{product_id} #{product_version} found: #{!aggregate_whatsnew_page.nil?}"
        aggregate_whatsnew_page
      end
      
      def exists_stable_version_whatsnew_page(site, product_id, product_version)
        #puts " Checking if final version for #{product_id}.#{product_version} exists: #{!(get_stable_version_whatsnew_page(site, product_id, product_version).nil?)}"
        return !(get_stable_version_whatsnew_page(site, product_id, product_version).nil?)
      end
      
    end
  end
end

