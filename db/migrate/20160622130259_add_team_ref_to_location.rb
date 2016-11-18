class AddTeamRefToLocation < ActiveRecord::Migration
  def change
    add_reference :locations, :team, index: true, foreign_key: true
  end
end
