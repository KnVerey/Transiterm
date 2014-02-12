require 'spec_helper'
require "./spec/models/concerns/searchable_spec.rb"
require "./spec/models/concerns/lookup_model_spec.rb"

describe Source do
	it_behaves_like "searchable"
	it_behaves_like "lookup_model"
end
