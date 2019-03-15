# Salesforce DX Scratch Org Setup

##### 1) Login to Dev Hub org and make it default (-d key):

```sh
sfdx force:auth:web:login -d -a devHubAlias
```

##### 2) Create Scratch org and make it default (-s key):

```sh
sfdx force:org:create -f config/project-scratch-def.json -d 30 -s -a scratchOrgAlias
```
##### 3) Import Org Wide Email Address:

```sh
sfdx force:data:tree:import -f data/OrgWideEmailAddresses.json
```
- after import go to updates@cp.clinicalresearch.com mail box and approve this email. Ask about how to get access to this mailbox

then open setup:
```sh
sfdx force:org:open
```

- go to Process Automation Settings and set up default workflow user email approval sender "IQVIA Referral Hub"

##### 4) Push project to Scratch org:
```sh
sfdx force:source:push
```

##### 5) Open Scratch org in browser and setup:
```sh
sfdx force:org:open
```

- Setup > User > edit > set role "View All" 
- Upload data:
```sh
sfdx force:data:tree:import -p data/import-plan.json
```
- Go to setup > all communities > open community builder > press publish

##### 6) Login to community

After import:

- find contact "Joseph Davis PI And HCP" and login to community under this contact
- switch to mode "View As Investigative Site" and press "I'm open to receive referrals"
- switch to mode "View As Referring Provider Clinic" and press "Find Study Sites" then press "Find Study Sites" again and then press "Send Site Request"
- switch to mode "View As Investigative Site" in navigation menu select "My Referring Clinics" press "Activate button"
- switch to mode "View As Referring Provider Clinic" press "Medical record review"

Or you can just change:
 
- SS Override Status to "Accepted" 
- HCPE Stats to "Activated" 
- and then login as "Joseph Davis PI And HCP" to community 


## Dev, Build and Test


## Resources


## Description of Files and Directories


## Issues


