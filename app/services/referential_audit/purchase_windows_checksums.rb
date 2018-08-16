class ReferentialAudit
  class PurchaseWindowsChecksums < Base
    def find_faulty
      faulty = []
      Chouette::PurchaseWindow.find_each do |p|
        faulty << p if p.set_current_checksum_source && p.update_checksum
      end
      faulty
    end

    def message record
      "PurchaseWindow ##{record.id} has inconsistent checksum"
    end
  end
end
