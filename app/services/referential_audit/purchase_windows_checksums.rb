class ReferentialAudit
  class PurchaseWindowsChecksums < Base
    def perform logger
      foo = Chouette::PurchaseWindow.all.map{|p| p.update_checksum}.uniq
      if foo == [] || foo == [nil]
        @status = :success
      else
        logger.add_error "Found #{foo.size - 1} PurchaseWindows with inconsistent Checksums"
        @status = :error
      end
    end
  end
end
