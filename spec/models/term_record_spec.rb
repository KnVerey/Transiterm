require 'spec_helper'

describe TermRecord do

  let(:person) { FactoryGirl.create(:user) }
  let (:cats) { FactoryGirl.create(:domain, user: person, name: "cats") }
  let (:rumors) { FactoryGirl.create(:source, user: person, name: "rumors") }
  let (:p_collection) { FactoryGirl.create(:collection, user: person) }
  let (:pc_record) { FactoryGirl.create(:term_record, domain: cats, source: rumors, collection: p_collection) }

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

  context "after save" do
    it "populates the clean_ fields if they were nil" do
      markdown_record = FactoryGirl.create(:term_record, english: "==A word!!!==", french: "**Un mot**", spanish: "__una-palabra__", context: "<strong>An example</strong>", comment: "**A** different thing")

      expect(markdown_record.clean_english).to match(/a word/)
      expect(markdown_record.clean_french).to match(/un mot/)
      expect(markdown_record.clean_spanish).to match(/palabra/)
      expect(markdown_record.clean_comment).to match(/a different thing/)
      expect(markdown_record.clean_context).to match(/an example/)
    end

    it "updates the clean_ fields if they changed" do
      markdown_record = FactoryGirl.create(:term_record, english: "==A word!!!==", french: "**Un mot**", spanish: "__una-palabra__", context: "<strong>An example</strong>", comment: "**A** different thing")
      markdown_record.french = "==Un mot!!=="
      markdown_record.save
      expect(markdown_record.clean_french).to eq("un mot")
    end
  end

  context "after destroy" do
    it "destroys newly orphaned sources" do
      term_record = FactoryGirl.create(:term_record)

      expect { term_record.destroy }.to change(Source, :count).by(-1)
      expect { Source.find(term_record.source_id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "does not destroy sources that aren't orphans" do
      successor = FactoryGirl.create(:term_record, source: rumors, collection: p_collection)

      expect { pc_record.destroy }.not_to change(Source, :count)
    end

    it "destroys newly orphaned domains" do
      term_record = FactoryGirl.create(:term_record)

      expect { term_record.destroy }.to change(Domain, :count).by(-1)
      expect { Domain.find(term_record.domain_id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "does not destroy domains that aren't orphans" do
      successor = FactoryGirl.create(:term_record, domain: cats, collection: p_collection)
      expect { pc_record.destroy }.not_to change(Domain, :count)
    end
  end

  context "when updating" do
    it "destroys newly orphaned sources" do
      new_source = FactoryGirl.create(:source, name: "wind", user: person)
      pc_record.reload
      expect { pc_record.update(source: new_source) }.to change(Source, :count).by(-1)
      expect { Source.find(rumors.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "does not destroy sources that aren't orphaned" do
      new_source = FactoryGirl.create(:source, name: "wind", user: person)
      successor = FactoryGirl.create(:term_record, source: rumors, collection: p_collection)

      expect { pc_record.update(source: new_source) }.not_to change(Source, :count)
    end

    it "destroys newly orphaned domains" do
      new_domain = FactoryGirl.create(:domain, name: "dogs", user: person)
      pc_record.reload
      expect { pc_record.update(domain: new_domain) }.to change(Domain, :count).by(-1)
      expect { Domain.find(cats.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "does not destroy domains that aren't orphaned" do
      new_domain = FactoryGirl.create(:domain, name: "dogs", user: person)
      successor = FactoryGirl.create(:term_record, domain: cats, collection: p_collection)

      expect { pc_record.update(domain: new_domain) }.not_to change(Domain, :count)
    end
  end
end