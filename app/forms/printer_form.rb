##
# Form object for creating a printer
class PrinterForm

  include AuthenticationForm

  set_attributes :name, :uuid
  
end