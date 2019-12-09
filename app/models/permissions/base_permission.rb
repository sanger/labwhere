# frozen_string_literal: true

##
# maintains the allowed actions for a Permission object
# usage:
#  class InheritedPermission < BasePermission
#   def initialize
#    super
#    allow :any_old, [:action]
#   end
#  end
#
#  p = InheritedPermission.new
#  p.allow?(:any_old, :action) => true
#
module Permissions
  class BasePermission
    ##
    # create an empty allowed action object
    def initialize(_user)
      @allowed_actions = {}
    end

    ##
    # is this action allowed?
    # check whether the permission:
    # * allows anything
    # * allows the particular action by checking the allowed actions
    #
    # A block can also be added which can allow finer grained permissions based on objects
    # attached to particular users.
    def allow?(controller, action, resource = nil)
      allowed = allow_all? || allowed_actions[[controller.to_s, action.to_s]]
      allowed && (allowed == true || resource && allowed.call(resource))
    end

    ##
    # force the permission can allow anything
    def allow_all
      @allow_all = true
    end

    ##
    # will the permission allow anything?
    def allow_all?
      @allow_all
    end

    ##
    # add allowed actions to the permission object
    def allow(controllers, actions, &block)
      Array(controllers).each do |controller|
        Array(actions).each do |action|
          @allowed_actions[[controller.to_s, action.to_s]] = block || true
        end
      end
    end

    private

    attr_reader :allowed_actions
  end
end
