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

end
