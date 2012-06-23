require 'active_support/core_ext/hash/slice'
require 'rack/utils'
require 'muster/strategies/hash'

module Muster
  module Strategies
    class Pagination < Hash
    
      def parse( query_string )
        parameters = Rack::Utils.parse_query(query_string).with_indifferent_access

        page = parameters.delete(:page).to_i
        page = 1 unless page > 0

        page_size = (parameters.delete(:page_size) || parameters.delete(:per_page)).to_i
        page_size = 30 unless page_size > 0

        offset = (page - 1) * page_size
        offset = nil if offset < 1

        parameters = parameters.merge(:pagination => {:page => page, :per_page => page_size}, :limit => page_size, :offset => offset)
        
        parameters = parameters.slice(*self.options[:only]).with_indifferent_access unless only.empty?

        parameters
      end

    end
  end
end
