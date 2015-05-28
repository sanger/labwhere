class AddCoordinateReferenceToLabwares < ActiveRecord::Migration
  def change
    add_reference :labwares, :coordinate, index: true, foreign_key: true
  end
end
