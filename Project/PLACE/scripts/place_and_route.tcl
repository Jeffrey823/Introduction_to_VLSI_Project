####################################################################################
#
# Script para Placement y Route optimizado
#
# Autor: Jeffrey Salas
#
####################################################################################

# Base de datos
create_lib ../dbs/diseno.ndm -ref_libs ../libs/my_ref_lib.ndb
create_block diseno

# Agregar el diseno
read_verilog ../source/diseno.v -top Micro8088
uniquify
link

# Crear el floorplan
initialize_floorplan -control_type core -core_utilization 0.90 -shape R \
-side_length {450 253}
read_parasitic_tech -tlup ../libs/saed90nm_1p9m_1t_nominal.tluplus

report_tracks > ../reports/tracks.txt

# Bloqueo de ruta de senales de M5 hasta M9
create_routing_blockage \
-layers {M5 M6 M7 M8 M9} \
-boundary {{0 0} {450 253}} \
-net_types {signal}

# Power
create_net -power VDD
create_net -ground VSS
create_power_domain VCC
create_supply_net VDD -domain VCC
create_supply_net VSS -domain VCC
create_supply_port VDD -domain VCC
create_supply_port VSS -domain VCC
connect_supply_net VDD -ports VDD
connect_supply_net VSS -ports VSS

set_domain_supply_net VCC -primary_power_net VDD -primary_ground_net VSS
commit_upf

# Revisar y conectar power
resolve_pg_nets
connect_pg_net -auto

# Crear Power mesh
create_pg_mesh_pattern power_mesh -layer { \
 {{vertical_layer M6} {width:1} {spacing: interleaving} {pitch:24}} \
 {{vertical_layer M6} {width:1} {spacing: interleaving} {pitch:24}} \
 {{horizontal_layer M5} {width:1} {spacing: interleaving} {pitch:24}} \
}

set_pg_strategy my_strat -core -pattern \
 {{name: power_mesh} {nets: {VDD VSS}}} \
 -extension {{stop: design_boundary}}

compile_pg -strategies my_strat

# Save_lib
save_lib

# Constraints
source ../scripts/constraints.tcl

# Place a puertos
place_pins -ports [get_ports]

# Placement
reset_placement -spread_cells
set_app_options -name place.coarse.fix_hard_macros -value false
set_app_options -name plan.place.auto_create_blockages -value auto
create_placement -floorplan
legalize_placement

# Constraints de optimizacion
set_voltage 0.70 -corners default -object_list [get_supply_nets VDD]
set_parasitic_parameters \
-early_spec ../libs/saed90nm_1p9m_1t_nominal.tluplus -early_temperature 125 \
-late_spec ../libs/saed90nm_1p9m_1t_nominal.tluplus -late_temperature 125

# Reglas de clocking
set_clock_routing_rules -default_rule \
-max_routing_layer M5 \
-min_routing_layer M4

# Configuracion para evitar scan
set_app_options -name place.coarse.continue_on_missing_scandef -value true

# Optimization
place_opt
clock_opt

# Routing
route_global
route_auto

route_opt

# Save
save_lib



