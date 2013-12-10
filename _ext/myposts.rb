require 'URIHelper'

module Awestruct
  module Extensions
    class MyPosts < Posts

      def initialize(path_prefix='/posts', assign_to=:posts, archive_template=nil, archive_path=nil, opts={})
        super(path_prefix, assign_to, archive_template, archive_path, opts)
        @path_prefix = path_prefix
        $LOG.debug "*** Initialized MyPosts extension" if $LOG.debug?
      end
      
      def execute(site)
        $LOG.debug "*** Executing MyPosts extension..." if $LOG.debug?
        super(site)
        site.posts.each do |post|
          #todo why is this not just the pageurl so relative urls just works ?
          #post.imagesdir = site.base_url + @imagesdir
          #post.url = URIHelper.concat(site.base_url, post.output_path)
          #puts post.title + ": " + post.output_path.to_s + " -> " + post.url
        end
        $LOG.debug "*** Done executing posts extension." if $LOG.debug?
      end
    end
  end
end
