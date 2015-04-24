require "rails_helper"

RSpec.describe "String Utilities" do

  it "#remove_non_ascii should remove all non ascii characters from string" do
    expect("A string with some control characters\n\r".remove_control_chars).to eq("A string with some control characters")
  end
end