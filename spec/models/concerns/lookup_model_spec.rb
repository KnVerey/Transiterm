require 'spec_helper'

shared_examples_for "lookup_model" do
  let(:model) { described_class }
  let(:lookup_object) { FactoryGirl.build(model.to_s.underscore.to_sym) }

	it "has a method #destroy_if_orphaned, which destroys the object with specified id if it has no associated term records" do
		lookup_object.save
		expect {
			model.destroy_if_orphaned(lookup_object.id)
		}.to change(model, :count).by(-1)
	end

	it "has a method #orphans, which returns an array of objects that are orphaned" do
		lookup_object.save
	  results = model.orphans
	  expect(results).to be_an(Array)
	  expect(results.first.class).to eq(model)
	end

  it "has an instance method #orphaned? that returns boolean for whether any records are associated with it" do
  	lookup_object.save
  	expect(lookup_object.orphaned?).to be_true
  end

end