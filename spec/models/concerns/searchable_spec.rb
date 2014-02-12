require 'spec_helper'

shared_examples_for "searchable" do
  let(:model) { described_class }
  let(:searchable_object) { FactoryGirl.build(model.to_s.underscore.to_sym) }

  it "has searchable fields that aren't populated in unpersisted objects" do
    model.searchable_fields.each do |field_hash|
    	expect(searchable_object.send(field_hash[:field])).to be_blank
    end
  end

  it "populates its searchable fields before save" do
  	searchable_object.save
    model.searchable_fields.each do |field_hash|
      first_word = searchable_object.send(field_hash[:attribute]).match(/\w+/)
    	expect(searchable_object.send(field_hash[:field])).to match(/#{first_word}/i)
    end
  end

  it "updates its searchable fields when attributes updated" do
    searchable_object.save
    model.searchable_fields.each do |field_hash|
      new_value = "Changed"
      searchable_object.send("#{field_hash[:attribute]}=", new_value)
      searchable_object.save
      expect(searchable_object.send(field_hash[:field])).to match(/#{new_value}/i)
    end
  end

  it "sanitizes its clean fields (html example)" do
    example_data_field = model.searchable_fields.first[:attribute]
    example_clean_field = model.searchable_fields.first[:field]

    searchable_object.send("#{example_data_field}=", "<em>Italics</em>")
    searchable_object.save

    expect(searchable_object.send(example_clean_field)).not_to match(/<em>|<\/em>/)
  end

  it "resets clean fields to nil when attribute is optional and changed to nil" do
    model.searchable_fields.each do |field_hash|
      searchable_object.send("#{field_hash[:attribute]}=", nil)
      next unless searchable_object.valid?
      expect(searchable_object.send(field_hash[:field])).to be_nil
    end
  end
end

describe Searchable do
  describe "#sanitize" do
    it "strips html tags" do
      expect(Searchable.sanitize("<em>Italics</em>")).not_to match(/<em>|<\/em>/)
    end

    it "strips markdown" do
      expect(Searchable.sanitize("==~#~***__<>+^()")).to be_blank
    end

    it "removes puncutation other than periods (for web addresses)" do
      expect(Searchable.sanitize("example!?$%:;,")).to eq("example")
    end

    it "removes www. and http:// from searchable fields" do
      expect(Searchable.sanitize("http://www.infonet.org")).to eq("infonet.org")
    end

    it "leaves numbers in its fields" do
      expect(Searchable.sanitize("example1!")).to eq("example1")
    end

    it "preserves spacing" do
      expect(Searchable.sanitize("the quick brown fox")).to eq("the quick brown fox")
    end

    it "preseves hyphens" do
      expect(Searchable.sanitize("the-quick-brown-fox")).to eq("the-quick-brown-fox")
    end

    it "preserves apostrophes" do
      expect(Searchable.sanitize("my uncle's brother's aunt's dog")).to eq("my uncle's brother's aunt's dog")
    end

    it "preserves accented letters" do
      expect(Searchable.sanitize("ÀàÂâÄäÉéÈèÊêËëÎîÏïÔôÖöÛûÜüÙùÇç")).to eq("ÀàÂâÄäÉéÈèÊêËëÎîÏïÔôÖöÛûÜüÙùÇç")
    end
  end
end