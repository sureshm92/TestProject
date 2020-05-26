# Prepare auth file
orgAuthVar=$1
echo "${!orgAuthVar}" > sfdx-auth-url

# Login
sfdx force:auth:sfdxurl:store -f sfdx-auth-url -a TargetOrg -d

# Run tests
sfdx force:apex:test:run -u TargetOrg --testlevel=RunLocalTests -w 60
