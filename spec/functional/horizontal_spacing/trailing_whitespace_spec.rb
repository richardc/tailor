require_relative '../../spec_helper'
require_relative '../../support/horizontal_spacing_cases'
require 'tailor/critic'
require 'tailor/configuration/style'


TRAILING_WHITESPACE = {}
TRAILING_WHITESPACE[:empty_line_with_spaces] = %Q{  }
TRAILING_WHITESPACE[:empty_line_with_spaces_in_method] = %Q{def thing
  
  puts 'something'
end}

TRAILING_WHITESPACE[:trailing_spaces_on_def] = %Q{def thing  
  puts 'something'
end}

describe "Trailing whitespace detection" do
  before do
    Tailor::Logger.stub(:log)
    FakeFS.activate!
    File.open(file_name.to_s, 'w') { |f| f.write contents }
    critic.check_file(file_name.to_s, style.to_hash)
  end

  let(:critic) do
    Tailor::Critic.new
  end

  let(:contents) { TRAILING_WHITESPACE[file_name]}

  let(:style) do
    style = Tailor::Configuration::Style.new
    style.trailing_newlines 0, level: :off
    style.allow_invalid_ruby true, level: :off

    style
  end

  context "line is empty spaces" do
    let(:file_name) { :empty_line_with_spaces }
    specify { critic.problems[file_name.to_s].size.should be 1 }
    specify { critic.problems[file_name.to_s].first[:type].should == "allow_trailing_line_spaces" }
    specify { critic.problems[file_name.to_s].first[:line].should be 1 }
    specify { critic.problems[file_name.to_s].first[:column].should be 2 }
    specify { critic.problems[file_name.to_s].first[:level].should be :error }
  end

  context "method contains an empty line with spaces" do
    let(:file_name) { :empty_line_with_spaces_in_method }
    specify { critic.problems[file_name.to_s].size.should be 1 }
    specify { critic.problems[file_name.to_s].first[:type].should == "allow_trailing_line_spaces" }
    specify { critic.problems[file_name.to_s].first[:line].should be 2 }
    specify { critic.problems[file_name.to_s].first[:column].should be 2 }
    specify { critic.problems[file_name.to_s].first[:level].should be :error }
  end

  context "def line ends with spaces" do
    let(:file_name) { :trailing_spaces_on_def }
    specify { critic.problems[file_name.to_s].size.should be 1 }
    specify { critic.problems[file_name.to_s].first[:type].should == "allow_trailing_line_spaces" }
    specify { critic.problems[file_name.to_s].first[:line].should be 1 }
    specify { critic.problems[file_name.to_s].first[:column].should be 11 }
    specify { critic.problems[file_name.to_s].first[:level].should be :error }
  end
end
