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
      # want: Final builds (even if archived) + pre-Final builds if no Final for that stream (eg., 4.5.0.AM1)
      def get_active_whatsnew_pages(site, product_id, product_version)
        # puts " current page: #{product_id} :: #{product_version}"
        site.whatsnew_pages[product_id].values.select{|p| (!p.build_info.archived || ((!product_version.end_with? ".Final") && (!product_version.end_with? ".GA")) || (p.build_info.version.end_with? ".Final") || (p.build_info.version.end_with? ".GA")) && (is_stable_version(p.build_info.version) || !exists_stable_version_whatsnew_page(site, p.build_info.product_id, p.build_info.version))}
      end
      
      # Returns the list of pages whose version match the given version (minus the qualifier)
      # want 4.4.x, not 4.4.x.y so use false
      # if page is archived, only show its pre-Final versions (4.4.1.x)
      # if page is NOT archived, show its pre-Final and earlier Final versions (4.4.4.x, 4.4.3.x, 4.4.2.x, 4.4.1.x, 4.4.0.x)
      def get_related_whatsnew_pages(site, product_id, product_version, includeService)
        main_version = get_main_version(product_version, includeService)
        site.whatsnew_pages[product_id].select{|version, p| (version.start_with? main_version) && (version != product_version)}
      end
      
      # false: want 4.4.x, not 4.4.x.y
      # true: want 4.4.x.y
      def get_stable_version_whatsnew_page(site, product_id, product_version)
        main_version = get_main_version(product_version, true)
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
        puts " Checking if final version for #{product_id}.#{product_version} exists: #{!(get_stable_version_whatsnew_page(site, product_id, product_version).nil?)}"
        return !(get_stable_version_whatsnew_page(site, product_id, product_version).nil?)
      end
      
    end
  end
end

