# frozen_string_literal: true

RSpec.shared_context 'shared helpers', shared_context: :metadata do
  # This is necessary as the labware barcodes textarea is not visible
  def fill_in_labware_barcodes(text)
    within '.CodeMirror' do
      # Click makes CodeMirror element active:
      current_scope.click

      # Split the text by newline and send each part followed by Enter key
      text.split("\n").each do |line|
        current_scope.send_keys(line)
        current_scope.send_keys(:enter)
      end
    end
  end
end
