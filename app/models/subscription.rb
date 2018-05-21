# coding: utf-8
class Subscription
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :organisation_name, :user_name, :email, :password, :password_confirmation

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

  def user
    @user ||= organisation.users.build name: user_name, email: email, password: password, password_confirmation: password_confirmation
  end

  def organisation
    @organisation ||= Organisation.new name: organisation_name
  end

  def valid?
    @valid = !@valid.nil? ? @valid : begin
      unless organisation.valid?
        organisation.errors[:name].each do |e|
          errors.add(:organisation_name, e)
        end
      end
      unless user.valid?
        %i{user_name password password_confirmation email}.each do |attribute|
          user.errors[attribute].each do |e|
            errors.add attribute, e
          end
        end
      end
      errors.empty?
    end
  end

  def line_referential
    @line_referential ||= LineReferential.create!(name: LineReferential.ts) do |referential|
      referential.add_member organisation, owner: true
      referential.objectid_format = :netex
      referential.sync_interval = 1 # XXX is this really useful ?
    end
  end

  def stop_area_referential
    @stop_area_referential ||= StopAreaReferential.create!(name: StopAreaReferential.ts) do |referential|
      referential.add_member organisation, owner: true
      referential.objectid_format = :netex
    end
  end

  def workgroup
    @workgroup ||= Workgroup.create!(name: Workgroup.ts) do |w|
      w.line_referential      = line_referential
      w.stop_area_referential = stop_area_referential
    end
  end

  def create_workbench!
    @workbench ||= organisation.workbenches.create!(name: Workbench.ts) do |w|
      w.line_referential      = line_referential
      w.stop_area_referential = stop_area_referential
      w.workgroup             = workgroup
      w.objectid_format       = 'netex'
    end
  end

  def save
    if valid?
      ActiveRecord::Base.transaction do
        organisation.save!
        user.save!

        create_workbench!
      end
    end
    valid?
  end

end
