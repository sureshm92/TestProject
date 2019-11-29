call sfdx force:org:create -f config/project-scratch-def.json -d 30 -s -a %1
call sfdx force:data:tree:import -f data/OrgWideEmailAddresses.json
call sfdx force:mdapi:deploy -d pre-setup/name-settings -w 1
call sfdx force:org:open