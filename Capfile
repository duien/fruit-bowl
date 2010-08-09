load 'deploy' if respond_to?(:namespace) # cap2 differentiator

set :application, 'fruit-bowl'
set :deploy_to, "/opt/#{application}"


set :scm, 'git'
#set :repository, 'file:///Users/emilyprice/Code/mongo-blog'
set :repository, 'git@github.com:/duien/fruit-bowl'
set :deploy_via, 'copy'
#set :copy_cache, true
# set :git_enable_submodules, 1

set :user, 'deploymeister'
set :use_sudo, false

role :app, "67.23.30.81"
role :web, "67.23.30.81"
role :db,  "67.23.30.81", :primary => true

set :keep_releases, 3

after 'deploy:update', 'deploy:cleanup'

namespace :deploy do
  task :start, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
    # Do nothing.
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end
end

task :copy_config do
  run "mkdir -p #{release_path}/config"
  run "cp /home/deploymeister/configuration/fruit-bowl/*.yml #{release_path}/config/"
end

after 'deploy:finalize_update', 'copy_config'
