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
        site.whatsnew_pages[product_id].values.select{|p| p.product_active == true && (is_stable_version(p.product_version) || !exists_stable_version_whatsnew_page(site, p.product_id, p.product_version))}
      end
      
      # Returns the list of pages whose version match the given version (minus the qualifier) 
      def get_related_whatsnew_pages(site, product_id, product_version)
        main_version = get_main_version(product_version)
        site.whatsnew_pages[product_id].select{|version, p| (version.start_with? main_version) && (version != product_version)}
      end
      
      def get_stable_version_whatsnew_page(site, product_id, product_version)
        main_version = get_main_version(product_version)
        final_version = main_version << ".Final"
        site.whatsnew_pages[product_id].values.select{|p| p.product_version == final_version}.first
      end

      def get_current_version_whatsnew_page(site, product_id, product_version)
        site.whatsnew_pages[product_id].values.select{|p| p.product_version == product_version}.first
      end
      
      def get_aggregate_whatsnew_page(site, product_id, product_version)
        if exists_stable_version_whatsnew_page(site, product_id, product_version)
          get_stable_version_whatsnew_page(site, product_id, product_version)
        else
          aggregated_whatsnew_page = get_current_version_whatsnew_page(site, product_id, product_version)
        end
      end
      
      def exists_stable_version_whatsnew_page(site, product_id, product_version)
        #puts " Checking if final version for #{product_id}.#{product_version} exists: #{!(get_stable_version_whatsnew_page(site, product_id, product_version).nil?)}"
        return !(get_stable_version_whatsnew_page(site, product_id, product_version).nil?)
      end
      
    end
  end
end

