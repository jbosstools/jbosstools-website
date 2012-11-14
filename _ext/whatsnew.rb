module Awestruct
  module Extensions
    module Whatsnew
      class Index
        
        @@transformers_registered = false
        
        def initialize(path_prefix)
          @path_prefix = path_prefix
        end

        # transform gets called twice in the process of loading the pipeline, so
        # we use a class variable to detect this scenario and shortcircuit
        def transform(transformers)
          if not @@transformers_registered
              transformers << AddHorizonalClassToDefinitionLists.new
              @@transformers_registered = true
          end
        end

        def execute(site)
          new_and_noteworthies = Hash.new
          
          site.pages.each do |page|
            if ( page.relative_source_path =~ /^#{@path_prefix}\/.*\.md/ \
                 || page.relative_source_path =~ /^#{@path_prefix}\/.*\.textile/)
              
              puts "   Processing N&N " + page.module_name + page.module_version 
              news_item = OpenStruct.new
              site.engine.set_urls([page])
              news_item.url = page.url
              news_item.module_name = page.module_name
              news_item.module_version = page.module_version
              news_item.jbt_version = page.jbt_version
              news_items = new_and_noteworthies[news_item.jbt_version]
              if(news_items == nil) 
                news_items = []
                new_and_noteworthies[news_item.jbt_version] = news_items
              end
              news_items << news_item
              page.news_item = news_item
            end
            site.new_and_noteworthies = new_and_noteworthies
          end
          
        end
      end

      class AddHorizonalClassToDefinitionLists
      
        def transform(site, page, rendered)
          if page.news_item
            puts "... Transforming page " + page.url
            doc = Hpricot(rendered)
            # matches any <dl> element inside a <div> with class attribute containing 'whatsnew' (amongst other values)
            doc.search("//div.whatsnew//dl").each do |dl|
              dl.attributes['class'] = 'dl-horizontal'
            end
            return doc
          end
          return rendered
          
        end
        
      end

    end
  end
end