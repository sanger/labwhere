class DeleteRecord

  include ActiveModel::Model
  include HashAttributes

  attr_accessor :user_code
  attr_reader :controller, :action, :current_user, :record

  validate :check_user
  
  def initialize(record)
    @record = record
  end

  def destroy(params)
    set_attributes(params)
    @current_user = User.find_by_code(user_code)
    if valid?
      if record.destroy
        true
      else
        add_errors
        false
      end
    else
      false
    end
  end

private
  
  def check_user
    UserValidator.new.validate(self)
  end

  def add_errors
    record.errors.each do |key, value|
      errors.add key, value
    end
  end
end