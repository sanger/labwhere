# frozen_string_literal: true

# Symbol extension
class Symbol
  def pluralize
    to_s.pluralize.to_sym
  end
end
