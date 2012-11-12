module RedCloth::Formatters::HTML
  def jiras(opts)
    if opts != nil then
      puts "   Processing Related JIRAs " + opts.to_s
      jiras = opts[:text].split(',').map! {|s| s.strip}
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
end

