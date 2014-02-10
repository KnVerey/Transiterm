require 'spec_helper'

shared_examples_for "searchable" do
  let(:model) { described_class }
  let(:searchable_object) { FactoryGirl.build(model.to_s.underscore.to_sym) }

  it "has searchable fields" do
    expect(searchable_object.searchable_fields.count).to be > 0
  end

  it "has searchable fields that aren't populated in unpersisted objects" do
    searchable_object.searchable_fields.each do |k, v|
    	expect(v).to be_blank
    end
  end

  it "populates its searchable fields before save" do
  	searchable_object.save
    searchable_object.searchable_fields.each do |k, v|
    	puts "#{k} was blank in object #{searchable_object.inspect}" if v.blank?
    	expect(v).not_to be_blank
    end
  end
end