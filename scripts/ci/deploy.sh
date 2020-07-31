# Show version of SFDX
sfdx --version

# Prepare auth file
orgAuthVar=$1
echo "${!orgAuthVar}" > authFile

# Login to org:
sfdx force:auth:sfdxurl:store -f authFile -a TargetOrg -d

# Save file content to backup
cp .forceignore .forceignoreTMP

# Deployment exclusions:
cat ./scripts/ci/.forceignore_deploy_exclude >> .forceignore

# Rename old community for support deployment (from: IQVIA_Referral_Hub1 -> to: IQVIA_Referral_Hub_C)
sed -i 's/IQVIA_Referral_Hub1/IQVIA_Referral_Hub_C/g' 'force-app/communities/community-iqvia/networks/IQVIA Referral Hub.network-meta.xml'
mv force-app/communities/community-iqvia/experiences/IQVIA_Referral_Hub1.site-meta.xml force-app/communities/community-iqvia/experiences/IQVIA_Referral_Hub_C.site-meta.xml
mv force-app/communities/community-iqvia/experiences/IQVIA_Referral_Hub1 force-app/communities/community-iqvia/experiences/IQVIA_Referral_Hub_C

# Deploy project
sfdx force:source:deploy -p force-app -u TargetOrg  -w 60

# Restore file from backup
cp .forceignoreTMP .forceignore
rm .forceignoreTMP

# Deploy communities
#sfdx force:source:deploy -p force-app/communities -u TargetOrg  -w 60
echo "Deploy success!"
