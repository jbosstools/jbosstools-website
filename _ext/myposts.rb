require 'uri_helper'


############################
#
# Deprecated extension. 
#

module Awestruct
  module Extensions
    class MyPosts < Posts

      def initialize(path_prefix='/posts', assign_to=:posts, archive_template=nil, archive_path=nil, opts={})
        super(path_prefix, assign_to, archive_template, archive_path, opts)
        @path_prefix = path_prefix
        #@images_dir=opts[:imagesdir]
        $LOG.debug "*** Initialized MyPosts extension" if $LOG.debug?
      end
      
      def execute(site)
        $LOG.debug "*** Executing MyPosts extension..." if $LOG.debug?
        super(site)
        site.posts.each do |post|
          #todo why is this not just the pageurl so relative urls just works ?
          #post.imagesdir = URIHelper.concat(site.base_url, @images_dir)
          puts "post " + post.to_s
          #post.url = URIHelper.concat(site.base_url, post.output_path)
          #puts post.title + ": " + post.output_path.to_s + " -> " + post.url
          if ( post.relative_source_path =~ /^#{@path_prefix}\/([^.]+)\..*$/ ) then
            basename=$1
            post.output_path="#{@path_prefix}/#{basename}.html"
            puts "post -> " + post.output_path.to_s
          end
        end
        $LOG.debug "*** Done executing posts extension." if $LOG.debug?
      end
    end
  end
end
