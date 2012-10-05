# Muster

Muster is a gem that turns query strings of varying formats into data structures suitable for
easier consumption in things like AR/DataMapper scopes and queries, making API development just a little bit easier.

    require 'muster'

    use Muster::Rack, Muster::Strategies::ActiveRecord, :fields => [:select, :order]

    # GET /people?select=id,name&order=name:desc
    # in your routes/controllers
    query = env['muster.query']

    @people = Person.select( query[:select] ).order( query[:order] )

## Strategies

The following types of strategies are supported. You can combine them in Rack any way you see fit to match the query string options
you want to support.

### Rack

Returns the query as parsed by Rack::Utils#parse_query.

    ?name=value1&name=value2&choice=1&choice=1
    
    { 'name' => ['value1', 'value2'], 'choice' => ['1', '1'] }

### Hash

Same as Rack but with support for delimited value separation and unique value detection.

    ?name=value1,value2&choice=1&choice=1

    { 'name' => ['value1', 'value2'], 'choice' => '1' }

### FilterExpression

Allows name value pairs to be specified in the query string values for use in filtering methods that take Hashes.
Include delimited value and unique value support from above.

    ?filter=id:1&filter=name:food  #=>  { 'filter' => {'id' => '1', 'name' => 'food'} }
    ?filter=id:1&filter=id:2       #=>  { 'filter' => {'id' => ['1', '2']} }     
    ?filter=id:1|2                 #=>  { 'filter' => {'id' => ['1', '2']} }
    ?filter=id:1,name:food         #=>  { 'filter' => {'id' => '1', 'name' => 'food'} }

### SortExpression

Returns options with support for dirctional indicators for use in sorting.

    ?order=name&order=age     #=>  { 'order' => ['name asc', 'age asc'] }
    ?order=name:asc&age:desc  #=>  { 'order' => ['name asc', 'age desc'] }

### Pagination

Returns options to support pagination with logic for default page size, not-a-number checks and offset calculations.

    ?page=2&per_page=5    #=>  { 'pagination' => {'page' => 2, 'per_page' => 5}, 'limit' => 5, 'offset' => 5 }
    ?page=a&page_size=-2  #=>  { 'pagination' => {'page' => 1, 'per_page' => 30}, 'limit' => 30, 'offset' => nil}


### ActiveRecord

Combines many of the strategies above to output ActiveRecord Query interface compatible options.

    ?select=id,name&where=status:new&order=name:desc&page=3&page_size=10
    
    { 'select' => ['id', 'name'], 'where' => {'status' => 'new'}, 'order' => 'name desc', 'limit' =>  10, 'offset' => 20, 'pagination' => {:page => 3, :per_page => 10} }

    query = env['muster.query']
    Person.select( query[:select] ).where( query[:where] ).order( query[:order] ).offset( query[:offset] ).limit( query[:limit] )

If you are using WillPaginate, you can also pass in :pagination:

    Person.paginate( query[:pagination] )

## Installation

Add this line to your application's Gemfile:

    gem 'muster'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install muster

## Usage

### In any Rack application:

    require 'muster'

    use Muster::Rack, Muster::Strategies::ActiveRecord, :fields => [:select, :order]
    
    # GET /people?select=id,name&order=name:desc
    # in your routes/controllers
    query = env['muster.query']
    
    @people = Person.select( query[:select] ).order( query[:order] )

You can combine multiple strategies, and their results will be merged

    use Muster::Rack, Muster::Strategies::Hash, :field => :select
    use Muster::Rack, Muster::Strategies::ActiveRecord, :field => :order
    
    # GET /people?select=id,name&order=name:desc
    # in your routes/controllers
    query = env['muster.query']
    
    @people = Person.select( query[:select] ).order( query[:order] )


### In any code:

    require 'muster'

    strategy = Muster::Strategies::Hash.new
    query    = strategy.parse(request.query_string)
    people   = Person.select( query[:select] ).order( query[:order] )

## Contributing

1. Fork it from https://github.com/claco/muster
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

