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
          puts "Executing whatsnew extension.."
          new_and_noteworthies_per_version = Hash.new
          new_and_noteworthies_per_module_id = Hash.new
          
          site.pages.each do |page|
            if ( page.relative_source_path =~ /^#{@path_prefix}\/.*\.md/ \
                 || page.relative_source_path =~ /^#{@path_prefix}\/.*\.textile/)
              
              # puts "   Processing N&N " + page.module_name + page.module_version 
              news_item = OpenStruct.new
              site.engine.set_urls([page])
              news_item.url = page.url
              news_item.module_id = page.module_id
              news_item.module_name = page.module_name
              news_item.module_version = page.module_version
              news_item.jbt_version = page.jbt_version
              news_item.content = page.content
              
              # puts "What's new content:\n" + news_item.content + "\n"
              
              if(new_and_noteworthies_per_version[news_item.jbt_version] == nil) 
                new_and_noteworthies_per_version[news_item.jbt_version] = []
              end
              new_and_noteworthies_per_version[news_item.jbt_version] << news_item
              
              if(new_and_noteworthies_per_module_id[news_item.module_id] == nil) 
                new_and_noteworthies_per_module_id[news_item.module_id] = []
              end
              new_and_noteworthies_per_module_id[news_item.module_id] << news_item
              
              page.news_item_per_version = news_item
            end
            site.new_and_noteworthies_per_version = new_and_noteworthies_per_version
            site.new_and_noteworthies_per_module_id = new_and_noteworthies_per_module_id
          end
          puts "Done executing whatsnew extension.."
          
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