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
- after import go to mail boxes updates@cp.clinicalresearch.com & patientupdates@cp.clinicalresearch.com and approve both. Ask about how to get access to this mailbox

then open setup:

```sh
sfdx force:org:open
```
- go to **Process Automation Settings** and set up Default workflow user and set in Email approval sender value "IQVIA Referral Hub"
- go to **Survey Settings** and enable 

##### 4) Push project to Scratch org:

```sh
sfdx force:source:push
```

##### 5) Open Scratch org in browser and setup:

```sh
sfdx force:org:open
```

- Setup > User > edit > set role "View All" 
- Upload data

```sh
sfdx force:data:tree:import -p data/import-plan.json
```

- Go to setup > all communities > open community builder > press publish

##### 6) Login to community

- Open Study Site for edit and change Override Status to "Accepted" 
- Open HCP Enrollment for edit and change Stats to "Activated" 
- Login to community under PI User, HCP user or Participant user on your choice 


## Dev, Build and Test


## Resources


## Description of Files and Directories


## Issues


