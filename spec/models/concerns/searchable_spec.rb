require 'spec_helper'

shared_examples_for "searchable" do
  let(:model) { described_class }
  let(:searchable_object) { FactoryGirl.build(model.to_s.underscore.to_sym) }

  it "has searchable fields" do
    expect(model.searchable_fields.size).to be > 0
  end

  it "has searchable fields that aren't populated in unpersisted objects" do
    model.searchable_fields.each do |f|
    	expect(searchable_object.send(f)).to be_blank
    end
  end

  it "populates its searchable fields before save" do
  	searchable_object.save
    model.searchable_fields.each do |f|
    	expect(searchable_object.send(f)).not_to be_blank
    end
  end

  it "sanitizes its clean fields (html example)" do
    example_clean_field = model.searchable_fields.first
    example_field = example_clean_field.gsub("clean_","")
    example_field << "_name" unless searchable_object.attributes.has_key?(example_field)
    searchable_object.send("#{example_field}=", "<em>Italics</em>")
    searchable_object.save

    expect(searchable_object.send(example_clean_field)).not_to match(/<em>|<\/em>/)
  end
end

describe Searchable do
  it "does not allow html tags in its searchable fields" do
    example_field = example_clean_field.gsub("clean_","")
    example_field << "_name" unless searchable_object.attributes.has_key?(example_field)
    searchable_object.send("#{example_field}=", "<em>Italics</em>")
    searchable_object.save

    expect(searchable_object.send(example_clean_field)).not_to match(/<em>|<\/em>/)
  end

  it "does not allow markdown in its searchable fields" do
    example_field = example_clean_field.gsub("clean_","")
    example_field << "_name" unless searchable_object.attributes.has_key?(example_field)
    searchable_object.send("#{example_field}=", "==~#~***__<>+^()")
    searchable_object.save

    expect(searchable_object.send(example_clean_field)).to be_blank
  end

  it "removes puncutation other than periods (for web addresses) in its searchable fields" do
    example_field = example_clean_field.gsub("clean_","")
    example_field << "_name" unless searchable_object.attributes.has_key?(example_field)
    searchable_object.send("#{example_field}=", "example!?$%:;,")
    searchable_object.save

    expect(searchable_object.send(example_clean_field)).to eq("example")
  end

  it "removes www. and http:// from searchable fields" do
    example_field = example_clean_field.gsub("clean_","")
    example_field << "_name" unless searchable_object.attributes.has_key?(example_field)
    searchable_object.send("#{example_field}=", "http://www.infonet.org")
    searchable_object.save

    expect(searchable_object.send(example_clean_field)).to eq("infonet.org")
  end

  it "leaves numbers in its fields" do
    example_field = example_clean_field.gsub("clean_","")
    example_field << "_name" unless searchable_object.attributes.has_key?(example_field)
    searchable_object.send("#{example_field}=", "example1!")
    searchable_object.save

    expect(searchable_object.send(example_clean_field)).to eq("example1")
  end

  it "preserves spacing in its searchable fields" do
    example_field = example_clean_field.gsub("clean_","")
    example_field << "_name" unless searchable_object.attributes.has_key?(example_field)
    searchable_object.send("#{example_field}=", "the quick brown fox")
    searchable_object.save

    expect(searchable_object.send(example_clean_field)).to eq("the quick brown fox")
  end

  it "preseves hyphens in its searchable fields" do
    example_field = example_clean_field.gsub("clean_","")
    example_field << "_name" unless searchable_object.attributes.has_key?(example_field)
    searchable_object.send("#{example_field}=", "the-quick-brown-fox")
    searchable_object.save

    expect(searchable_object.send(example_clean_field)).to eq("the-quick-brown-fox")
  end

  it "preserves apostrophes in its searchable fields" do
    example_field = example_clean_field.gsub("clean_","")
    example_field << "_name" unless searchable_object.attributes.has_key?(example_field)
    searchable_object.send("#{example_field}=", "my uncle's brother's aunt's dog")
    searchable_object.save

    expect(searchable_object.send(example_clean_field)).to eq("my uncle's brother's aunt's dog")
  end

  it "preserves accented letters in its searchable fields" do
    example_field = example_clean_field.gsub("clean_","")
    example_field << "_name" unless searchable_object.attributes.has_key?(example_field)
    searchable_object.send("#{example_field}=", "ÀàÂâÄäÉéÈèÊêËëÎîÏïÔôÖöÛûÜüÙùÇç")
    searchable_object.save

    expect(searchable_object.send(example_clean_field)).to eq("ÀàÂâÄäÉéÈèÊêËëÎîÏïÔôÖöÛûÜüÙùÇç")
  end
end