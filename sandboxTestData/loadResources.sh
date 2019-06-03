echo "import started..."
sfdx force:data:tree:import -p ./resources/Resource__c-plan.json
sfdx force:data:tree:import -p ./resources/Resource__c2-plan.json
sfdx force:data:tree:import -p ./resources/Resource__c3-plan.json
sfdx force:data:tree:import -p ./resources/Resource__c4-plan.json
sfdx force:data:tree:import -p ./resources/Resource__c5-plan.json
sfdx force:data:tree:import -p ./resources/Resource__c6-plan.json
echo "import completed"

$SHELL