##
# Form object for creating or updating a Team
class TeamForm

  include AuthenticationForm

  set_attributes :name, :number

end