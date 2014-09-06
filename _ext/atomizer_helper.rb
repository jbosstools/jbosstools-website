require 'products_helper'

require 'git'

module Awestruct
  module Extensions
    module AtomizerHelper

      ## returns last commit time stamp
      ## but if no git repo or file not under git control return modified date for the file.
      def last_commit_or_modifed_date (file)
        begin
          repo = Git.open('.') # :log => Logger.new(STDOUT))
          repo.log(1).object(file).first.date
        rescue
          File.mtime(file)
        end
      end
    end
  end
end

