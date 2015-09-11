class Cgap < ActiveRecord::Base
  self.abstract_class = true
  establish_connection :cgap

end