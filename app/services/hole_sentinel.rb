class HoleSentinel
  def initialize(workbench)
    @workbench = workbench
  end

  def incoming_holes
    holes = {}

    return holes unless referential.present?

    referential.switch do
      referential.lines.each do |line|
        line_holes = Stat::JourneyPatternCoursesByDate.holes_for_line(line)

        # first we check that the next hole is soon enough for us to care about
        next unless line_holes.exists?
        next unless line_holes.first.date <= days_ahead.since

        # then we check that we have N consecutive 'no circulation' days
        next unless line_holes.offset(min_hole_size).first&.date == line_holes.first.date + min_hole_size

        holes[line.id] = line_holes.first.date
      end
    end
    holes
  end

  protected

  def referential
    @workbench.output.current
  end

  def min_hole_size
    3
  end

  def days_ahead
    7.days
  end
end
