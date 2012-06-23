require 'spec_helper'

describe Muster::Strategies::Pagination do
  let(:options) { {} }
  subject { Muster::Strategies::Pagination.new(options) }

  describe '#parse' do
    context 'by default' do
      it 'returns default hash for empty query string' do
        subject.parse('').should == {'pagination' => {'page' => 1, 'per_page' => 30}, 'offset' => nil, 'limit' => 30}
      end

      it 'ensures page is positive integer' do
        subject.parse('page=foop')[:pagination].should == {'page' => 1, 'per_page' => 30}
      end

      it 'ensures per_page is positive integer' do
        subject.parse('per_page=foop')[:pagination].should == {'page' => 1, 'per_page' => 30}
      end

      it 'accepts page_size instead of per_page' do
        subject.parse('page_size=10')[:pagination].should == {'page' => 1, 'per_page' => 10}
      end

      it 'calculates offset from pagination' do
        subject.parse('page=1&per_page=5')[:offset].should eq nil
        subject.parse('page=2&per_page=5')[:offset].should eq 5
        subject.parse('page=3&per_page=5')[:offset].should eq 10
      end
    end

    context 'with :only option' do
      context 'as symbol' do
        before { options[:only] = :limit }

        it 'only returns values for the key specified' do
          subject.parse('per_page=10').should == {'limit' => 10}
        end
      end

      context 'as Array of symbols' do
        before { options[:only] = [:limit, :offset] }

        it 'only returns values for the keys specified' do
          subject.parse('per_page=10&page=2').should == {'limit' => 10, 'offset' => 10}
        end
      end

      context 'as string' do
        before { options[:only] = 'limit' }

        it 'only returns values for the key specified' do
          subject.parse('per_page=10').should == {'limit' => 10}
        end
      end

      context 'as Array of strings' do
        before { options[:only] = ['limit', 'offset'] }

        it 'only returns values for the keys specified' do
          subject.parse('per_page=10&page=2').should == {'limit' => 10, 'offset' => 10}
        end
      end
    end
  end
end
