##
# Form object for creating or updating a Team
class TeamForm

  include Auditor

  set_attributes :name, :number

end