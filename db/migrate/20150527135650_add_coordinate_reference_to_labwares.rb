# frozen_string_literal: true

class AddCoordinateReferenceToLabwares < ActiveRecord::Migration[4.2]
  def change
    add_reference :labwares, :coordinate, index: true, foreign_key: true
  end
end
