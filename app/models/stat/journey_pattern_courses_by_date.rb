module Stat
  class JourneyPatternCoursesByDate < ActiveRecord::Base
    belongs_to :journey_pattern, class_name: "Chouette::JourneyPattern"
    belongs_to :route, class_name: "Chouette::Route"
    belongs_to :line, class_name: "Chouette::Line"

    scope :for_journey_pattern, ->(journey_pattern) { where(journey_pattern_id: journey_pattern.id) }
    scope :for_line, ->(line) { where(line_id: line.id) }
    scope :for_route, ->(route) { where(route_id: route.id) }
    scope :notifiable, -> (workbench) { where.not(date: workbench.notification_rules.pluck(:period)) }

    def self.compute_for_referential(referential)
      Chouette::Benchmark.log "JourneyPatternCoursesByDate computation" do
        referential.switch do
          JourneyPatternCoursesByDate.delete_all
          ActiveRecord::Base.cache do
            ActiveRecord::Base.transaction do
              referential.journey_patterns.select(:id, :route_id).find_each do |journey_pattern|
                populate_for journey_pattern, referential: referential
                fill_blanks_for journey_pattern
              end
            end
          end
        end
      end
    end

    def self.populate_for(journey_pattern, referential: nil)
      route_id = journey_pattern.route_id
      line_id = journey_pattern.route.line_id

      JourneyPatternCoursesByDate.bulk_insert do |worker|
        JourneyPatternOfferService.new(
          journey_pattern,
          referential: referential
        ).circulation_dates.each do |date, count|
          worker.add(
            journey_pattern_id: journey_pattern.id,
            route_id: route_id,
            line_id: line_id,
            date: date,
            count: count
          )
        end
      end
    end

    def self.fill_blanks_for(journey_pattern)
      scope = for_journey_pattern(journey_pattern)
      return unless scope.exists?

      previous_date = scope.first.date
      route_id = journey_pattern.route_id
      line_id = journey_pattern.route.line_id
      JourneyPatternCoursesByDate.bulk_insert do |worker|
        scope.order('date ASC').each do |stat|
          while previous_date < stat.date - 1
            previous_date = previous_date.next
            worker.add(
              date: previous_date,
              count: 0,
              journey_pattern_id: journey_pattern.id,
              route_id: route_id,
              line_id: line_id
            )
          end
          previous_date = stat.date
        end
      end
    end

    def self.holes_for_line line
      for_line(line).group('date, line_id').having('SUM(count) = 0').select(:date).order(:date)
    end
  end
end
