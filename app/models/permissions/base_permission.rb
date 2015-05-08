module Permissions
  class BasePermission

    def initialize(user)
      @allowed_actions = {}
    end

    def allow?(controller, action, resource = nil)
      allowed = allow_all? || allowed_actions[[controller.to_s, action.to_s]]
      allowed && (allowed == true || resource && allowed.call(resource))
    end

    def allow_all
      @allow_all = true
    end

    def allow_all?
      @allow_all
    end

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