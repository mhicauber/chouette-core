class ComplianceCheckSetObserver < NotifiableOperationObserver
  def email_sendable_for?(ccset)
    return false unless ccset.context == 'manual'

    super
  end
end
