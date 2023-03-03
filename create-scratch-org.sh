#!/bin/sh
#v2.8 PP-13.0 RH-15.0
echo "Clean up previous scratch org"
sfdx force:org:delete -p

echo "Modifying files for scratch org"
echo "Step 1 - Move current files to scratch-org-files/original-files"
sed -i 's/IQVIA_Referral_Hub_C/IQVIA_Referral_Hub1/g' 'force-app/communities/community-iqvia/networks/IQVIA Referral Hub.network-meta.xml'
sed -i 's/#force-app\/main\/default\/flows/force-app\/main\/default\/flows/g' '.forceignore'
sed -i 's/#force-app\/main\/default\/profiles\/PRDBAPI/force-app\/main\/default\/profiles\/PRDBAPI/g' '.forceignore'

if [ "$(ls -A ./scratch-org-files/original-files)" ]
then
    rm -rf ./scratch-org-files/original-files
else
     echo "Empty directory, continue..."
fi

mv ./force-app/communities/community-iqvia/experiences ./scratch-org-files/original-files
mv ./force-app/communities/community-gsk/sites/GSK_Community.site-meta.xml ./scratch-org-files/original-files
mv ./force-app/communities/community-iqvia/sites/IQVIA_Referral_Hub.site-meta.xml ./scratch-org-files/original-files
mv ./force-app/communities/community-janssen/sites/Janssen_Community.site-meta.xml ./scratch-org-files/original-files
mv ./force-app/main/default/profiles/Business\ Administrator.profile-meta.xml ./scratch-org-files/original-files
mv ./force-app/main/default/profiles/Business\ Lead.profile-meta.xml ./scratch-org-files/original-files
mv ./force-app/main/default/profiles/IQVIA\ Customer\ Community\ Plus\ Login\ User.profile-meta.xml ./scratch-org-files/original-files
mv ./force-app/main/default/profiles/IQVIA\ SPNL2.profile-meta.xml ./scratch-org-files/original-files
mv ./force-app/main/default/profiles/Product\ Owner.profile-meta.xml ./scratch-org-files/original-files
mv ./force-app/main/default/workflows/Participant_Enrollment__c.workflow-meta.xml ./scratch-org-files/original-files

echo "Step 2 - Move backup files the project directory"
mv ./scratch-org-files/experiences ./force-app/communities/community-iqvia
mv ./scratch-org-files/GSK_Community.site-meta.xml ./force-app/communities/community-gsk/sites
mv ./scratch-org-files/IQVIA_Referral_Hub.site-meta.xml ./force-app/communities/community-iqvia/sites
mv ./scratch-org-files/Janssen_Community.site-meta.xml ./force-app/communities/community-janssen/sites
mv ./scratch-org-files/Business\ Administrator.profile-meta.xml ./force-app/main/default/profiles
mv ./scratch-org-files/Business\ Lead.profile-meta.xml ./force-app/main/default/profiles
mv ./scratch-org-files/IQVIA\ Customer\ Community\ Plus\ Login\ User.profile-meta.xml ./force-app/main/default/profiles
mv ./scratch-org-files/IQVIA\ SPNL2.profile-meta.xml ./force-app/main/default/profiles
mv ./scratch-org-files/Product\ Owner.profile-meta.xml ./force-app/main/default/profiles
mv ./scratch-org-files/Participant_Enrollment__c.workflow-meta.xml ./force-app/main/default/workflows

echo "Move communities"
mv ./force-app/communities ./

echo "Creating scratch org..."
sfdx force:org:create -f config/project-scratch-def.json -d 30 -s -a $1

echo "Creating OrgWideEmailSddresses..."
sfdx force:data:tree:import -f data/OrgWideEmailAddresses.json

#Reduce component size
echo "Deploying static files..."
sfdx force:org:open -p 'lightning/setup/DeployStatus/home'
sfdx force:source:deploy -p "force-app/main/onboarding-tour,force-app/main/default/staticresources" --tracksource
sfdx force:source:deploy -p "force-app/unpackaged/main/default/staticresources,force-app/main/default/namedCredentials,force-app/main/default/remoteSiteSettings,force-app/main/default/cspTrustedSites,force-app/main/default/labels" --tracksource

if [ $? = 0 ]; 
then
    echo "Pushing project in progress..."
    sfdx force:source:push -f -w 100

    if [ $? = 0 ]; 
    then
        echo "Return communities"
        mv ./communities ./force-app/
        
        echo "Post setup in progress..."
        
        sfdx force:source:push -f -w 100

        sfdx force:apex:execute -f scripts/apex/SFDX_Setup_UpdateUserRole.apex

        sfdx force:data:tree:import -p data/import-plan.json

        sfdx force:apex:execute -f scripts/apex/SFDX_Setup_UpdateSSAndHCPEStatuses.apex

        sfdx force:apex:execute -f scripts/apex/PostSetupBatches.apex

    #    echo "Publish communities..."
    #    sfdx force:community:publish --name "IQVIA Referral Hub"
    #    sfdx force:community:publish --name "GSK Community"

        echo "Assign permissions to admin user..."
        sfdx force:user:permset:assign --permsetname PP_Approved_Languages_Edit
        sfdx force:user:permset:assign --permsetname PP_Batch_Control_Panel
        sfdx force:user:permset:assign --permsetname PP_CTP_Edit
        sfdx force:user:permset:assign --permsetname PP_Manual_Creation_Panel
        sfdx force:user:permset:assign --permsetname PP_Message_Configuration_Edit
        sfdx force:user:permset:assign --permsetname PP_Motivational_Messages_Edit
        sfdx force:user:permset:assign --permsetname PP_Participant_BL
        sfdx force:user:permset:assign --permsetname PP_Participant_Non_PIII_View
        sfdx force:user:permset:assign --permsetname PP_Participant_PII_Edit
        sfdx force:user:permset:assign --permsetname PP_Participant_PII_On_Cases_View
        sfdx force:user:permset:assign --permsetname PP_Payment_Vendors_Edit
        sfdx force:user:permset:assign --permsetname PP_StudySite_Edit
        sfdx force:user:permset:assign --permsetname PP_Study_Resources_Edit
        sfdx force:user:permset:assign --permsetname PP_Toggle_Feature_Delta_Edit
        sfdx force:user:permset:assign --permsetname PP_Travel_Vendors_Edit
        sfdx force:user:permset:assign --permsetname PP_Trial_Surveys_Edit
        sfdx force:user:permset:assign --permsetname PP_Visits_Configuration_Edit
        sfdx force:user:permset:assign --permsetname PP_Visits_Results_Sharing_Edit
        sfdx force:user:permset:assign --permsetname Patient_Portal_Edit_Study_Settings
        sfdx force:user:permset:assign --permsetname SurveyCreator

        echo "Push completed successfully, discard all the file changes!"
    else
        echo "Return communities"
        mv ./communities ./force-app/
        
        echo "Push not completed properly, check logs and try again"
    fi
else
    echo "Error in deploying static files, resolve deployment errors and try again!"
fi
