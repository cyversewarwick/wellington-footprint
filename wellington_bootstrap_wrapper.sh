#!/bin/bash
set -e

#pre-process peaks
#we can have one or two peak files. which one we having?
cut -f -3 $1 > temp1.bed
../bedops/bin/bedops --range 50 --everything temp1.bed > temp1_2.bed
../bedops/bin/bedops --merge temp1_2.bed > processed_peaks.bed
rm temp1.bed
rm temp1_2.bed
#blank first file name
shift
#note the cheat. requires the iPlant app to take the .beds first
#and then take the .bams, with a --start flag to signify a new beginning
if [ $1 != '--start' ]
	then
		cut -f -3 $1 > temp2.bed
		../bedops/bin/bedops --range 50 --everything temp2.bed > temp2_2.bed
		../bedops/bin/bedops --merge processed_peaks.bed temp2_2.bed > processed_peaks.bed
		rm temp2.bed
		rm temp2_2.bed
		#blank second file name
		shift
fi
#at this point, the first argument is supposed to be the --start
if [ $1 != '--start' ]
	then
		echo "Error: You need to provide no more than two DHS site files. Exiting." >&2
		exit 1
fi
#if we're still here, then the first argument is indeed --start and we can proceed
shift

#run wellington.
#we need to run the indexing ourselves because yes
samtools index $1
samtools index $2
#hard pass in out_treatment1.bed and out_treatment2.bed as destinations
python ../scripts/wellington_bootstrap.py $1 $2 processed_peaks.bed out_treatment1.bed out_treatment2.bed ${@:3}

#unlike the previous analysis, now everything is handily placed in the root

#do two visualisations, for each possible file
mkdir treatment1_output_visualisation
#get the wiggle tracks
python ../scripts/dnase_wig_tracks.py processed_peaks.bed $1 treatment1_output_visualisation/fw_cuts.wig treatment1_output_visualisation/rv_cuts.wig
if [ -s out_treatment1.bed ]
	then
		#get the average profile thing
		python ../scripts/dnase_average_profile.py out_treatment1.bed $1 treatment1_output_visualisation/average_footprint.png
		#get the heatmap
		python ../scripts/dnase_to_javatreeview.py out_treatment1.bed $1 treatment1_output_visualisation/javatreeview_heatmap_ready.csv
fi
mkdir treatment2_output_visualisation
#get the wiggle tracks
python ../scripts/dnase_wig_tracks.py processed_peaks.bed $2 treatment2_output_visualisation/fw_cuts.wig treatment2_output_visualisation/rv_cuts.wig
if [ -s out_treatment2.bed ]
	then
		#get the average profile thing
		python ../scripts/dnase_average_profile.py out_treatment2.bed $2 treatment2_output_visualisation/average_footprint.png
		#get the heatmap
		python ../scripts/dnase_to_javatreeview.py out_treatment2.bed $2 treatment2_output_visualisation/javatreeview_heatmap_ready.csv
fi