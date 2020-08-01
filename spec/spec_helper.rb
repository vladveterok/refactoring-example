require 'simplecov'
require 'undercover'

SimpleCov.start do
  add_filter(%r{\/spec\/})
end

require_relative '../bootstrap'

require_relative 'fixtures/file_helper'
require_relative 'fixtures/phrases_helper'
require_relative 'fixtures/cards_helper'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.after do
    File.delete(FileHelper::OVERRIDABLE_FILENAME) if File.exist?(FileHelper::OVERRIDABLE_FILENAME)
  end
end
