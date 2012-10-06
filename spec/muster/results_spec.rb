require 'spec_helper'

describe Muster::Results do
  let(:data)        { {:name => [1, 2, 3]} }
  let(:options)     { {} }
  subject(:results) { Muster::Results.new(data, options) }

  its(:data) { should eq data }

  describe '#filter' do
    context 'without options hash' do
      it 'returns the same as fetch' do
        results.filter(:name).should eq [1,2,3]
      end

      it 'supports a default value' do
        results.filter(:bogons, :default).should eq :default
      end

      it 'throws exception without default' do
        expect{ results.filter(:bogons) }.to raise_error(KeyError)
      end
    end

    context 'with options hash' do
      context 'with :except option' do
        context 'with data value as Array' do
          before { data[:name] = [1,2,3] }

          it 'returns values not listed in :except as array' do
            results.filter(:name, :except => [2]).should eq [1,3]
          end

          it 'returns values not listed in :except as scalar' do
            results.filter(:name, :except => 2).should eq [1,3]
          end
        end

        context 'with data value as scalar' do
          before { data[:name] = 1 }

          it 'returns value not listed in :except as scalar' do
            results.filter(:name, :except => 2).should eq 1
          end

          it 'returns value not listed in :except as scalar' do
            results.filter(:name, :except => 1).should be_nil
          end
        end
      end

      context 'with :only option' do
        it 'returns value listed in :only as scalar' do
          results.filter(:name, :only => 1).should eq 1
        end

        it 'returns values listed in :only as array' do
          results.filter(:name, :only => [1,3]).should eq [1,3]
        end
      end
    end
  end

  describe '#filtered' do
    context 'without filters' do
      it 'returns self' do
        results.filtered.object_id.should == results.object_id
      end

      its(:filters) { should be_an_instance_of(Hash) }
      its(:filters) { should be_empty }
    end

    context 'with filters' do
      it 'applies filters to data' do
        results.add_filter(:name, :only => [2, 3])
        results.add_filter(:page, 1)
        results.add_filter(:order, :only => [:first])
        results.add_filter(:where, :only => :second)

        filtered_results = results.filtered
        filtered_results.should be_an_instance_of(Muster::Results)
        filtered_results.should == {"name"=>[2, 3], "page"=>1, "order"=>[], "where"=>nil}
      end
    end
  end
end
