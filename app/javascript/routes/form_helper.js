const formHelper = {
  addInput: (name, value, index) => {
    let form = document.querySelector('form')
    let input = document.createElement('input')
    let formatedName = `route[stop_points_attributes][${index.toString()}][${name}]`
    input.setAttribute('type', 'hidden')
    input.setAttribute('name', formatedName)
    input.setAttribute('value', value)
    form.appendChild(input)
  },
  addError: (ids) => {
    ids.forEach((id) => {
      if (!$(id).parents('.form-group').hasClass('has-error')) {
        $(id).parents('.form-group').addClass('has-error')
        $(id).parent().append(`<span class='help-block small'>${'doit être rempli(e)'}</span>`)
      }
    })
  },
  cleanInputs: (ids) => {
    ids.forEach((id) =>{
      $(id).parents('.form-group').removeClass('has-error')
      $(id).siblings('span').remove()
    })
  },
  handleForm: (...ids) => {
    let filledInputs = []
    let blankInputs = []
    ids.forEach(id => {
      $(id).val() == "" ? blankInputs.push(id) : filledInputs.push(id)
    })

    if (filledInputs.length > 0) formHelper.cleanInputs(filledInputs)
    if (blankInputs.length > 0) formHelper.addError(blankInputs)
  },
  handleStopPoints: (event, state) => {
    if (state.stopPoints.length >= 2) {
      state.stopPoints.map((stopPoint, i) => {
        formHelper.addInput('id', stopPoint.stoppoint_id ? stopPoint.stoppoint_id : '', i)
        formHelper.addInput('stop_area_id', stopPoint.stoparea_id, i)
        formHelper.addInput('position', stopPoint.index, i)
        formHelper.addInput('for_boarding', stopPoint.for_boarding, i)
        formHelper.addInput('for_alighting', stopPoint.for_alighting, i)
      })
      if ($('.alert.alert-danger').length > 0) $('.alert.alert-danger').remove()
    }
    else {
      event.preventDefault()
      let msg = "L'itinéraire doit comporter au moins deux arrêts"
      if ($('.alert.alert-danger').length == 0) {
        $('#stop_points').find('.subform').after(`<div class='alert alert-danger'><span class='fa fa-lg fa-exclamation-circle'></span><span>${msg}</span></div>`)
      }
    }
  }
}

export default formHelper
