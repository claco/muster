require 'spec_helper'

describe Muster::Rack do
  let(:application) { lambda{|env| [200, {'Content-Type' => 'text/plain'}, '']} }
  let(:environment) { Rack::MockRequest.env_for('/?name=value&order=name') }
  let(:options)     { {} }
  let(:middleware)  { Muster::Rack.new(application, Muster::Strategies::Hash, options) }

  it 'parse query string with strategy' do
    middleware.call(environment)

    environment[Muster::Rack::QUERY].should == {'name' => 'value', 'order' => 'name'}
    environment[Muster::Rack::QUERY].should be_an_instance_of(Muster::Results)
  end

  it 'accepts options for middlewhere' do
    options[:field] = :name

    middleware.call(environment)

    environment[Muster::Rack::QUERY].should == {'name' => 'value'}
    environment[Muster::Rack::QUERY].should be_an_instance_of(Muster::Results)
  end

  it 'accepts a strategy instance' do
    strategy = Muster::Strategies::Hash.new(:field => :name)
    Muster::Rack.new(application, strategy).call(environment)

    environment[Muster::Rack::QUERY].should == {'name' => 'value'}
    environment[Muster::Rack::QUERY].should be_an_instance_of(Muster::Results)
  end

  it 'merges multiple strategies into one result' do
    Muster::Rack.new(application, Muster::Strategies::Hash, :field => :name).call(environment)
    environment[Muster::Rack::QUERY].should == {'name' => 'value'}
    environment[Muster::Rack::QUERY].should be_an_instance_of(Muster::Results)

    Muster::Rack.new(application, Muster::Strategies::Hash, :field => :order).call(environment)
    environment[Muster::Rack::QUERY].should == {'name' => 'value', 'order' => 'name'}
    environment[Muster::Rack::QUERY].should be_an_instance_of(Muster::Results)
  end

  it 'supports indifferent access' do
    Muster::Rack.new(application, Muster::Strategies::Hash, :field => :name).call(environment)
    environment[Muster::Rack::QUERY].should == {'name' => 'value'}
    environment[Muster::Rack::QUERY].should be_an_instance_of(Muster::Results)

    Muster::Rack.new(application, Muster::Strategies::Hash, :field => :order).call(environment)
    environment[Muster::Rack::QUERY].should == {'name' => 'value', 'order' => 'name'}
    environment[Muster::Rack::QUERY].should be_an_instance_of(Muster::Results)

    environment[Muster::Rack::QUERY]['name'].should eq 'value'
    environment[Muster::Rack::QUERY][:name].should eq 'value'
  end
end
