# frozen_string_literal: true

##
# Form object for creating a printer
class PrinterForm
  include AuthenticationForm
  include Auditor

  set_attributes :name
end
