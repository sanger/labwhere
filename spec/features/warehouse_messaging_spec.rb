# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Warehouse Messaging', type: :feature do
  let(:num_plates) { 10 }
  let!(:sci_swipe_card_id) { generate(:swipe_card_id) }
  let!(:scientist) { create(:scientist, swipe_card_id: sci_swipe_card_id) }

  def testing_scenario
    location = create(:location_with_parent)
    labwares = build_list(:labware, num_plates)
    visit new_scan_path
    expect do
      fill_in "User swipe card id/barcode", with: sci_swipe_card_id
      fill_in "Location barcode", with: location.barcode
      fill_in "Labware barcodes", with: labwares.join_barcodes
      click_button "Go!"
    end.to change(Scan, :count).by(1)
  end

  context 'when using RabbitMQ' do
    let(:broker) do
      Messages::Broker.new('enabled' => true, 'broker_port' => 'xxxx', 'broker_host' => 'localhost')
    end

    before do
      stub_const("Broker::Handle", broker)
    end

    context 'when we cannot connect to RabbitMQ' do
      it 'provides Labware basic functionality without failing' do
        expect { testing_scenario }.not_to raise_error
        expect(page).to have_content "#{num_plates} labwares scanned in to Location"
      end
    end

    context 'when we cannot connect to RabbitMQ' do
      it 'groups error messages' do
        allow(ExceptionNotifier).to receive(:notify_exception)
        testing_scenario
        expect(ExceptionNotifier).to have_received(:notify_exception).exactly(num_plates).times
      end
    end

    context 'when we can connect but not publish to RabbitMQ' do
      let(:double_exchange) { double('exchange') }
      before do
        allow(broker).to receive(:connect).and_return(true)
        allow(broker).to receive(:exchange).and_return(double_exchange)
        allow(double_exchange).to receive(:publish).and_raise('Boom!')
      end
      it 'provides Labware basic functionality without failing' do
        expect { testing_scenario }.not_to raise_error
      end
    end

    context 'when we can connect and publish' do
      let(:double_exchange) { double('exchange') }

      before do
        allow(broker).to receive(:connect).and_return(true)
        allow(broker).to receive(:exchange).and_return(double_exchange)
        allow(double_exchange).to receive(:publish)
      end

      it 'publishes in the queues' do
        testing_scenario
        expect(double_exchange).to have_received(:publish).exactly(num_plates).times
      end
    end
  end
end
