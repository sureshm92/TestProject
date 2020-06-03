# Deployment exclusions:
cat ./scripts/ci/.forceignore_deploy_exclude >> .forceignore

# Rename old community for support deployment (from: IQVIA_Referral_Hub1 -> to: IQVIA_Referral_Hub_C)
sed -i 's/IQVIA_Referral_Hub1/IQVIA_Referral_Hub_C/g' 'unpackaged/communities/community-iqvia/networks/IQVIA Referral Hub.network-meta.xml'
mv unpackaged/communities/community-iqvia/experiences/IQVIA_Referral_Hub1.site-meta.xml unpackaged/communities/community-iqvia/experiences/IQVIA_Referral_Hub_C.site-meta.xml
mv unpackaged/communities/community-iqvia/experiences/IQVIA_Referral_Hub1 unpackaged/communities/community-iqvia/experiences/IQVIA_Referral_Hub_C

# Deploy project
sfdx force:source:deploy -p force-app -u $1  -w 60

# Deploy communities
sfdx force:source:deploy -p unpackaged/communities -u $1  -w 60
