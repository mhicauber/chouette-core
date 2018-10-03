class Aggregate < ActiveRecord::Base
  include OperationSupport

  belongs_to :workgroup

  validates :workgroup, presence: true

  after_commit :aggregate, :on => :create

  def parent
    workgroup
  end

  def aggregate
    update_column :started_at, Time.now
    update_column :status, :running

    AggregateWorker.perform_async(id)
  end

  def aggregate!
    update status: :successful, ended_at: Time.now
  end
end
