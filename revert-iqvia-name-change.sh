# Reset the community name (from: IQVIA_Referral_Hub1 -> to: IQVIA_Referral_Hub_C)
echo "Change IQVIA_Referral_Hub1 -> IQVIA_Referral_Hub_C"
sed -i 's/IQVIA_Referral_Hub1/IQVIA_Referral_Hub_C/g' 'force-app/communities/community-iqvia/networks/IQVIA Referral Hub.network-meta.xml'
mv force-app/communities/community-iqvia/experiences/IQVIA_Referral_Hub1.site-meta.xml force-app/communities/community-iqvia/experiences/IQVIA_Referral_Hub_C.site-meta.xml
mv force-app/communities/community-iqvia/experiences/IQVIA_Referral_Hub1 force-app/communities/community-iqvia/experiences/IQVIA_Referral_Hub_C
