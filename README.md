# Muster

Muster is a gem that turns query string options of varying formats into data structures suitable for
easier consumption in things like AR and DataMapper scopes and queries, making API development just a little bit easier.

    select=id&select=name      {select => ['id', 'name']}
    select=id,name             {select => ['id', 'name']}

    where=id:1&where=name:foo  {where => ['id:1', 'name:food']}     ==> {where => {id => 1, name => food}}
    where=id:1&where=id:2      {where => ['id:1', 'id:2']}          ==> {where => {id => [1, 2]}}     
    where=id:1|2               {where => ['id:1|2']}                ==> {where => {id => [1, 2]}}

    order=name&order=age       {order => ['name', 'age']}           ==> {order => ['name ASC', 'age ASC']}
    order=name:asc&age:desc    {order => ['name:asc', 'age:desc']}  ==> {order => ['name ASC', 'age DESC']}

    page=2&per_page=5          {page => '2', per_page => '5' }      ==> {pagination => {page => 2, per_page => 5}, limit => 5, offset => 5}
    page=a&per_page=-2         {page => 'a', per_page => '-2' }     ==> {pagination => {page => 1, per_page => 10}, limit => 10, offset => 10}

## Installation

Add this line to your application's Gemfile:

    gem 'muster'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install muster

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

