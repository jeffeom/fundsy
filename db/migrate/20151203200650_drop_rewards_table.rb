class DropRewardsTable < ActiveRecord::Migration
  def change
    def up
      drop_table :rewards
    end

    def down
      raise ActiveRecord::IrreversibleMigration
    end
  end
end
