require 'spec_helper'
require "./spec/models/concerns/searchable_spec.rb"

describe TermRecord do

  it_behaves_like "searchable"

  let (:record) { FactoryGirl.create(:term_record) }

  context "during validation" do
    it 'should validate correct languages are saved based on collection settings' do
    	collection = FactoryGirl.build(:collection, :english => true, :french => true, :spanish => false)
    	term_record = FactoryGirl.build(:term_record, :collection => collection, :french => "")

    	term_record.should be_invalid
    end

    it 'should say record is valid' do
    	collection = FactoryGirl.build(:collection, :english => true, :french => true, :spanish => false)
    	term_record = FactoryGirl.build(:term_record, :collection => collection)

    	term_record.should be_valid
    end

    it 'should only add one error message' do
    	collection = FactoryGirl.build(:collection, :english => true, :french => true)
    	term_record = FactoryGirl.build(:term_record, :collection => collection, :french => "", :english => "")

    	term_record.valid?

    	term_record.errors.count.should == 1
    end
  end

  context "before save" do
    it "when an optional field changed to nil, it sets clean field to nil" do
      record.comment = nil
      record.save
      expect(record.clean_comment).to be_nil
    end
  end

  context "after destroy" do
    it "destroys newly orphaned sources" do
      record.reload
      expect { record.destroy }.to change(Source, :count).by(-1)
      expect { Source.find(record.source_id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "does not destroy sources that aren't orphans" do
      successor = FactoryGirl.create(:term_record)
      successor.user = record.user
      successor.source = record.source
      successor.save

      expect { record.destroy }.not_to change(Source, :count)
    end

    it "destroys newly orphaned domains" do
      record.reload
      expect { record.destroy }.to change(Domain, :count).by(-1)
      expect { Domain.find(record.domain_id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "does not destroy domains that aren't orphans" do
      successor = FactoryGirl.create(:term_record)
      successor.user = record.user
      successor.domain = record.domain
      successor.save

      expect { record.destroy }.not_to change(Domain, :count)
    end
  end

  context "when updating" do
    it "destroys newly orphaned sources" do
      new_source = FactoryGirl.create(:source, name: "wind", user: record.user)
      expect { record.update(source: new_source) }.to change(Source, :count).by(-1)
      expect(Source.count).to eq(1)
    end

    it "does not destroy sources that aren't orphaned" do
      new_source = FactoryGirl.create(:source, name: "wind", user: record.user)
      successor = FactoryGirl.create(:term_record)
      successor.user = record.user
      successor.source = record.source
      successor.save

      expect { record.update(source: new_source) }.not_to change(Source, :count)
    end

    it "destroys newly orphaned domains" do
      new_domain = FactoryGirl.create(:domain, name: "dogs", user: record.user)
      expect { record.update(domain: new_domain) }.to change(Domain, :count).by(-1)
      expect(Domain.count).to eq(1)
    end

    it "does not destroy domains that aren't orphaned" do
      new_domain = FactoryGirl.create(:domain, name: "dogs", user: record.user)
      successor = FactoryGirl.create(:term_record)
      successor.user = record.user
      successor.domain = record.domain
      successor.save

      expect { record.update(domain: new_domain) }.not_to change(Domain, :count)
    end
  end
end