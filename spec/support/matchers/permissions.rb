RSpec::Matchers.define :allow_permission do |*args|
  match do |permission|
    expect(permission.allow?(*args)).to be_truthy
  end
end