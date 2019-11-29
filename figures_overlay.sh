local_stem=/Users/CN/Documents/Joystick_Cereb_MRS/MRSIanalysis/
SUITDIR=/Users/CN/Documents/Joystick_Cereb_MRS/MRSIanalysis/spm12/toolbox/suit
# ------------------------------------------------------------------------------
# Register all voxinVOI to T1
for i in ${local_stem}/bidsdir/derivatives/*/ses-*/mrsi/base/T1.nii; do
    cd ${i%T1.nii}

    for map in voxInVOI.nii.gz; do
        flirt \
            -in ${map} \
            -ref T1.nii \
            -out ${map%*.nii.gz}_T1 \
            -usesqform \
            -applyxfm \
            -noresampblur \
            -interp nearestneighbour \
            -setbackground 0 \
            -paddingsize 1
    done
done
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# Register all voxinVOI_T1 to MNI
ls ${local_stem}/bidsdir/derivatives/*/ses-*/mrsi/base/voxInVOI_T1.nii.gz
# In matlab: Run process_all_suit.m step 3: reslice into SUIT space using DARTEL (line 33 - 77)
ls ${local_stem}/bidsdir/derivatives/*/ses-*/mrsi/base/voxInVOI_T1_sstd.nii

# For the two subjects where suit linear registrations failed and I had to come up with an FSL workaround: Run the section below
image_to_resample=../../mrsi/base/voxInVOI_T1
while read troubled_subject; do
    SUB=`echo ${troubled_subject} | awk '{print $1}'`
    COND=`echo ${troubled_subject} | awk '{print $2}'`
    echo ${SUB} ${COND}
    cd /Users/CN/Documents/Joystick_Cereb_MRS/MRSIanalysis/bidsdir/derivatives/${SUB}/ses-${COND}/anat/suit_T1/
    # Remove potential faulty images that process_all_suit.m script might have created
    if [[ -f ${image_to_resample}.nii ]]; then
        rm ${image_to_resample}.nii
    fi
    applywarp \
        --in=${image_to_resample} \
        --ref=/Users/CN/Documents/Joystick_Cereb_MRS/MRSIanalysis/spm12/toolbox/suit/templates/SUIT.nii \
        --out=${image_to_resample%*.nii.gz}_sstd \
        --warp=u_a_T1_biascorr_seg1_to_SUIT_fsl_withmatrix.nii \
        --premat=Affine_fsl_seg1.mat
done < /Users/CN/Documents/Joystick_Cereb_MRS/MRSIanalysis/suit_troubleshooting.txt

ls ${local_stem}/bidsdir/derivatives/*/ses-*/mrsi/base/voxInVOI_T1_sstd.nii* | wc
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
overlay_image=voxInVOI_T1_sstd
output=overlay_finalsample_raw
inputlist=final_sample
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

# Get subject list of final sample
ls ${local_stem}/bidsdir/derivatives/*/ses-*/mrsi/base/${overlay_image}.nii* > ${local_stem}/bidsdir/code/${inputlist}.txt
# Remove subject M03 (sub-03) and subject F01 (sub-12)
sed -i.bak '/sub-03/d' ${local_stem}/bidsdir/code/${inputlist}.txt
sed -i.bak '/sub-12/d' ${local_stem}/bidsdir/code/${inputlist}.txt
# ------------------------------------------------------------------------------
fslmaths $SUITDIR/atlasesSUIT/SUIT.nii -add 1 -bin ${local_stem}/bidsdir/derivatives/${output}
# ------------------------------------------------------------------------------

# for i in `ls ${local_stem}/bidsdir/derivatives/*/ses-*/mrsi/base/qa/QA_GABA_sstd.nii*`; do
while read i; do
    Min=`fslstats $i -R | awk '{print $1}'`
    Max=`fslstats $i -R | awk '{print $2}'`
    if [[  "${Min}" == 0.000000 ]] & [[  "${Max}" == 1.000000 ]]; then
        Add_mask=true
    elif [[  "${Min}" == nan ]] & [[  "${Max}" == nan ]]; then
        Add_mask=true;
    else echo dimensions incorrect for $i: ${Min} ${Max};
        Add_mask=false
    fi

    if [[ -f ${i}.gz ]]; then
        rm ${i}.gz
    fi
    if ${Add_mask}; then
        echo adding subject mask...
        fslmaths ${local_stem}/bidsdir/derivatives/${output} \
         -add $i \
         ${local_stem}/bidsdir/derivatives/${output}

     fi
done <${local_stem}/bidsdir/code/${inputlist}.txt
cd ${local_stem}

fsleyes -vl 91 41 44 $SUITDIR/atlasesSUIT/SUIT.nii ${local_stem}/bidsdir/derivatives/${output} -dr 1 30 -cm cool &
fsleyes -vl 100 45 45 $FSLDIR/data/standard/MNI152_T1_1mm_brain.nii.gz ${local_stem}/bidsdir/derivatives/${output} -dr 1 30 -cm cool &

# Take screenshot at 91 | 41 | 44 with cm cool

fslcc -t 0.001 /Users/CN/Documents/Joystick_Cereb_MRS/MRSIanalysis//bidsdir/derivatives/overlay_finalsample_raw.nii.gz \
$SUITDIR/atlasesSUIT/AFNI_SUITCerebellum/Cerebellum-SUIT.nii.gz
fsleyes  /Users/CN/Documents/Joystick_Cereb_MRS/MRSIanalysis//bidsdir/derivatives/overlay_finalsample_raw.nii.gz $SUITDIR/atlasesSUIT/AFNI_SUITCerebellum/Cerebellum-SUIT.nii.gz
