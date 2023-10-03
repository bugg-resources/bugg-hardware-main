#!/usr/bin/env fish
set project_name    bugg-main-r5
set project_dir     ./src
set board_file      $project_dir/$project_name.kicad_pcb
set schematic_file  $project_dir/$project_name.kicad_sch
set output_dir      ./build
set fab_dir         $output_dir/$project_name-fabrication
set assy_dir        $output_dir/$project_name-assembly
set bom_dir         $output_dir/$project_name-bom

set layers        F.Cu,B.Cu,In1.Cu,In2.Cu,In3.Cu,In4.Cu,F.Silkscreen,B.Silkscreen,F.Mask,B.Mask,F.Paste,B.Paste,Edge.Cuts,User.1
set bom_fields "Reference,Value,Voltage,Tempco,Tolerance,Footprint,Manufacturer,MPN,Mouser,Digikey,\${QUANTITY}" 
set bom_labels "Reference,Value,Voltage,Tempco,Tolerance,Footprint,Manufacturer,MPN,Mouser,Digikey,Qty" 
set bom_groupby "Value"

echo Removing existing data
rm -rf $output_dir
echo Creating file tree
mkdir -p $fab_dir
mkdir -p $assy_dir
mkdir -p $bom_dir

echo Plotting gerbers:
kicad-cli-nightly pcb export gerbers --output $fab_dir/ --layers $layers $board_file
echo 
echo Plotting drills:
kicad-cli-nightly pcb export drill --output $fab_dir/ $board_file --excellon-separate-th

echo 
echo Printing component placements:
kicad-cli-nightly pcb export pos --output $assy_dir/$project_name-top.pos --units mm --use-drill-file-origin --exclude-dnp src/bugg-main-r5.kicad_pcb --side front
kicad-cli-nightly pcb export pos --output $assy_dir/$project_name-bottom.pos --units mm --use-drill-file-origin --exclude-dnp src/bugg-main-r5.kicad_pcb --side back

echo
echo Printing BoM:
kicad-cli-nightly sch export bom --output $bom_dir/$project_name.csv --fields $bom_fields --labels $bom_labels --group-by $bom_groupby --ref-range-delimiter \"\" $schematic_file

