module Awestruct
  module Extensions
    class MyPosts < Posts

      def initialize(path_prefix='', assign_to=:posts, archive_template=nil, archive_path=nil, opts={})
        super(path_prefix, assign_to, archive_template, archive_path, opts)
        @imagesdir = opts[:imagesdir] || '/images'
        puts "Initialized MyPosts extension with imagesdir=" + @imagesdir
      end
      
      def execute(site)
        super(site)
        site.posts.each do |page|
          #todo why is this not just the pageurl so relative urls just works ?
          page.imagesdir = site.base_url + @imagesdir
        end
      end
    end
  end
end
