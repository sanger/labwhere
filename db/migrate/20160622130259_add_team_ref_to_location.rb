class AddTeamRefToLocation < ActiveRecord::Migration[4.2]
  def change
    add_reference :locations, :team, index: true, foreign_key: true
  end
end
