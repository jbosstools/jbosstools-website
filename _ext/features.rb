require 'uri_helper'

module Awestruct
  module Extensions
    Change = Struct.new(:sha, :author, :date, :message)
    class Features

      
      @@transformers_registered = false
      
      def initialize(path_prefix, opts={})
        @path_prefix = path_prefix.end_with?('/') ? path_prefix.chop : path_prefix
        #@imagesdir = opts[:imagesdir] || '/images'
        $LOG.debug "*** Initialized Feature extension with path_prefix=" + @path_prefix if $LOG.debug?
      end

      # transform gets called twice in the process of loading the pipeline, so
      # we use a class variable to detect this scenario and shortcircuit
      def transform(transformers)
        if not @@transformers_registered
            #transformers << WrapWithSections.new
            @@transformers_registered = true
        end
      end

      def execute(site)
        $LOG.debug "*** Executing features extension..." if $LOG.debug?
        features = Hash.new
        
        site.pages.each do |page|
          if ( page.relative_source_path =~ /^#{@path_prefix}\/.*\/*.md/ \
               || page.relative_source_path =~ /^#{@path_prefix}\/.*\/*.textile/ \
               || page.relative_source_path =~ /^#{@path_prefix}\/.*\/*.adoc/ )
            # all images locations should be relative to the optional value configured in the pipeline.rb
            $LOG.debug "  Processing " + page.title.to_s if $LOG.debug?
            feature = OpenStruct.new
            page.feature = feature
            site.engine.set_urls([page])
            feature.url = page.url
            feature.feature_id = page.feature_id
            feature.product_id = page.product_id
            feature.highlighted = page.feature_highlighted || false
            feature.name = page.title
            feature.order = page.feature_order != nil ? page.feature_order : 100
            feature.tagline = page.feature_tagline
            feature.image_url = URIHelper.concat(@path_prefix, page.feature_image_url)
            features[feature.product_id] = Array.new unless !features[feature.product_id].nil?
            features[feature.product_id] << feature
          end
        end
        site.features = features
        $LOG.debug "*** Done executing features extension..." if $LOG.debug?
        
      end
    end
  end
end