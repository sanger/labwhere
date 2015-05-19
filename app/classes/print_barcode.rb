class PrintBarcode

  class_attribute :site
  self.site = "http://psd2g.internal.sanger.ac.uk:8000/lims-support"

  class_attribute :headers
  self.headers = {'Content-Type' => "application/json", 'Accept' => "application/json"}

  attr_reader :request, :response, :printer, :location, :uri, :message
  
  def initialize(printer_id, location_id)
    @printer = Printer.find(printer_id)
    @location = Location.find(location_id)

    create_request
  end

  def post
    @response = http.request(request)
    add_message
    response.code == 200
  end

private

  attr_reader :http

  def add_message
    @message = case response.code
      when 200
        I18n.t("printing.success")
      when 423
        I18n.t("printing.unavailable")
      else
        I18n.t("printing.failure")
      end
  end

  def create_request
    @uri = URI.parse("#{self.site}/#{printer.uuid}")
    @http = Net::HTTP.new(uri.host, uri.port)
    @request = Net::HTTP::Post.new(uri.path, initheader = self.headers)
    @request.body = LabelPrinter.new(location).to_json
  end
end