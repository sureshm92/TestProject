 apk upgrade --update-cache --available && apk add openssl curl jq 
 openssl s_client -connect  sonarqube:443 | keytool -import -noprompt -alias sonarqbue_test -keystore $JAVA_HOME/lib/security/cacerts -storepass changeit
 sonar-scanner -Dsonar.branch.name=$CI_COMMIT_REF_NAME
 cat .scannerwork/report-task.txt
 export url=$(cat .scannerwork/report-task.txt | grep ceTaskUrl | cut -c11- ) #URL where report gets stored
 echo $url
 sleep 90s #Wait time for the report
 curl -k -u "$SONAR_TOKEN":"" $url -o analysis.json
 cat analysis.json
 export status=$(cat analysis.json | jq -r '.task.status') #Status as SUCCESS, CANCELED or FAILED
 export analysisId=$(cat analysis.json | jq -r '.task.analysisId') #Get the analysis Id
 echo "URL" $url
 echo "status" $status
 echo  "analysisId" $analysisId
 if [ "$status" == "SUCCESS" ];then 
        echo -e "SONAR ANALYSIS SUCCESSFUL...ANALYSING RESULTS";
        curl -k -u "$SONAR_TOKEN":"" $SONAR_HOST_URL/api/qualitygates/project_status?analysisId=$analysisId -o result.txt; #Analysis result like critical, major and minor issues
        export result=$(cat result.txt | jq -r '.projectStatus.status');

         if [ "$result" == "ERROR" ];then
          echo -e "SONAR RESULTS FAILED";
          echo "$(cat result.txt | jq -r '.projectStatus.conditions')"; #prints the critical, major and minor violations
          exit 1 #breaks the build for violations
         else
          echo -e "SONAR RESULTS SUCCESSFUL";
          echo "$(cat result.txt | jq -r '.projectStatus.conditions')";
          exit 0 
         fi
 else 
       echo -e "\e[91mSONAR ANALYSIS FAILED\e[0m";
       exit 1 #breaks the build for failure in Step2
 fi
