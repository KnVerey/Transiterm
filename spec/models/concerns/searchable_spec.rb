require 'spec_helper'

shared_examples_for "searchable" do
  let(:model) { described_class }
  let(:searchable_object) { FactoryGirl.build(model.to_s.underscore.to_sym) }
  let(:example_clean_field) { searchable_object.searchable_fields.keys.first }

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

  it "removes puncutation in its searchable fields" do
    example_field = example_clean_field.gsub("clean_","")
    example_field << "_name" unless searchable_object.attributes.has_key?(example_field)
    searchable_object.send("#{example_field}=", "example!?$%:;,.")
    searchable_object.save

    expect(searchable_object.send(example_clean_field)).to eq("example")
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