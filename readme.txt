Salesforce DX setup

1) Login to Dev Hub org and make it default (-d key):

sfdx force:auth:web:login -d -a my-hub-org


2) Create Scratch org and make it default (-s key):

sfdx force:org:create -f config/project-scratch-def.json -a someSOrgAlias -d 30 -s


3) Open Scratch org in browser:

sfdx force:org:open


4) Push changes to Scratch org:

sfdx force:source:push


5) Pull changes to Scratch org:

sfdx force:source:pull



Setup org:

1) Open org > User > edit > set Role
2) Upload data:

- upload accounts and contacts:
sfdx force:data:tree:import --plan data/export-Account-Contact-plan.json

- upload Clinical Trial Profile:
sfdx force:data:tree:import --plan data/export-Clinical_Trial_Profile__c-plan.json

- From Clinical Trial Profle create Study Site with status "Invitation Sent" and set PI Contact
- From Study Site create HCP Enrollment with status "Invitation sent" and set HCP Contact

3) Go to setup > all communities > open community builder > press publish
4) Select PI or HCP сontact and login in community