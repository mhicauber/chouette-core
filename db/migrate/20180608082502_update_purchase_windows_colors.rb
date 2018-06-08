class UpdatePurchaseWindowsColors < ActiveRecord::Migration
  def up
     Chouette::PurchaseWindow.where("color LIKE '#%'").update_all('color = right(color, -1)')
  end

  def down
     Chouette::PurchaseWindow.where("color NOT LIKE '#%'").update_all("color = '#' || color")
  end
end
