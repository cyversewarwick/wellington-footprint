#!/bin/bash
set -e

#pre-process peaks
cut -f -3 $1 > temp.bed
../bedops/bin/bedops --range 50 --everything temp.bed > temp2.bed
../bedops/bin/bedops --merge temp2.bed > processed_peaks.bed
rm temp.bed
rm temp2.bed

#run wellington.
#note that we need to make the directory ourselves because yes
#we also need to run the indexing ourselves because yes
mkdir analysis
samtools index $2
python ../scripts/wellington_footprints.py processed_peaks.bed $2 analysis ${@:3}

#move wellington run contents into main folder
mv analysis/* .
rmdir analysis

#get the average profile thing
mkdir output_visualisation
python ../scripts/dnase_average_profile.py WellingtonFootprints.FDR.bed $2 output_visualisation/average_footprint.png

#get the heatmap
python ../scripts/dnase_to_javatreeview.py WellingtonFootprints.FDR.bed $2 output_visualisation/javatreeview_heatmap_ready.csv

#get the wiggle tracks
python ../scripts/dnase_wig_tracks.py processed_peaks.bed $2 output_visualisation/fw_cuts.wig output_visualisation/rv_cuts.wig

#wipe out tempfiles
rm *.bam.bai
rm processed_peaks.bed