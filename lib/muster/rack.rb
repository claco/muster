require 'active_support/hash_with_indifferent_access'
require 'rack'

module Muster

  # Rack middleware plugin for Muster query string parsing
  #
  # @example
  #
  #   app = Rack::Builder.new do
  #     use Muster::Rack, Muster::Strategies::Hash, :fields => [:name, :choices]
  #   end
  #   
  #   # GET /?name=bob&choices=1&choices=2
  #   match '/' do
  #     env['muster.query']  #=> {'name' => 'bob', 'choices' => ['1', '2']}
  #   end
  class Rack

    # @attribute [r] app
    # @return [Object] Rack application middleware is running under
    attr_reader :app
    
    # @attribute [r] strategy
    # @return [Muster::Strategies::Rack] Muster Strategy to run
    attr_reader :strategy
      
    # @attribute [r] options
    # @return [Hash] options to pass to strategy 
    attr_reader :options

    # Key in ENV where processed query string are stored
    QUERY = 'muster.query'.freeze

    # Key in ENV where the query string that was processed is stored
    QUERY_STRING = 'muster.query_string'.freeze

    # Creates a new Rack::Muster middleware instance
    #
    # @param app [String] Rack application
    # @param strategy [Muster::Strategies::Rack] Muster query string parsing strategy to run
    # @param options [Hash] options to pass to the specified strategy
    #
    # @example
    #
    #   middleware = Muster::Rack.new(app, Muster::Strategies::Hash, :fields => [:name, :choices])
    #   
    #   strategy = Muster::Strategies::Hash.new(:fields => [:name, :choices])
    #   middleware = Muster::Rack.new(app, strategy)
    def initialize( app, strategy, options={} )
      @app = app
      @strategy = strategy
      @options = options
    end

    # Handle Rack request
    #
    # @param env [Hash] Rack environment
    #
    # @return [Array]
    def call( env )
      request  = ::Rack::Request.new(env)
      parser   = self.strategy.kind_of?(Class) ? self.strategy.new(options) : self.strategy

      env[QUERY] ||= Muster::Results.new({})
      env[QUERY].merge! parser.parse(request.query_string)
      env[QUERY_STRING] = request.query_string

      @app.call(env)
    end

  end
end
