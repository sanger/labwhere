# frozen_string_literal: true

require "rails_helper"

RSpec.describe PrintsController, type: :controller do
  describe 'POST create' do
    let(:label_printer_double) do
      label_printer = instance_double(LabelPrinter)
      allow(label_printer).to receive(:post)
      allow(label_printer).to receive(:message).and_return(I18n.t("printing.success"))
      allow(label_printer).to receive(:response_ok?).and_return(true)
      label_printer
    end

    let(:label_printer_double_error) do
      label_printer = instance_double(LabelPrinter)
      allow(label_printer).to receive(:post)
      allow(label_printer).to receive(:message).and_return(I18n.t("printing.failure"))
      allow(label_printer).to receive(:response_ok?).and_return(false)
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
          .with(printer: @printer.id.to_s, locations: @location.child_ids, label_template_name: 'labwhere_1d', copies: 1)
          .and_return(label_printer_double)

        post :create, params: {
          location_id: @location.id,
          printer_id: @printer.id,
          barcode_type: "1D",
          print_child_barcodes: 1,
          copies: 1
        }, xhr: true

        expect(response.status).to eq(200)

        expect(assigns(:message_type)).to eq('notice')
        expect(assigns(:message)).to eq(I18n.t("printing.success") + " for each child of location: #{@location.name}")
      end
    end

    context 'when print_child_barcodes is false' do
      it 'sends the location to the LabelPrinter' do
        expect(LabelPrinter).to receive(:new)
          .with(printer: @printer.id.to_s, locations: @location.id.to_s, label_template_name: 'labwhere_1d', copies: 1)
          .and_return(label_printer_double)

        post :create, params: {
          location_id: @location.id,
          printer_id: @printer.id,
          barcode_type: "1D",
          copies: 1
        }, xhr: true

        expect(response.status).to eq(200)

        expect(assigns(:message_type)).to eq('notice')
        expect(assigns(:message)).to eq(I18n.t("printing.success") + " for location: #{@location.name}")
      end
    end

    context 'when label printer returns error' do
      it 'displays an error message to the user' do
        expect(LabelPrinter).to receive(:new)
          .with(printer: @printer.id.to_s, locations: @location.id.to_s, label_template_name: 'labwhere_1d', copies: 1)
          .and_return(label_printer_double_error)

        post :create, params: {
          location_id: @location.id,
          printer_id: @printer.id,
          barcode_type: "1D",
          copies: 1
        }, xhr: true

        expect(assigns(:message_type)).to eq('alert')
        expect(assigns(:message)).to eq(I18n.t("printing.failure") + " for location: #{@location.name}")
      end
    end
  end
end
