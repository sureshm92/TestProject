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