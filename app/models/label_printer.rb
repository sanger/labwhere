##
# Print barcode for a particular location
# The object will create a request from a printer_id and location_ids.
class LabelPrinter

  attr_reader :printer, :locations, :labels

  ##
  # For a given printer and location create a json request.
  # The labels will contain a header and footer and info about the location.
  def initialize(printer_id, location_ids)
    @printer = Printer.find(printer_id)
    @locations = Location.find(Array(location_ids))
    @labels = Label.new(@locations)
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
    begin
      PMB::PrintJob.execute(printer_name: @printer.name, label_template_id: 1, labels: @labels.to_h)
      @response_ok = true
    rescue JsonApiClient::Errors::ServerError, JsonApiClient::Errors::UnexpectedStatus => e
      @response_ok = false
    end
  end

  def response_ok?
    @response_ok ||= false
  end

end