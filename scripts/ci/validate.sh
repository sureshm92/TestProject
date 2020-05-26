# Prepare auth file
orgAuthVar=$1
echo "${!orgAuthVar}" > sfdx-auth-url

sfdx force:auth:sfdxurl:store -f sfdx-auth-url -a TargetOrg -d
sfdx --version
cat .forceignore_validate_exclude >> .forceignore
sfdx force:source:deploy -p force-app -u TargetOrg -c -w 60
echo "Validate success!"
