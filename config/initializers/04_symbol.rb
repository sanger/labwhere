# frozen_string_literal: true

class Symbol
  def pluralize
    to_s.pluralize.to_sym
  end
end
