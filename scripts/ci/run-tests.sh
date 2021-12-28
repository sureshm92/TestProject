# Prepare auth file
orgAuthVar=$1
echo "${!orgAuthVar}" > authFile

# Login
sfdx force:auth:sfdxurl:store -f authFile -a TargetOrg -d

# Run tests
#sfdx force:apex:test:run -u TargetOrg --testlevel=RunLocalTests -w 60
sfdx force:apex:test:run -u TargetOrg -w 350 --resultformat json --outputdir $CI_PROJECT_DIR/tests/apex/ --codecoverage --testlevel RunLocalTests
