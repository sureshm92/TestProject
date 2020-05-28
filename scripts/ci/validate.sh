# Prepare auth file
orgAuthVar=$1
echo "${!orgAuthVar}" > authFile

sfdx force:auth:sfdxurl:store -f authFile -a TargetOrg -d
sfdx --version
cat ./scripts/ci/.forceignore_validate_exclude >> .forceignore
sfdx force:source:deploy -p force-app -u TargetOrg -c -w 60
echo "Validate success!"
