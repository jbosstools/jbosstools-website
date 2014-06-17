# This file is a rake build file. The purpose of this file is to simplify
# setting up and using Awestruct. It's not required to use Awestruct, though it
# does save you time (hopefully). If you don't want to use rake, just ignore or
# delete this file.
#
# If you're just getting started, execute this command to install Awestruct and
# the libraries on which it depends:
#
#  rake setup
#
# The setup task installs the necessary libraries according to which Ruby
# environment you are using. If you want the libraries kept inside the project,
# execute this command instead:
#
#  rake setup[local]
#
# IMPORTANT: To install gems, you'll need development tools on your machine,
# which include a C compiler, the Ruby development libraries and some other
# development libraries as well.
#
# There are also tasks for running Awestruct. The build will auto-detect
# whether you are using Bundler and, if you are, wrap calls to awestruct in
# `bundle exec`.
#
# To run in Awestruct in development mode, execute:
#
#  rake
#
# To clean the generated site before you build, execute:
#
#  rake clean preview
#
# To deploy using the production profile, execute:
#
#  rake deploy
#
# To get a list of all tasks, execute:
#
#  rake -T
#
# Now you're Awestruct with rake!


require 'rubygems'


#$use_bundle_exec = true
#$install_gems = ['awestruct -v "~> 0.5.3"', 'rb-inotify -v "~> 0.9.0"']
#$awestruct_cmd = nil
task :default => :preview

task :my_task, :arg1, :arg2 do |t, args|
  puts "Args were: #{args}"
end

desc 'retrieve local git repo information'
task :info, :profile do |t, args|
  puts "Local repository information for profile #{args}" 
  puts "Local branch=" + retrieve_local_branch_name()
  exit 0
end

def retrieve_local_branch_name()
  localBranch = %x(git rev-parse --abbrev-ref HEAD) 
  return localBranch
end

desc 'Setup the environment to run Awestruct'
task :setup, [:env] => :init do |task, args|
  next if !which('awestruct').nil?

  if File.exist? 'Gemfile'
    if args[:env] == 'local'
      require 'fileutils'
      FileUtils.remove_file 'Gemfile.lock', true
      FileUtils.remove_dir '.bundle', true
      system 'bundle install --binstubs=_bin --path=.bundle'
    else
      system 'bundle install'
    end
  else
    if args[:env] == 'local'
      $install_gems.each do |gem|
        msg "Installing #{gem}..."
        system "gem install --bindir=_bin --install-dir=.bundle #{gem}"
      end
    else
      $install_gems.each do |gem|
        msg "Installing #{gem}..."
        system "gem install #{gem}"
      end
    end
  end
  msg 'Run awestruct using `awestruct` or `rake`'
  # Don't execute any more tasks, need to reset env
  exit 0
end

desc 'Update the environment to run Awestruct'
task :update => :init do
  if File.exist? 'Gemfile'
    system 'bundle update'
  else
    system 'gem update awestruct'
  end
  # Don't execute any more tasks, need to reset env
  exit 0
end

desc 'Build and preview the site locally in development mode'
task :preview => :check do
  run_awestruct '-d'
end

desc 'Generate the site using the specified profile (default: development)'
task :gen => :check do |task, args|
  profile = args[0] || 'development'
  profile = 'production' if profile == 'prod'
  run_awestruct "-P #{profile} -g --force"
end

desc 'Push local commits to origin/develop'
task :push do
  system 'git push origin develop'
end

desc 'Generate the site and deploy to production'
task :deploy => [:push, :check] do |task, args|
  run_awestruct '-P #{profile} -g --force'
  run_awestruct '-P #{profile} --deploy'
end

desc "Assign publish dates to news entries"
task :setpub do
  set_pub_dates 'develop'
end

desc 'Clean out generated site and temporary files'
task :clean, :spec do |task, args|
  require 'fileutils'
  dirs = ['.awestruct', '.sass-cache', '_site']
  if args[:spec] == 'all'
    dirs << '_tmp'
  end
  dirs.each do |dir|
    FileUtils.remove_dir dir unless !File.directory? dir
  end
end

# Perform initialization steps, such as setting up the PATH
task :init do
  # Detect using gems local to project
  if File.exist? '_bin'
    ENV['PATH'] = "_bin#{File::PATH_SEPARATOR}#{ENV['PATH']}"
    ENV['GEM_HOME'] = '.bundle'
  end
end

desc 'Check to ensure the environment is properly configured'
task :check => :init do |task, args|
  if !File.exist? 'Gemfile'
    if which('awestruct').nil?
      msg 'Could not find awestruct.', :warn
      msg 'Run `rake setup` or `rake setup[local]` to install from RubyGems.'
      # Enable once the rubygem-awestruct RPM is available
      #msg 'Run `sudo yum install rubygem-awestruct` to install via RPM. (Fedora >= 18)'
      exit 1
    else
      $use_bundle_exec = false
      next
    end
  end

  begin
    require 'bundler'
    Bundler.setup
  rescue LoadError
    $use_bundle_exec = false
  rescue StandardError => e
    msg e.message, :warn
    if which('awestruct').nil?
      msg 'Run `rake setup` or `rake setup[local]` to install required gems from RubyGems.'
    else
      msg 'Run `rake update` to install additional required gems from RubyGems.'
    end
    exit e.status_code
  end
