class CreateLocationTypesRestrictionJoinTable < ActiveRecord::Migration
  def change
    create_join_table :location_types, :restrictions do |t|
      # t.index [:location_type_id, :restriction_id]
      t.index [:restriction_id, :location_type_id], unique: true, name: "restriction_id_and_location_type_id_index"
    end
  end
end
