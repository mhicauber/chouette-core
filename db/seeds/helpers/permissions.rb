module Seed

  def self.all_features
    Feature.all
  end

  def self.base_permissions
    Permission.base
  end

  def self.extended_permissions
    Permission.extended
  end

  def self.referentials_permissions
    Permission.referentials
  end

  def self.all_permissions
    Permission.full
  end
end
