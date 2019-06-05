echo "import started..."
sfdx force:data:tree:import -p data-out/import-plan.json
sfdx force:data:tree:import -p sfdx-out/import-plan.json
sfdx force:data:tree:import -p data-ver-2/data-plan.json
sfdx force:data:tree:import -p sfdx-BAonly/import-plan.json

echo "import completed"

$SHELL