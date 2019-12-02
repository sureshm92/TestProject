@echo off
echo Push in progress...
call sfdx force:source:push -f

if %ERRORLEVEL% == 0 (
    echo Post setup in progress...
    call sfdx force:apex:execute -f scripts/apex/SFDX_Setup_UpdateUserRole.apex

    call sfdx force:data:tree:import -p data/import-plan.json

    call sfdx force:apex:execute -f scripts/apex/SFDX_Setup_UpdateSSAndHCPEStatuses.apex

    call sfdx force:user:permset:assign --permsetname PP_Approved_Languages_Edit
    call sfdx force:user:permset:assign --permsetname PP_CTP_Edit
    call sfdx force:user:permset:assign --permsetname PP_Manual_Creation_Panel
    call sfdx force:user:permset:assign --permsetname PP_StudySite_Edit
    call sfdx force:user:permset:assign --permsetname PP_Study_Resources_Edit
    call sfdx force:user:permset:assign --permsetname PP_Travel_Vendors_Edit
    call sfdx force:user:permset:assign --permsetname PP_Trial_Surveys_Edit
    call sfdx force:user:permset:assign --permsetname PP_Visits_Configuration_Edit
    call sfdx force:user:permset:assign --permsetname PP_Visits_Results_Sharing_Edit
    call sfdx force:user:permset:assign --permsetname Patient_Portal_Edit_Study_Settings
    call sfdx force:user:permset:assign --permsetname PP_Admin_Panel
    call sfdx force:user:permset:assign --permsetname PP_Participant_BL
    call sfdx force:user:permset:assign --permsetname SurveyCreator

    echo Push completed successfully!
) else (echo Push not completed properly, check logs and try again)