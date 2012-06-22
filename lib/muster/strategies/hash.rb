require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/array/wrap'
require 'rack/utils'

module Muster
  module Strategies
    class Hash

      attr_accessor :options

      def initialize( options={} )
        self.options = options.with_indifferent_access
      end
      
      def parse( query_string )
        parameters = Rack::Utils.parse_query(query_string)

        if !only.empty?
          parameters = parameters.select{ |key,value| only.include?(key.to_s) }
        end

        if csv?
          parameters.each do |key, value|
            parameters[key] = value.split(/,\s*/) if value.instance_of?(String)
            parameters[key] = value.map{|value| value.split(/,\s*/)}.flatten if value.instance_of?(Array)
          end
        end

        parameters.each do |key, value|
          if value.instance_of?(Array)
            value.uniq!
          end
        end
        
        return parameters.with_indifferent_access
      end

      private

      def csv?
        @csv ||= (self.options[:csv] == true)
      end

      def only
        @only ||= Array.wrap(self.options[:only]).map(&:to_s)
      end

    end
  end
end
