require 'rspec/core/rake_task'
require 'bundler/gem_tasks'

ENV['test'] = 'true'

# Default directory to look in is `/spec`
RSpec::Core::RakeTask.new(:spec)
task :default => :spec