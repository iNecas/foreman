class AddJsessionidToComputeResources < ActiveRecord::Migration
  def change
    add_column :compute_resources, :jsessionid, :string
  end
end
