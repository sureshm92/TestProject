# Salesforce DX Scratch Org Setup

##### 1) Login to Dev Hub org and make it default (-d key):

```sh
sfdx force:auth:web:login -d -a setYourDevHubAliasHere
```

##### 2) Create Scratch org and make it default (-s key):

```sh
sfdx force:org:create -f config/project-scratch-def.json -d 30 -s -a setYourAliasHere
```
##### 3) Push project to Scratch org:
```sh
sfdx force:source:push
```

##### 4) Open Scratch org in browser and setup:
```sh
sfdx sfdx force:org:open
```

1) Setup > User > edit > set role "View All" 
2) Upload data:
```sh
sfdx force:data:tree:import -p data/import-plan.json
```
- From Clinical Trial Profle create Study Site with status "Invitation Sent" and set PI Contact
- From Study Site create HCP Enrollment with status "Invitation sent" and set HCP Contact

3) Go to setup > all communities > open community builder > press publish
4) Select PI or HCP contact and login in community

## Dev, Build and Test


## Resources


## Description of Files and Directories


## Issues


