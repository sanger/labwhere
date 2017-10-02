##
# Print barcode for a particular location
# The object will create a request from a printer_id and location_ids.
class LabelPrinter
  include ActiveModel::Model
  attr_accessor :printer, :locations, :label_template_id, :copies
  attr_reader :labels

  validates_presence_of :printer, :locations, :label_template_id
  validates_numericality_of :copies, greater_than: 0
  ##
  # For a given printer and location create a json request.
  # The labels will contain a header and footer and info about the location.
  def initialize(attributes = {})
    super
    @labels = Label.new(@locations, copies)
  end

  def printer=(printer)
    @printer = Printer.find(printer)
  end

  def locations=(locations)
    @locations = Location.find(Array(locations))
  end
  ##
  # Produce a success or failure message
  def message
    response_ok? ? I18n.t("printing.success") : I18n.t("printing.failure")
  end

  ##
  # Post the request to the barcode service. The label_template_id: 1 refers to the LabWhere label template
  # Will return true if successful
  # Will return false if there is either an unexpected error or a server error
  def post
    return unless valid?
    begin
      puts "!!! PRINTING !!!"
      # puts labels.body
      PMB::PrintJob.execute(printer_name: printer.name, label_template_id: label_template_id, labels: labels.to_h)
      @response_ok = true
    rescue JsonApiClient::Errors::ServerError, JsonApiClient::Errors::UnexpectedStatus => e
      @response_ok = false
    end
  end

  def response_ok?
    @response_ok ||= false
  end

end
