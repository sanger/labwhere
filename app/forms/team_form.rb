# frozen_string_literal: true

##
# Form object for creating or updating a Team
class TeamForm
  include AuthenticationForm
  include Auditor

  create_attributes :name, :number
end
