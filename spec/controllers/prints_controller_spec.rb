require "rails_helper"

RSpec.describe PrintsController, type: :controller do

  describe 'POST create' do

    let(:label_printer_double) do
      label_printer = instance_double(LabelPrinter)
      allow(label_printer).to receive(:post)
      allow(label_printer).to receive(:message)
      label_printer
    end

    before :each do
      @printer  = create(:printer)
      @location = create(:unordered_location)
    end

    context 'when print_child_barcodes is true' do
      it 'sends the Location\'s children to the LabelPrinter' do
        @location.children = create_list(:location, 3)

        expect(LabelPrinter).to receive(:new)
          .with(@printer.id.to_s, @location.child_ids)
          .and_return(label_printer_double)

        post :create, location_id: @location.id, printer_id: @printer.id, print_child_barcodes: 1

        expect(response).to redirect_to locations_path
      end
    end

    context 'when print_child_barcodes is false' do
      it 'sends the location to the LabelPrinter' do

        expect(LabelPrinter).to receive(:new)
          .with(@printer.id.to_s, @location.id.to_s)
          .and_return(label_printer_double)

        post :create, location_id: @location.id, printer_id: @printer.id

        expect(response).to redirect_to locations_path
      end
    end

  end

end