import '../../helpers/polyfills'

import MasterSlave from "../../helpers/master_slave"

new MasterSlave("form")

$(".destination input[name*=destroy]").change(function(e){
  $(e.target).parents('.destination').find('.fields').toggleClass('hidden-fields', e.target.checked)
  $(e.target).parents('.destination').find('input[name*=name]').attr('readonly', e.target.checked)
})
