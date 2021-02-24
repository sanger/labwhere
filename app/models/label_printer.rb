# frozen_string_literal: true

require 'net/http'
##
# Print barcode for a particular location
# The object will create a request from a printer_id and location_ids.
class LabelPrinter
  include ActiveModel::Model
  attr_writer :copies
  attr_accessor :label_template_name
  attr_reader :labels, :printer

  validates_presence_of :printer, :locations, :label_template_name
  validates_numericality_of :copies, greater_than: 0
  ##
  # For a given printer and location create a json request.
  # The labels will contain a header and footer and info about the location.
  def initialize(attributes = {})
    super
    @labels = Label.new(locations * copies)
  end

  def printer=(printer)
    @printer = Printer.find(printer)
  end

  def locations=(locations)
    @locations = Location.find(Array(locations))
  end

  def copies
    @copies || 1
  end

  def locations
    @locations || []
  end

  ##
  # Produce a success or failure message
  def message
    response_ok? ? I18n.t("printing.success") : I18n.t("printing.failure")
  end

  ##
  # Post the request to the barcode service. The label_template_name refers to the LabWhere label template
  # Will return true if successful
  # Will return false if there is either an unexpected error or a server error
  def post
    return unless valid?

    begin
      response = Net::HTTP.post URI("#{Rails.configuration.pmb_api_base}/print_jobs"),
                                body.to_json,
                                'Content-Type' => 'application/json'
      if response.code == "200"
        @response_ok = true
      else
        throw JSON.parse(response.body)
      end
    rescue StandardError => e
      @response_ok = false
    end
  end

  def response_ok?
    @response_ok ||= false
  end

  private

  def body
    @body ||= {
      print_job: {
        printer_name: printer.name,
        label_template_name: label_template_name,
        labels: labels.body,
        copies: copies
      }
    }
  end
end
