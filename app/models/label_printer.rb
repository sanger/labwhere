##
# Print barcode for a particular location
# The object will create a request from a print and location.
# The body of the json request is created through a serializer.
class LabelPrinter

  include ActiveModel::Serialization

  # Site which hosts barcode printing service
  class_attribute :site
  self.site = "http://psd2g.internal.sanger.ac.uk:8000/lims-support"

  # JSON headers
  class_attribute :headers
  self.headers = {'Content-Type' => "application/json", 'Accept' => "application/json"}

  attr_reader :request, :uri, :body, :locations

  delegate :as_json, :to_json, to: :serializer

  alias_attribute :labels, :locations
  
  ##
  # For a given printer and location create a json request.
  # The url is based on the site and the uuid of the printer.
  # The body of the request will contain a header and footer and info about the location.
  def initialize(printer_id, location_ids)
    @printer = Printer.find(printer_id)
    @locations = Location.find(Array(location_ids))

    @uri = URI.parse("#{self.site}/#{printer.uuid}")
    @http = Net::HTTP.new(uri.host, uri.port)
    @body = self.to_json
  end

  ##
  # Produce a success or failure message
  def message
    response_ok? ? I18n.t("printing.success") : I18n.t("printing.failure")
  end

  ##
  # Post the request to the barcode service.
  # Will return boolean dependent on the success of the request.
  def post
    @request = Net::HTTP::Post.new(uri.path, initheader = self.headers)
    request.body = body
    @response_code = http.request(request).code.to_i
    response_ok?
  end

  def response_code
    @response_code ||= 200
  end

  def response_ok?
    response_code == 200
  end

  ##
  # Create the json request body using the serializer
  def serializer
    @serializer ||= LabelPrinterSerializer.new(self)
  end

private

  attr_reader :http, :printer

end