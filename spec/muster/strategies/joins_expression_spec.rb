require 'spec_helper'

describe Muster::Strategies::JoinsExpression do
  let(:options) { {} }
  subject { Muster::Strategies::JoinsExpression.new(options) }

  describe '#parse' do
    context 'by default' do
      it 'returns empty hash for empty query string' do
        subject.parse('').should eq({})
        subject.parse('').should be_an_instance_of(Muster::Results)
      end

      it 'returns hash of all key/value pairs' do
        subject.parse('joins=author,author.foop').should eq('joins' => ['author', { 'author' => 'foop' }])
      end

      it 'hash supports indifferent key access' do
        hash = subject.parse('joins=author,activity')
        hash[:joins][0].should eq('author')
        hash[:joins][1].should eq('activity')
      end

      it 'combines multiple expressions into an array' do
        subject.parse('joins=author,activity').should eq('joins' => ['author', 'activity'])
      end

      it 'discards non unique values' do
        subject.parse('joins=author&joins=author').should eq('joins' => ['author'])
      end
    end

    context 'with :expression_separator option' do
      context 'as regex' do
        before do
          options[:expression_separator] = /\|\s*/
        end

        it 'converts comma separated value into Array' do
          subject.parse('joins=author|activity').should eq('joins' => ['author', 'activity'])
        end

        it 'ignores spaces after a separator' do
          subject.parse('joins=author|%20  activity').should eq('joins' => ['author', 'activity'])
        end
      end

      context 'as string' do
        before do
          options[:expression_separator] = '|'
        end

        it 'converts comma separated value into Array' do
          subject.parse('joins=author|activity|rule').should eq('joins' => ['author', 'activity', 'rule'])
        end
      end
    end

    context 'with :field_separator option' do
      context 'as regex' do
        before { options[:field_separator] = /\s*:\s*/ }

        it 'splits field from values' do
          subject.parse('joins=author:country:name').should eq('joins' => [{ 'author' => { 'country' => 'name' } }])
        end

        it 'ignores spaces after field' do
          subject.parse('joins=author : country').should eq('joins' => [{ 'author' => 'country' }])
        end
      end

      context 'as string' do
        before { options[:field_separator] = ':' }

        it 'converts comma separated value into Array' do
          subject.parse('joins=author:country').should eq('joins' => [{ 'author' => 'country' }])
        end
      end
    end

    context 'with :fields option' do
      context 'as symbol' do
        before { options[:field] = :includes }

        it 'fields returns expressions for the key specified' do
          subject.parse('includes=author').should eq('includes' => ['author'])
        end
      end

      context 'as Array of symbols' do
        before { options[:fields] = [:includes, :joins] }

        it 'fields returns expressions for the keys specified' do
          subject.parse('joins=author&includes=activity').should eq('joins' => ['author'], 'includes' => ['activity'])
        end
      end

      context 'as string' do
        before { options[:field] = 'includes' }

        it 'fields returns expressions for the key specified' do
          subject.parse('includes=author').should eq('includes' => ['author'])
        end
      end

      context 'as Array of strings' do
        before { options[:fields] = ['includes', 'joins'] }

        it 'fields returns expressions for the keys specified' do
          subject.parse('includes=author&joins=activity').should eq('includes' => ['author'], 'joins' => ['activity'])
        end
      end
    end
  end
end
