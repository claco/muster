require 'spec_helper'

describe Muster::Strategies::FilterExpression do
  let(:options) { {} }
  subject { Muster::Strategies::FilterExpression.new(options) }

  describe '#parse' do

    context 'by default' do
      it 'returns empty hash for empty query string' do
        subject.parse('').should == {}
        subject.parse('').should be_an_instance_of(Muster::Results)
      end

      it 'returns hash of all key/value pairs' do
        subject.parse('where=id:1&filter=name:foop').should == { 'where' => {'id' => '1'}, 'filter' => {'name' => 'foop'} }
      end

      it 'hash supports indifferent key access' do
        hash = subject.parse('where=id:1')
        hash[:where][:id].should eq '1'
        hash['where']['id'].should eq '1'
      end

      it 'combines multiple expressions into an array' do
        subject.parse('where=id:1&where=id:2').should == { 'where' => {'id' => ['1', '2']} }
      end

      it 'support for multiple values using |' do
        subject.parse('where=id:1|2&where=id:3').should == { 'where' => {'id' => ['1', '2', '3']} }
      end

      it 'support for multiple expressions using ,' do
        subject.parse('where=id:1,id:2,id:3').should == { 'where' => {'id' => ['1', '2', '3']} }
      end

      it 'discards non unique values' do
        subject.parse('where=id:1&where=id:2&where=id:1').should == { 'where' => {'id' => ['1', '2']} }
      end
    end

    context 'with :value_separator option' do
      context 'as regex' do
        before do
          options[:expression_separator] = '|'
          options[:value_separator] = /,\s*/
        end

        it 'converts comma separated value into Array' do
          subject.parse('where=id:1,2').should == { 'where' => {'id' => ['1', '2']} }
        end

        it 'ignores spaces after commas' do
          subject.parse('where=id:1,+2,%20   3').should == { 'where' => {'id' => ['1', '2', '3']} }
        end
      end

      context 'as string' do
        before do
          options[:expression_separator] = '|'
          options[:value_separator] = ','
        end

        it 'converts comma separated value into Array' do
          subject.parse('where=id:1,2,3').should == { 'where' => {'id' => ['1', '2', '3']} }
        end
      end
    end

    context 'with :field_separator option' do
      context 'as regex' do
        before { options[:field_separator] = /\s*!\s*/ }

        it 'splits field from values' do
          subject.parse('where=id!1').should == { 'where' => {'id' => '1'} }
        end

        it 'ignores spaces after field' do
          subject.parse('where=id ! 1').should == { 'where' => {'id' => '1'} }
        end
      end

      context 'as string' do
        before { options[:field_separator] = '!' }

        it 'converts comma separated value into Array' do
          subject.parse('where=id!1').should == { 'where' => {'id' => '1'} }
        end
      end
    end

    context 'with :fields option' do
      context 'as symbol' do
        before { options[:field] = :where }

        it 'fields returns expressions for the key specified' do
          subject.parse('where=id:1&filters=id:2').should == { 'where' => {'id' => '1'} }
        end
      end

      context 'as Array of symbols' do
        before { options[:fields] = [:where, :filter] }

        it 'fields returns expressions for the keys specified' do
          subject.parse('where=id:1&filter=id:2&attribute=id:3').should == { 'where' => {'id' => '1'}, 'filter' => {'id' => '2'} }
        end
      end

      context 'as string' do
        before { options[:field] = 'where' }

        it 'fields returns expressions for the key specified' do
          subject.parse('where=id:1&filter=id:2').should == { 'where' => {'id' => '1'} }
        end
      end

      context 'as Array of strings' do
        before { options[:fields] = ['where', 'filter'] }

        it 'fields returns expressions for the keys specified' do
          subject.parse('where=id:1&filter=id:2&attribute=id:3').should == { 'where' => {'id' => '1'}, 'filter' => {'id' => '2'} }
        end
      end
    end

  end
end
