#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require 'yard'
require 'yard/rake/yardoc_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.verbose = false
end

YARD::Rake::YardocTask.new(:yard)
