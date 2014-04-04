require 'uri_helper'

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
        site.blog_dir = site.base_url + @path_prefix
        # changing the output path to avoid the /yyyy/mm/dd subfolders and problems with relative path to images
        #puts " blog posts: #{site.posts}"
        draft_posts = Array.new
        site.posts.each do |post|
          #puts " processing blog with title: '#{post.title}'..." 
          if ( post.relative_source_path =~ /^#{@path_prefix}\/([^.]+)\..*$/ ) then
            basename=$1
            post.output_path="#{@path_prefix}/#{basename}.html"
            #puts "  post date: #{post.date} >  #{Date.today.next_day} ? #{post.date > Date.today.next_day}"
            if post.date > Date.today.next_day
              draft_posts << post
              post.draft_article = true
            end
          end
        end
        unless site.profile == "development"
          draft_posts.each do |post|
            site.posts.delete(post) 
          end
        end
        $LOG.debug "*** Done executing posts extension." if $LOG.debug?
      end
    end
  end
end
