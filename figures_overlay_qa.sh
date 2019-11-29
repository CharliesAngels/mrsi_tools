local_stem=/Users/CN/Documents/Joystick_Cereb_MRS/MRSIanalysis/
SUITDIR=/Users/CN/Documents/Joystick_Cereb_MRS/MRSIanalysis/spm12/toolbox/suit
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
output=overlay_finalsample
inputlist=final_sample
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

# Get subject list of final sample
ls ${local_stem}/bidsdir/derivatives/*/ses-*/mrsi/base/qa/QA_GABA_sstd.nii* > ${local_stem}/bidsdir/code/${inputlist}.txt
# Remove subject M03 (sub-03) and subject F01 (sub-12)
sed -i.bak '/sub-03/d' ${local_stem}/bidsdir/code/${inputlist}.txt
sed -i.bak '/sub-12/d' ${local_stem}/bidsdir/code/${inputlist}.txt
# ------------------------------------------------------------------------------

fslmaths $SUITDIR/atlasesSUIT/SUIT.nii -thr -2 -uthr -1 -bin ${local_stem}/bidsdir/derivatives/${output}
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

fsleyes $SUITDIR/atlasesSUIT/SUIT.nii ${local_stem}/bidsdir/derivatives/${output} -cm red-yellow &

# Take screenshot at 91 | 41 | 44 with cm cool
