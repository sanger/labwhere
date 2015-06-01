class LabelPrinter

  class_attribute :site
  self.site = "http://psd2g.internal.sanger.ac.uk:8000/lims-support"

  class_attribute :headers
  self.headers = {'Content-Type' => "application/json", 'Accept' => "application/json"}

  attr_reader :request, :uri, :body, :location

  delegate :as_json, :to_json, to: :serializer
  
  def initialize(printer_id, location_id)
    @printer = Printer.find(printer_id)
    @location = Location.find(location_id)

    @uri = URI.parse("#{self.site}/#{printer.uuid}")
    @http = Net::HTTP.new(uri.host, uri.port)
    @body = self.to_json
  end

  def message
    response_ok? ? I18n.t("printing.success") : I18n.t("printing.failure")
  end

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

  def serializer
    @serializer ||= LabelPrinterSerializer.new(self)
  end

private

  attr_reader :http, :printer

end