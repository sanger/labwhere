# frozen_string_literal: true

##
# Form object for creating a printer
class PrinterForm
  include AuthenticationForm
  include Auditor

  create_attributes :name
end
