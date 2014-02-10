require 'spec_helper'

shared_examples_for "searchable" do
  let(:model) { described_class }

  it "has searchable fields" do
    searchable_object = FactoryGirl.create(model.to_s.underscore.to_sym)
    expect(searchable_object.searchable_fields.count).to be > 0
  end

  it "has searchable fields that aren't populated in unpersisted objects" do
    searchable_object = FactoryGirl.build(model.to_s.underscore.to_sym)
    searchable_object.searchable_fields.each do |k, v|
    	expect(v).to be_blank
    end
  end

  it "populates its searchable fields before save" do
    searchable_object = FactoryGirl.create(model.to_s.underscore.to_sym)
    searchable_object.searchable_fields.each do |k, v|
    	expect(v).not_to be_blank
    end
  end
end