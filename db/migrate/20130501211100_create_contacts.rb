class CreateContacts < ActiveRecord::Migration
  def change
    create_table(:contacts) do |t|
      t.references :initiator     
      t.references :recipient     
      t.timestamps
    end
    add_index :contacts, :initiator_id
    add_index :contacts, :recipient_id
  end
end
