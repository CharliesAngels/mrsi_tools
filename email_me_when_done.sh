
# while [[ ! -f /home/fs0/leahm/scratch/Joystick_Cereb-MRS/Data/bidsdir/derivatives/results/mrsi_191118/PairedT_mrsi_second-third_tfce_corrp_tstat2.nii.gz ]]; do
while [[ ! -f PairedT_network14_diff_tfce_corrp_tstat2.nii.gz ]]; do
    echo Not finished. Checking again in 10 min...
    sleep 600
done
echo SCRIPT HAS FINISHED! Sending notification email...
# Leah's mailgun
curl -s --user 'api:YOUR-API' \
    https://api.mailgun.net/v3/sandbox-YOUR-CODE.mailgun.org/messages \
    -F from='Mailgun Sandbox <postmaster@sandbox-YOUR-CODE.mailgun.org>' \
    -F to=YOUR-EMAIL-ADDRESS \
    -F subject='Script has finished!' \
    -F text='Script has finished!'
