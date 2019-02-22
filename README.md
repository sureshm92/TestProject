# Salesforce DX setup

##### 1) Login to Dev Hub org and make it default (-d key):

sfdx force:auth:web:login -d -a my-hub-org
```sh
sfdx force:auth:web:login -d -a my-hub-org
```

##### 2) Create Scratch org and make it default (-s key):

```sh
sfdx force:org:create -f config/project-scratch-def.json -a someSOrgAlias -d 30 -s
```
##### 3) Open Scratch org in browser:
```sh
sfdx sfdx force:org:open
```

##### 4) Push changes to Scratch org:
```sh
sfdx force:source:push
```

#### Setup org:

1) Open org > User > edit > set role "View All"!
2) Upload data:
- upload org wide email address:

```sh
sfdx force:data:tree:import -f data/OrgWideEmailAddresses.json
```
- upload accounts and contacts:

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


