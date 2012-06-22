require 'spec_helper'

describe Muster::Strategies::Hash do
  let(:options) { {} }
  subject { Muster::Strategies::Hash.new(options) }

  describe '#parse' do

    context 'by default' do
      it 'returns empty hash for empty query string' do
        subject.parse('').should == {}
      end

      it 'returns hash of all key/value pairs' do
        subject.parse('a=1&b=2').should == {'a' => '1', 'b' => '2'}
      end

      it 'hash supports indifferent key access' do
        hash = subject.parse('a=1')
        hash[:a].should eq '1'
        hash['a'].should eq '1'
      end

      it 'combines multiple key values into an array' do
        subject.parse('a=1&a=2').should == {'a' => ['1', '2']}
      end

      it 'discards non unique values' do
        subject.parse('a=1&a=2&a=1').should == {'a' => ['1', '2']}
      end
    end

    context 'with :csv option' do
      before { options[:csv] = true}   

      it 'converts comma separated value into Array' do
        subject.parse('a=1,2&a=3').should == {'a' => ['1', '2', '3']}
      end

      it 'ignores spaces after commas' do
        subject.parse('a=1,+2,%20   3').should == {'a' => ['1', '2', '3']}
      end
    end

    context 'with :only option' do
      context 'as symbol' do
        before { options[:only] = :a }

        it 'only returns values for the key specified' do
          subject.parse('a=1&b=2').should == {'a' => '1'}
        end
      end

      context 'as Array of symbols' do
        before { options[:only] = [:a, :b] }

        it 'only returns values for the keys specified' do
          subject.parse('a=1&b=2&c=3').should == {'a' => '1', 'b' => '2'}
        end
      end

      context 'as string' do
        before { options[:only] = 'a' }

        it 'only returns values for the key specified' do
          subject.parse('a=1&b=2').should == {'a' => '1'}
        end
      end

      context 'as Array of strings' do
        before { options[:only] = ['a', 'b'] }

        it 'only returns values for the keys specified' do
          subject.parse('a=1&b=2&c=3').should == {'a' => '1', 'b' => '2'}
        end
      end
    end

  end
end
