# Rename community for deployment (IQVIA_Referral_Hub_C -> IQVIA_Referral_Hub1)
echo "Change IQVIA_Referral_Hub_C -> IQVIA_Referral_Hub1"
sed -i 's/IQVIA_Referral_Hub_C/IQVIA_Referral_Hub1/g' 'force-app/communities/community-iqvia/networks/IQVIA Referral Hub.network-meta.xml'
mv force-app/communities/community-iqvia/experiences/IQVIA_Referral_Hub_C.site-meta.xml force-app/communities/community-iqvia/experiences/IQVIA_Referral_Hub1.site-meta.xml
mv force-app/communities/community-iqvia/experiences/IQVIA_Referral_Hub_C force-app/communities/community-iqvia/experiences/IQVIA_Referral_Hub1