module AuthenticationForm

  extend ActiveSupport::Concern

  included do
    include FormObject

    set_form_variables :user_code, current_user: :find_current_user

    validate :check_user

  end

private

  def find_current_user
    User.find_by_code(user_code)
  end

  def check_user
    UserValidator.new.validate(self)
  end

end