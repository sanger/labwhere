# frozen_string_literal: true

RSpec.shared_context 'shared helpers', shared_context: :metadata do
  # This is necessary as the labware barcodes textarea is not visible
  def fill_in_labware_barcodes(text)
    within '.CodeMirror' do
      # Click makes CodeMirror element active:
      current_scope.click

      # Find the hidden textarea:
      field = current_scope.find('textarea', visible: false)

      # Mimic user typing the text:
      text.each_char do |char|
        field.send_keys char
        sleep 0.1 # Small delay to ensure each character is processed
      end
    end
  end
end
