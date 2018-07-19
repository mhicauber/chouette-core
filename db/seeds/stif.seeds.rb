# coding: utf-8

require_relative 'seed_helpers'

stif = Organisation.seed_by(code: "STIF") do |o|
  o.name = 'STIF'
end

stop_area_referential = StopAreaReferential.seed_by(name: "Reflex") do |r|
  r.objectid_format = "stif_reflex"
  r.add_member stif, owner: true
end

line_referential = LineReferential.seed_by(name: "CodifLigne") do |r|
  r.objectid_format = "stif_codifligne"
  r.add_member stif, owner: true
end

workgroup = Workgroup.seed_by(name: "Gestion de l'offre théorique IDFm") do |w|
  w.line_referential      = line_referential
  w.stop_area_referential = stop_area_referential
  w.export_types          = ["Export::Netex"]
  w.owner                 = stif
end

stif.workbenches.seed_by(name: "Gestion de l'offre") do |w|
  w.line_referential      = line_referential
  w.stop_area_referential = stop_area_referential
  w.objectid_format       = Workbench.objectid_format.stif_netex
  w.workgroup             = workgroup
end
