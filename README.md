### Setting up your VS Code IDE

##### 0) Setup Node.js

Configure gitbash as your default terminal in VS Code and then raise a request for Node.js (v12.0.0 and above) by running the below command from terminal

```sh
start microsoft-edge:http://selfservice.quintiles.net/ESD/Home
```

It comes with npm package manager. After installation, initialize npm package in your workspace by running the command below -

```sh
npm init
```

##### 1) Configure Prettier for Apex

Install the prettier VS Code extension and then install the node library by running

```sh
npm install --save-dev prettier prettier-plugin-apex
```

Enable auto-format on save -
_File > Preferences > Settings > Search for "format on save" > Enable the editor setting_

##### 2) Install Apex PMD

_Extensions > Search for "Apex PMD" > Install_

---

### Salesforce DX Scratch Org Setup

##### 0) Login to Dev Hub org and make it default (-d key):

```
sfdx force:auth:web:login -d -a PPDevHub
sfdx force:config:set defaultdevhubusername=devHubAlias --global
```

##### 1) Create Scratch Org:

```sh
./create-scratch-org.sh scratchOrgAlias
```

##### 2) Publish each community:

_Go to Setup > All Communities > Open Community Builder > press "Publish"_

---

If merge request fails on the error
just remove <userPermission> with the name ViewFlowUsageAndFlowEventData from Admin.profile
