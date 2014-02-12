require 'spec_helper'
require "./spec/models/concerns/searchable_spec.rb"

describe Source do
	it_behaves_like "searchable"
end
