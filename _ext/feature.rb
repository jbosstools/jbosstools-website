module Awestruct
  module Extensions
    module Feature
      Change = Struct.new(:sha, :author, :date, :message)
      class Index
        include Feature
        
        def initialize(path_prefix, num_changes = nil)
          @path_prefix = path_prefix
          @num_changes = num_changes
        end

        def transform(transformers)
          #transformers << WrapHeaderAndAssignHeadingIds.new
        end

        def execute(site)
          features = []
          
          site.pages.each do |page|
            if ( page.relative_source_path =~ /^#{@path_prefix}\/(?!index)/ )
              
              feature = OpenStruct.new
              page.feature = feature
              site.engine.set_urls([page])
              feature.url = page.url
              feature.highlighted_feature = page.highlighted_feature != nil ? page.highlighted_feature : false
              feature.title = page.title
              feature.order = page.feature_order
              feature.image_url = page.image_url
              if page.description.nil?
                page.description = page.feature_summary
              end

              feature.summary = page.summary
              
              feature.content = Hpricot(page.content).to_s
              
              puts "Feature content=" + feature.content
              
              features << feature
            end
            site.features = features
          end
          
        end
      end

      class WrapHeaderAndAssignHeadingIds
      
        def transform(site, page, rendered)
          if page.feature
            page_content = Hpricot(rendered)

            feature_root = page_content.at('div[@id=feature]')

            # Wrap <div class="header"> around the h2 section
            # If you can do this more efficiently, feel free to improve it
            feature_content = feature_root.search('h2').first.parent
            indent = get_indent(get_depth(feature_content) + 2)
            in_header = true
            header_children = []
            feature_content.each_child do |child|
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

            feature_header = Hpricot::Elem.new('div', {:class=>'header'})
            feature_content.children[0, header_children.length] = [feature_header]
            feature_header.children = header_children
            feature_content.insert_before(Hpricot::Text.new("\n" + indent), feature_header)
            feature_content.insert_after(Hpricot::Text.new("\n" + indent), feature_header)

            feature_root.search('h3').each do |header_html|
              page.feature.sections.each do |section|
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