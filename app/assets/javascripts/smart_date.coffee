
smartDateSelector       = '.smart_date'
smartDateSelectSelector = "#{smartDateSelector} select"
legalDaysPerMonth       = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

correctDay = (dateValues) ->
  [day, month, year] = dateValues
  return day if legalDaysPerMonth[month-1] >= day
  return 29 if day == 29 && isLeapYear(year)
  legalDaysPerMonth[month-1]

smartCorrectDate = ->
  allSelectors = $(@).parent().children('select') # N'a pas un sibbling('select', include_self = true) ?
  allVals      = allSelectors.map (index, sel) ->
    parseInt($(sel).val())
  correctedDay = correctDay allVals
  daySelector  = allSelectors.first()
  $(daySelector).val(correctedDay)

$ ->
  $(smartDateSelectSelector).on 'change', smartCorrectDate
