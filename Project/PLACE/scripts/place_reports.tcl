####################################################################
#
# Reportes
#
# Autor: Jeffrey Salas
#
####################################################################

report_power 		> ../reports/power.txt
report_cell 		> ../reports/cell.txt
report_qor 		    > ../reports/qor.txt
report_clocks 		> ../reports/clocks.txt
report_utilization 	> ../reports/utilization.txt
report_port 		> ../reports/ports.txt
report_supply_nets 	> ../reports/power_nets.txt
report_timing -max_paths 20 -delay_type max > ../reports/timing_setup.txt
report_timing -max_paths 20 -delay_type min > ../reports/timing_hold.txt

