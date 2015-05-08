require "rails_helper"

RSpec.describe Permissions::AdminPermission, type: :model do

  let(:permissions) { Permissions.permission_for(build(:admin)) }

  it "should allow access to anything" do
    expect(permissions).to allow(:any, :thing)
  end

  it "should be able to modify a resource" do
    expect(permissions).to allow(:location, :create)
  end

end