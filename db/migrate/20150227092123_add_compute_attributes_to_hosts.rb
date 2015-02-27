class AddComputeAttributesToHosts < ActiveRecord::Migration
  def change
    add_column :hosts, :compute_attributes, :text
  end
end
