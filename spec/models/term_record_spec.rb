require 'spec_helper'

describe TermRecord do

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

  it "destroys orphaned sources after destroy" do
    source = FactoryGirl.create(:source)
    term_record = FactoryGirl.create(:term_record, source: source)

    expect { term_record.destroy }.to change(Source, :count).by(-1)
    expect { Source.find(source.id) }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "does not destroy sources that aren't orphans" do
    source = FactoryGirl.create(:source)
    term_record = FactoryGirl.create(:term_record, source: source)
    successor = FactoryGirl.create(:term_record, source: source)

    expect { term_record.destroy }.not_to change(Source, :count)
  end

  it "destroys orphaned domains after destroy" do
    domain = FactoryGirl.create(:domain)
    term_record = FactoryGirl.create(:term_record, domain: domain)

    expect { term_record.destroy }.to change(Domain, :count).by(-1)
    expect { Domain.find(domain.id) }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "does not destroy domains that aren't orphans" do
    domain = FactoryGirl.create(:domain)
    term_record = FactoryGirl.create(:term_record, domain: domain)
    successor = FactoryGirl.create(:term_record, domain: domain)

    expect { term_record.destroy }.not_to change(Domain, :count)
  end
end
