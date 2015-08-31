#!/usr/bin/env rake
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'yard'
require 'yard/rake/yardoc_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.verbose = false
end

RuboCop::RakeTask.new

YARD::Rake::YardocTask.new(:yard)

task :default => [:rubocop, :spec, :yard]
