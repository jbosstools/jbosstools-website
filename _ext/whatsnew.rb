module Awestruct
  module Extensions
    module Whatsnew
      class Index
        
        def initialize(path_prefix)
          @path_prefix = path_prefix
        end

        def transform(transformers)
          #transformers << WrapHeaderAndAssignHeadingIds.new
        end

        def execute(site)
          new_and_noteworthies = Hash.new
          
          site.pages.each do |page|
            if ( page.relative_source_path =~ /^#{@path_prefix}\/.*\.md/ \
                 || page.relative_source_path =~ /^#{@path_prefix}\/.*\.textile/)
              
              puts "   Processing N&N " + page.module_name

              item = OpenStruct.new
              site.engine.set_urls([page])
              item.url = page.url
              item.title = page.module_name
              item.module_version = page.module_version
              item.jbt_version = page.jbt_version
              items = new_and_noteworthies[item.jbt_version]
              
              if(items == nil) 
                items = []
                new_and_noteworthies[item.jbt_version] = items
              end
              items << item
            end
            site.new_and_noteworthies = new_and_noteworthies
          end
          
        end
      end

      class WrapHeaderAndAssignHeadingIds
      
        def transform(site, page, rendered)
          if page.news_item
            page_content = Hpricot(rendered)

            news_item_root = page_content.at('div[@id=news_item]')

            # Wrap <div class="header"> around the h2 section
            # If you can do this more efficiently, feel free to improve it
            news_item_content = news_item_root.search('h2').first.parent
            indent = get_indent(get_depth(news_item_content) + 2)
            in_header = true
            header_children = []
            news_item_content.each_child do |child|
              if in_header
                if child.name == 'h3' or (child.name == 'div' and child.attributes['class'] == 'section')
                  in_header = false
                else
                  if child.pathname == 'text()' and child.to_s.strip.length == 0
                    header_children << Hpricot::Text.new("\n" + indent)
                  else
                    header_children << child
                  end
                end
              end
            end

            news_item_header = Hpricot::Elem.new('div', {:class=>'header'})
            news_item_content.children[0, header_children.length] = [news_item_header]
            news_item_header.children = header_children
            news_item_content.insert_before(Hpricot::Text.new("\n" + indent), news_item_header)
            news_item_content.insert_after(Hpricot::Text.new("\n" + indent), news_item_header)

            news_item_root.search('h3').each do |header_html|
              page.news_item.sections.each do |section|
                if header_html.inner_html.eql? section.text
                  header_html.attributes['id'] = section.link_id
                  break
                end
              end
            end
            return page_content.to_html.gsub(/^<!DOCTYPE [^>]*>/, '<!DOCTYPE html>')
          end
          return rendered
        end
        
        def get_depth(node)
          depth = 0
          p = node
          while p.name != 'html'
            depth += 1
            p = p.parent
          end
          depth
        end

        def get_indent(depth, ts = ' ')
          "#{ts * depth}"
        end
        
      end

    end
  end
end