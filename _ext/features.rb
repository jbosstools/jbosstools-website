require 'uri_helper'

module Awestruct
  module Extensions
    module Features
      Change = Struct.new(:sha, :author, :date, :message)
      class Index
        include Features
        
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
              #page.imagesdir = site.base_url + @imagesdir
              $LOG.debug "  Processing " + page.title.to_s if $LOG.debug?
              feature = OpenStruct.new
              page.feature = feature
              site.engine.set_urls([page])
              feature.url = URIHelper.concat(site.base_url, page.url)
              feature.id = page.feature_id
              feature.highlighted = page.feature_highlighted || false
              feature.name = page.title
              #feature.order = page.feature_order != nil ? page.feature_order : 100
              feature.tagline = page.feature_tagline
              feature.image_url = URIHelper.concat(site.base_url, @path_prefix, page.feature_image_url)
              #puts "Feature " + feature.id + ": highlighted= " + feature.highlighted.to_s 
              features[feature.id] = feature
            end
            site.features = features
          end
          $LOG.debug "*** Done executing features extension..." if $LOG.debug?
          
        end
      end

      class WrapWithSections
      
        # sadly, this part of the extension is strongly coupled with the features layout
        def transform(site, page, rendered)
          if page.feature != nil
            @doc = Nokogiri::HTML(rendered)
            
            # wrap mandatory H1 element into DIVs
            @doc.css("//div#overview/h1").
              wrap("<div class='row-fluid feature'></div>").
              wrap("<div class='span12'></div>").
              wrap("<div class='featureContent'></div>")
            
            # then, wrap all following H2 and P elements (both description and image) into the same DIVs
            @doc.css("//div#overview/*").select{|node| accept(node)}.each do |node|
              move_into_feature_content_element(node)
            end
            
            # then, extract the IMG from the div[class='featureContent']/p and add a heading <HR>
            @doc.css("//div.featureContent/p/img").each do |img|
              move_image_before_content(img)
            end
            
            # add the 'hero-unit' class to the first section and remove the <HR> there only
            add_hero_unit_class(@doc.css("//div.feature/div.span12").first) 
            
            return @doc.to_html
          end
          return rendered
        end
        
        # Filter nodes, ensure only H2 and P are accepted
        def accept(node) 
          return (node.name == "h2" || node.name == "p")
        end
        
        # looks for the previous sibling that is an element of class 'feature-content' 
        # and add the given node into it
        # note: some sibling maybe 'text' element, though.        
        def move_into_feature_content_element(node)
          sibling = findPreviousSibling(node, "div")
          if(sibling != nil) 
            node.parent = sibling.css("div[class='featureContent']").first
          end
        end
        
        # find previous sibling with given name for the given node 
        def findPreviousSibling(node, name) 
          return nil unless node != nil
          return (node.name == name) ? node : findPreviousSibling(node.previous_sibling, name) 
        end
        
        # move the image out of the 'feature-content' div, putting it before that node in the DOM
        def move_image_before_content(img)
          parent = findParentWithClass(img, "span12")
          if parent != nil
            parent.children.before(img)
            parent.children.before(Nokogiri::XML::Element.new("hr", @doc))
          end
        end
        
        def findParentWithClass(node, clazz)
          return nil unless !node.html?
          parent = node.parent
          return (parent.has_attribute?("class") && parent.get_attribute("class") == clazz) ? parent : findParentWithClass(parent, clazz) 
        end
        
        def add_hero_unit_class(node)
          return nil unless node != nil
          node.children.select{|c| c.name == 'hr'}.each do |c|
            c.remove
          end
          node.set_attribute("class", node.get_attribute("class") << " hero-unit")
        end
      end


    end
  end
end