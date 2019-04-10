echo "deleting old scratch org..."

sfdx force:org:delete -u scratch --noprompt

echo "creating scratch org..."

sfdx force:org:create -s -f config/project-scratch-def.json -a scratch -d 30

cd ant

ant convert-workflow-DX

cd ..

sfdx force:org:open -u scratch

echo "Pushing metadata..."

sfdx force:source:push -u scratch

sfdx force:apex:execute -f DxPostInstall.apex -u scratch

echo "apex execution completed"

sfdx force:data:tree:import -f data/OrgWideEmailAddresses.json

sfdx force:data:tree:import -p data/import-plan.json

echo "import completed"

git checkout -- force-app/main/default/workflows/Participant_Enrollment__c.workflow-meta.xml

sfdx force:user:password:generate -u scratch 

sfdx force:org:display -u scratch 

$SHELL