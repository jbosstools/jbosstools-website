module RedCloth::Formatters::HTML
  def topic(opts)
    if opts != nil then
      result = "<dt>" + opts.to_s + "</dt>"
    end
    result
  end 

  def jiras(opts)
    if opts != nil then
      jiras = opts[:text].split(',').map! {|s| s.strip}
      # puts "   Processing Related JIRA(s) " + jiras.to_s
      if jiras.length > 1
        result = "<div class=\"related_jiras\"><ul>"
        result << "Related JIRAs: "
        links = []
        for jira in jiras
          links << "<li>" + toJiraLink(jira) + "</li>"
        end
        result << links.compact.join(", ")
        result << ".</ul></div>"
      elsif jiras.length == 1
        result = "<div class=\"related_jira\">Related JIRA: " << toJiraLink(jiras[0]) << ".</div>"
      else
        result = "No related JIRA"
      end
    end
    result
  end

  def toJiraLink(jiraId) 
    "<a href=\"https://issues.jboss.org/browse/" + jiraId.upcase + "\">" + jiraId.upcase + "</a>"
  end

  def vimeo(opts)
    clip_id, dim = opts[:text].split(' ').map! {|s| s.strip}
    dim_attrs = ''
    if dim
      # x is transformed by &#215; by textile
      w, h = dim.split('&#215;')
    else
      w, h = ["800", "600"]
    end
    dim_attrs = " width=\"#{w}\" height=\"#{h}\""
    "<div class=\"left\" id=\"container-reduced\"><link href=\"/stylesheets/jbt-movies.css\" media=\"screen, projection\" rel=\"stylesheet\" type=\"text/css\"><div class=\"playerbox\"><div id=\"player\"><iframe#{pba(opts)}#{dim_attrs} class=\"vimeo\" src=\"http://player.vimeo.com/video/#{clip_id}?title=0&amp;byline=0&amp;portrait=0\" frameborder=\"0\" webkitallowfullscreen=\"webkitallowfullscreen\" mozallowfullscreen=\"mozallowfullscreen\" allowfullscreen=\"allowfullscreen\"></iframe></div></div></div>"

  end

end
