require 'spec_helper'
require "./spec/models/concerns/searchable_spec.rb"

describe Domain do
	it_behaves_like "searchable"
end
