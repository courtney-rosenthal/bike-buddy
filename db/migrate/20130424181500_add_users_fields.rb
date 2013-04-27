class AddUsersFields < ActiveRecord::Migration
  def change
    add_column :users, :name, :string, :limit => 30
    add_column :users, :is_enabled, :boolean
    add_column :users, :is_experienced, :boolean
    add_column :users, :contact_opt_in, :boolean
    add_column :users, :phone, :string, :limit => 20
    add_column :users, :origination_address, :string, :limit => 120
    add_column :users, :origination_latitude, :float, :precision => 10, :scale => 6
    add_column :users, :origination_longitude, :float, :precision => 10, :scale => 6
    add_column :users, :destination_address, :string, :limit => 120
    add_column :users, :destination_latitude, :float, :precision => 10, :scale => 6
    add_column :users, :destination_longitude, :float, :precision => 10, :scale => 6
    add_column :users, :schedule, :string, :limit => 120
    add_column :users, :user_note, :string, :limit => 120
  end
end

