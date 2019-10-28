require "rails_helper"

RSpec.describe "String Utilities" do
  it "#remove_non_ascii should remove all non ascii characters from string" do
    expect("A string with some control characters\n\r".remove_control_chars).to eq("A string with some control characters")
  end

  it "#remove_last_word should remove the last word from a camel case string" do
    expect("LocationGubbins".remove_last_word).to eq("Location")
    expect("LocationTypeGubbins".remove_last_word).to eq("LocationType")
  end
end
