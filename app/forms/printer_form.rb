##
# Form object for creating a printer
class PrinterForm

  include AuthenticationForm
  include AddAudit

  set_attributes :name, :uuid
  
end