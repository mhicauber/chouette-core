class JourneyPatternOfferService
  MIN_HOLE_SIZE = 3

  def initialize(journey_pattern)
    @journey_pattern = journey_pattern
  end

  def line
    @journey_pattern.line
  end

  def referential
    @referential || @journey_pattern.referential
  end

  def period_start
    @period_start || (compute_period && @period_start)
  end

  def period_end
    @period_end || (compute_period && @period_end)
  end

  def holes
    @holes ||= begin
      dates = circulated_dates
      previous_period = { finish: period_start.prev_day }
      dates.push(start: period_end.next)
      current_period = dates.shift
      holes = []
      while current_period
        if (current_period[:start] - previous_period[:finish]) > MIN_HOLE_SIZE
          holes << (previous_period[:finish].next...current_period[:start])
        end
        previous_period = current_period
        current_period = dates.shift
      end
      holes
    end
  end

  private

  def circulated_dates
    ActiveRecord::Base.connection.execute(query).map do |r|
      {
        start:  r['start'].to_date,
        finish: r['finish'].to_date,
        count:  r['val'].to_i
      }.tap do |item|
        item[:avg] = item[:count] / (item[:finish] - item[:start] + 1).to_f
      end
    end
  end

  def compute_period
    @period_start = nil
    @period_end = nil
    referential.metadatas.each do |m|
      if m.line_ids.include?(line.id)
        @period_start = [@period_start, m.periodes.map(&:min).min].compact.min
        @period_end = [@period_end, m.periodes.map(&:max).max].compact.max
      end
    end
  end

  def query
    <<-SQL
    WITH RECURSIVE dates AS (
      select CURRENT_DATE + i AS date
      from generate_series(#{(period_start - Time.now.to_date).to_i}, #{(period_end - Time.now.to_date).to_i}) i
    ), circulation_dates AS (
      SELECT dates.date, COUNT(DISTINCT(periods.id)) - COUNT(DISTINCT(excluded_dates.id)) + COUNT(DISTINCT(included_dates.id)) AS val
      FROM dates
        LEFT JOIN  #{referential.slug}.time_tables ON 1=1
        LEFT JOIN  #{referential.slug}."time_tables_vehicle_journeys" ON "time_tables_vehicle_journeys"."time_table_id" = "time_tables"."id"
        INNER JOIN #{referential.slug}."vehicle_journeys" ON "vehicle_journeys"."id" = "time_tables_vehicle_journeys"."vehicle_journey_id"
        INNER JOIN #{referential.slug}."journey_patterns" ON "vehicle_journeys"."journey_pattern_id" = "journey_patterns"."id"
        INNER JOIN #{referential.slug}."routes" ON "journey_patterns"."route_id" = "routes"."id"
        LEFT JOIN  #{referential.slug}."time_table_dates" AS excluded_dates ON excluded_dates."time_table_id" = "time_tables"."id" AND excluded_dates.date = dates.date AND excluded_dates.in_out = false
        LEFT JOIN  #{referential.slug}."time_table_dates" AS included_dates ON included_dates."time_table_id" = "time_tables"."id" AND included_dates.date = dates.date AND included_dates.in_out = true
        LEFT JOIN  #{referential.slug}."time_table_periods" AS periods ON periods."time_table_id" = "time_tables"."id" AND periods.period_start <= dates.date AND periods.period_end >= dates.date
      WHERE
        (included_dates.id IS NOT NULL OR (periods.id IS NOT NULL AND (time_tables.int_day_types & POW(2, ((DATE_PART('dow', dates.date)::int+6)%7)+2)::int) > 0))
        AND vehicle_journeys.journey_pattern_id = #{@journey_pattern.id}
      GROUP BY dates.date, vehicle_journeys.journey_pattern_id
      ORDER BY dates.date ASC
    ), aggregated_dates(start, finish, val) AS (
      SELECT circulation_dates.date, circulation_dates.date, circulation_dates.val from circulation_dates
      union all
      SELECT aggregated_dates.start, circulation_dates.date, circulation_dates.val + aggregated_dates.val
      FROM circulation_dates JOIN aggregated_dates ON circulation_dates.date = aggregated_dates.finish + 1
    ), ranges AS (
      SELECT MIN(aggregated_dates.start) AS start, aggregated_dates.finish, max(val) AS val FROM aggregated_dates GROUP BY aggregated_dates.finish ORDER BY MIN(aggregated_dates.start)
    )
    SELECT ranges.start, MAX(ranges.finish) AS finish, MAX(ranges.val) AS val FROM ranges GROUP BY ranges.start ORDER BY MIN(ranges.start)
    SQL
  end
end
