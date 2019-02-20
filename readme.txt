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
2) Upload data
- Several Accounts
- Several Contacts for (PI and HCP)
- Account with name "Participant" for all participant contacts
- Create Clinical Trial Profile
- Create Study Site with status "Invitation Sent"
- Create HCP Enrollment with status "Invitation sent"
3) Go to setup > all communities > open community builder > press publish
4) Select PI or HCP сontact and login in community