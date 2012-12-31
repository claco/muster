require 'active_support/core_ext/array/wrap'
require 'active_support/core_ext/object/blank'
require 'active_support/hash_with_indifferent_access'

module Muster

  # Query parsed results helper class
  #
  # As with most Muster classes, all hashes returned and options specified support with indifferent access.
  # You can also access results using the dot notation for the key name.
  #
  # @param data [Hash] the hash of query string results after parsing to load
  #
  # @example
  #
  #   data = { :select => [:id, :name, :created_at] }
  #   results = Muster::Results.new(data)
  #
  #   # Filter values one at a time
  #   results.data                                     #=> { 'select' => [:id, :name, :created_at] }
  #   results[:select]                                 #=> [:id, :name, :created_at]
  #   results.select                                   #=> [:id, :name, :created_at]
  #   results.filter(:select, :only => [:id, :name])   #=> [:id, :name]
  #   results.filter(:select, :except => :created_at)  #=> [:id, :name]
  #   results.filter(:page, 1)                         #=> 1
  #   results.filter(:page)                            #=> KeyError: :page does not exist
  #
  #   # Filter values in one pass
  #   results.add_filter(:select, :only => [:id, :name])
  #   results.add_filter(:page, 1)
  #   results.filtered                                 #=> { 'select' => [:id, :name], 'page' => 1 }
  #   results.filtered[:select]                        #=> [:id, :name]
  #   results.filtered.select                          #=> [:id, :name]
  class Results < ActiveSupport::HashWithIndifferentAccess

    # @attribute [r] data
    # @return [Hash] raw data specified during initialization
    attr_reader :data

    # @attribute [r] filters
    # @return [Hash] filters specified using {#add_filter}
    attr_reader :filters

    # Create a new results instance
    #
    # @param data [Hash] the raw parsed query string data
    # @param [Hash] options the options available for this method
    #  They'e aren't any options yet. :-)
    #
    # @example
    #
    #   data = { :select => [:id, :name, :created_at] }
    #   results = Muster::Results.new(data)
    def initialize( data, options={} )
      super(data)

      @data = data
      @filters = {}
    end

    # Add a filter to be applied to the data in {#filtered} results
    #
    # @param key [String,Symbol] the key of the values in {#data} to filter
    # @param [optional, Hash] options the options available for this filter
    # @option options [optional] :only when specified, only return the matching values
    #   If you specify a single value, a single value will be returned
    #   If you specify an Array of values, an Array will be returned, even if only one value matches
    # @option options [optional] :except return all values except the ones given here
    #   If the raw data value is a single value, a single value will be returned
    #   If the raw data value is an Array, and array will be returned, even if all values are excluded
    #   If nothing was excluded, the raw value is returned as-is
    #
    # If you pass a scalar value instead of a Hash into options, it will be treated as the default, just like
    # Hash#fetch does.
    #
    # If you pass nothing into the options argument, it will return all values if the key exists or raise
    # a KeyError like Hash#fetch.
    #
    # @return [void]
    #
    # @example
    #
    #   results.add_filter(:select, :only => [:id, :name])
    #   results.add_filter(:select, :except => [:id])
    #   results.add_filter(:page, 1)
    def add_filter( key, *options )
      self.filters[key] = options
    end

    # Returns the raw data with all of the filters applied
    #
    # If no filters were added, this method simply returns self.
    #
    # @return [Muster::Results]
    #
    # @example
    #
    #   results.add_filter(:select, :only => [:id, :name])
    #   results.add_dilter(:page, 1)
    #   results.filtered   #=> { 'select' => [:id, :name], 'page' => 1 }
    def filtered
      return self if self.filters.empty?

      filtered_results = self.filters.inject( {} ) do |results, (key, options)|
        results[key] = self.filter( key, *options )

        results
      end

      return self.class.new(filtered_results)
    end

    # Filters and returns the raw data values for the specifid key and options
    #
    # @param key [String,Symbol] the key of the values in {#data} to filter
    # @param [optional, Hash] options the options available for this filter
    # @option options [optional] :only when specified, only return the matching values
    #   If you specify a single value, a single value will be returned
    #   If you specify an Array of values, an Array will be returned, even if only one value matches
    # @option options [optional] :except return all values except the ones given here
    #   If the raw data value is a single value, a single value will be returned
    #   If the raw data value is an Array, and array will be returned, even if all values are excluded
    #   If nothing was excluded, the raw value is returned as-is
    #
    # If you pass a scalar value instead of a Hash into options, it will be treated as the default, just like
    # Hash#fetch does.
    #
    # If you pass nothing into the options argument, it will return all values if the key exists or raise
    # a KeyError like Hash#fetch.
    #
    # @return [void]
    #
    # @example
    #
    #   data = { :select => [:id, :name, :created_at] }
    #   results = Muster::Results.new(data)
    #   results.filter(:select)                            #=> [:id, :name, :created_at]
    #   results.filter(:select, :only => :name)            #=> :name
    #   results.filter(:select, :only => [:other, :name])  #=> [:name]
    #   results.filter(:other, :default)                   #=> :default
    #   results.filter(:other)                             #=> KeyError
    def filter( key, *options )
      if options.present? && options.first.instance_of?(Hash)
        options = options.first.with_indifferent_access

        if options.has_key?(:only)
          return filter_only_values( key, options[:only] )
        elsif options.has_key?(:except)
          return filter_excluded_values( key, options[:except] )
        end
      else
        return self.fetch(key, *options)
      end
    end

    private

    def method_missing(meth, *args, &block)
      if self.has_key?(meth)
        value = self[meth]

        if value.kind_of?(Hash)
          value.instance_eval do
            def method_missing(meth, *args, &block)
              if self.has_key?(meth)
                return self.fetch(meth)
              end

              super
            end
          end
        end

        return value
      end

      super
    end

    def filter_excluded_values( key, excluded )
      value = self[key]
      excluded = Array.wrap(excluded)

      if value.instance_of?(Array)
        return value - excluded
      elsif excluded.include?(value)
        return nil
      else
        return value
      end
    end

    def filter_only_values( key, allowed )
      values = Array.wrap( self[key] )

      if allowed.instance_of?(Array)
        return values & allowed
      elsif values.include?(allowed)
        return allowed
      end
    end

  end
end
