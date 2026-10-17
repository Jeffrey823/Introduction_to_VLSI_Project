#############################################
#
# Script para sintesis
#
# Autor: Jeffrey Salas
#
#############################################

# remover diseño anterior
remove_design -designs

# Agregamos bibliotecas (librarys)
set target_library [ls ../libs/saed90nm_max.db]
set link_library [ls ../libs/saed90nm_max.db]

# Leer Verilog
# read_file -format verilog ../source/Micro8088.v
set verilog_files [ls ../source/*.v]
foreach file $verilog_files {
        puts "INFO: Reading verilog file $file"
        read_file -format verilog $file
}

# Se ejecuta Analyze
foreach file $verilog_files {
	puts "INFO: Analyzing verilog $file"
	analyze -format verilog $file
}

# Definir el top y hacemos elaborate
current_design Micro8088
elaborate Micro8088

# linking
link

# Guardar db inicial
write -hierarchy -format ddc -output ../dbs/diseno_precompile.ddc

#source constraints
source ../scripts/constraints.tcl
propagate_constraints

# Compile
check_design
compile_ultra

# Guardado Final
write -hierarchy -format ddc -output ../dbs/diseno_postcompile.ddc
set verilogout_no_tri true
change_names -hierarchy -rules verilog
write -hierarchy -format verilog -output ../dbs/diseno.v

write_sdc ../dbs/diseno.sdc
