module Awestruct
  module Extensions
    class BuildInfo
      
      def initialize()
      end

      # adds the current time to the site, so it can be reused
      #eg: Thu, 14 Apr 2011 12:17:27 GMT
      def execute(site)
        time = Time.now
        site.buildTime = time.strftime("%a, %d %b %Y %H:%M:%S %Z") 
        puts "Build time: " + site.buildTime
      end
      
    end
    
  end
  
end
     