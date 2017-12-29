require 'rspec/expectations'

RSpec::Matchers.define :to_match_cert_bundle do |expected|
  match do |actual|
    actual.gsub("\n", "") == expected.gsub("\n", "")
  end
  failure_message_when_negated do |actual|
    "expected that #{actual} would equal #{expected}"
  end
end

