class UpdatePurchaseWindowsColors < ActiveRecord::Migration
  def up
     Chouette::PurchaseWindow.where("color LIKE '#%'").update_all('color = right(color, -1)')
     Chouette::PurchaseWindow.where.not(color: nil).each &:update_checksum!
  end

  def down
     Chouette::PurchaseWindow.where("color NOT LIKE '#%'").update_all("color = '#' || color")
     Chouette::PurchaseWindow.where.not(color: nil).each &:update_checksum!
  end
end
