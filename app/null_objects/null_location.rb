# frozen_string_literal: true

# Null object for location
class NullLocation
  # will always have name Empty
  def name; "Empty" end

  # will always have barcode Empty
  def barcode; "Empty" end

  # will never have a parent
  def parent; nil end

  # will never be valid
  def valid?; false end

  # will always be empty
  def empty?; true end

  def marked_for_destruction?; false end

  def unknown?; false end

  def unspecified?; true end

  def path; [] end
end
