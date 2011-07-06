require "bundler"
Bundler.require
require 'fruit_bowl'

namespace :update do
  desc "update all the types"
  task :all do
    Item.update_all!
  end
end

# this is called by heroku
task :cron do
  Rake::Task["update:all"].invoke
end