end

# Execute Awestruct
def run_awestruct(args)
  system "#{$use_bundle_exec ? 'bundle exec ' : ''}awestruct #{args}" 
end

# A cross-platform means of finding an executable in the $PATH.
# Respects $PATHEXT, which lists valid file extensions for executables on Windows
#
#  which 'awestruct'
#  => /usr/bin/awestruct
def which(cmd, opts = {})
  unless $awestruct_cmd.nil? || opts[:clear_cache]
    return $awestruct_cmd
  end

  $awestruct_cmd = nil
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each do |ext|
      candidate = File.join path, "#{cmd}#{ext}"
      if File.executable? candidate
        $awestruct_cmd = candidate
        return $awestruct_cmd
      end
    end
  end
  return $awestruct_cmd
end

# Print a message to STDOUT
def msg(text, level = :info)
  case level
  when :warn
    puts "\e[31m#{text}\e[0m"
  else
    puts "\e[33m#{text}\e[0m"
  end
end

def set_pub_dates(branch)
  require 'tzinfo'
  require 'git'
  local_tz = IO.readlines('_config/site.yml').find {|l| l.start_with?('local_tz: ') }.chomp.sub('local_tz: ', '')
  local_tz = TZInfo::Timezone.get(local_tz)

  repo = nil

  Dir['news/*.adoc'].select {|e| !e.start_with? 'news/_'}.each do |e|
    lines = IO.readlines e
    header = lines.inject([]) {|collector, l|
      break collector if l.chomp.empty?
      collector << l 
      collector
    }
  
    do_commit = false
    if !header.detect {|l| l.start_with?(':revdate: ') || l.start_with?(':awestruct-draft:') || l.start_with?(':awestruct-layout:') }
      revdate = Time.now.utc.getlocal(local_tz.current_period.utc_total_offset)
      lines[2] = "#{revdate.strftime('%Y-%m-%d')}\n"
      lines.insert(3, ":revdate: #{revdate}\n")
      File.open(e, 'w') {|f|
        f.write(lines.join)
      }
      if !repo
        repo = Git.open('.')
        b = repo.branch(branch)
        b.remote = 'origin/develop'
        b.create
        b.checkout
      end
      repo.add(e)
      repo.commit "Set publish date of post #{e} [ci skip]"
      do_commit = true
    end
  
    if do_commit
      repo.push('origin', branch)
    end
  end
end

desc 'Run the awestruct build'
task :buildstaging do
  success = system "bundle exec awestruct -P staging -g"
  fail unless success
end

desc 'Check for errors'
task :errorcheck do
  errorcheck
end

def errorcheck
puts 'Looking for awestruct errors in output:'
  success = system "grep -lr 'awestruct/engine' --exclude=Rakefile _site/"
  if success
    puts 'Errors found in output. Check files listed above.'
    fail
  end
  puts 'No errors found!'
end
############################################################################
#
# Build web site on Travis-CI
#
############################################################################
desc 'Generate site from Travis CI and publish site'
task :travis do
  # if this is a pull request, do a simple build of the site and stop
  if ENV['TRAVIS_PULL_REQUEST'].to_s.to_i > 0
    puts 'Pull request detected. Executing build only.'
    errorcheck
    next
  end
  
  tag = false

  if ENV['TRAVIS_BRANCH'].to_s.scan(/^production$/).length > 0
    tag = true
    puts 'Building production branch build.'
    profile = 'production'
    deploy_url = "tools@filemgmt.jboss.org:/www_htdocs/tools"

  elsif ENV['TRAVIS_BRANCH'].to_s.scan(/^master$/).length > 0
   
    puts 'Building staging(master) branch build.'
    profile = 'staging'
    deploy_url = "tools@filemgmt.jboss.org:/stg_htdocs/tools/"

  elsif ENV['TRAVIS_BRANCH'].to_s.scan(/^new_noteworthy$/).length > 0
   
    puts 'Building staging(new_noteworthy) branch build.'
    profile = 'new_noteworthy'
    deploy_url = "tools@filemgmt.jboss.org:/stg_htdocs/tools/new_noteworthy"
  
  else

    puts ENV['TRAVIS_BRANCH'].to_s + ' branch is not configured for Travis builds - skipping.'
    next

  end

  # Build execution
  system "bundle exec awestruct -P #{profile} -g"

  # Workaround for not having the above separated out properly in subtasks
  errorcheck

  puts '## Deploying website via rsync to #{deploy_url}'
  success = system("rsync -Pqr --protocol=28 --delete-after _site/* #{deploy_url}")

  if tag
    puts '## Tagging repo'
    system("git config --global user.email 'tools@jboss.org'")
    system("git config --global user.name 'JBoss Tools CI'")
    system("git remote add travis ${REPO_URL}")
    system('git tag $GIT_TAG -a -m "Published to production from TravisCI build $TRAVIS_BUILD_NUMBER"')
    system("git push travis $GIT_TAG")
  end
  fail unless success
end
