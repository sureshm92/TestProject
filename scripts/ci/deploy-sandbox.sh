# Show version of SFDX
sfdx --version
echo 'ORG: ${1} ${2} ${3}'
echo '$(${1})' > sfdx-auth-url

# Login to org:
sfdx force:auth:sfdxurl:store -f sfdx-auth-url -a TargetOrg -d

# Deployment exclusions:
cat .forceignore_deploy_exclude >> .forceignore

# Rename old community for support deployment (from: IQVIA_Referral_Hub1 -> to: IQVIA_Referral_Hub_C)
sed -i 's/IQVIA_Referral_Hub1/IQVIA_Referral_Hub_C/g' 'unpackaged/communities/community-iqvia/networks/IQVIA Referral Hub.network-meta.xml'
mv unpackaged/communities/community-iqvia/experiences/IQVIA_Referral_Hub1.site-meta.xml unpackaged/communities/community-iqvia/experiences/IQVIA_Referral_Hub_C.site-meta.xml
mv unpackaged/communities/community-iqvia/experiences/IQVIA_Referral_Hub1 unpackaged/communities/community-iqvia/experiences/IQVIA_Referral_Hub_C

# Deploy project
sfdx force:source:deploy -p force-app -u TargetOrg  -w 60

# Deploy communities
sfdx force:source:deploy -p unpackaged/communities -u TargetOrg  -w 60
echo "Deploy success!"
