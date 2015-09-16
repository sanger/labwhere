if Rails.env.development?  || Rails.env.staging?
  Dir[File.join(Rails.root,"lib","cgap","models","*.rb")].each { |f| require f }
end
