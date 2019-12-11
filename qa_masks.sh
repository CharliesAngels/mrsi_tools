# # ------------------------------------------------------------------------------
# Script name:  qa_masks.sh
#
# Description:  Script to threshold metabolite maps of interest by quality
#               assessment masks.
#
# Author:       Caroline Nettekoven, 2019
#
# ------------------------------------------------------------------------------
# Dependencies
raw=/home/fs0/leahm/scratch/Joystick_Cereb-MRS/Data/bidsdir/raw
drv=/home/fs0/leahm/scratch/Joystick_Cereb-MRS/Data/bidsdir/derivatives/
# ------------------------------------------------------------------------------
# QA Settings
FWHM=15         # Rejects FWHM above 15
SNR=30          # Rejects SNR below 50
CRLB=50         # Rejects CRLB above 50
# QA settings are the same as :
# Kolasinski 2017 Curr. Biol. http://dx.doi.org/10.1016/j.cub.2017.04.055
# ------------------------------------------------------------------------------


for SUB in M01 M02 M03 M04 M05 M06 M07 M08 M09 M10 M11 F03 F04 F05 F06; do
    echo ======================== $SUB ========================
    # Find subject's ID
    ID=` cat ${raw}/../../conditions.txt | grep ${SUB} | awk '{print $1}' `

    for COND in adapt control ; do
        echo ============ $COND ========

        for ACQ in base first second third ; do
            echo ============ $ACQ ========

            maps_folder=${raw}/${ID}/ses-${COND}/mrsi/${ACQ}_maps
            output_folder=${drv}/${ID}/ses-${COND}/mrsi/${ACQ}_maps
            cd ${output_folder}

            # Threshold QA maps
            fslmaths ${maps_folder}/FWHM           -uthr ${FWHM}    -bin    FWHM_thr${FWHM}_bin
            fslmaths ${maps_folder}/SNR            -thr ${SNR}      -bin    SNR_thr${SNR}_bin
            fslmaths ${maps_folder}/GABA_crlb      -uthr ${CRLB}    -bin    CRLB_thr${CRLB}_bin

            # Combine QA maps
            fslmaths FWHM_thr${FWHM}_bin -add SNR_thr${SNR}_bin QA_combined
            fslmaths QA_combined -add CRLB_thr${CRLB}_bin -thr 3 -bin QA

            map_of_interest=GABA_ratio
            fslmaths ${maps_folder}/${map_of_interest} -mas QA_combined ${map_of_interest}_QA

        done

    done
    echo " "

done
