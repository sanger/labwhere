##
# The API does not need to protect against CSRF attacks
# If we did not pass a null session all api calls would fails as they do not contain the secret key.
class ApiController < ApplicationController

  protect_from_forgery with: :null_session

end