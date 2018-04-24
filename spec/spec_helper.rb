if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start
end

require 'pry'
require 'rack/mock'
require 'muster'
require 'rspec/its'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end
