  

# Convert

```sh

$ sfdx force:mdapi:convert --rootdir packagingorg/unpackaged

-r | --rootdir ROOTDIR

-d | --outputdir OUTPUTDIR

```

# retrieve

```sh

$ sfdx force:mdapi:retrieve -s -r ./packagingorg -u "usrname" -p "packageName"

-s | --singlepackage

-r | --retrievetargetdir RETRIEVETARGETDIR

```

# deploy

```sh

$ sfdx force:source:deploy -u devhub -p force-app

-p | --packagenames PACKAGENAMES

-u | --targetusername

-u | --targetusername TARGETUSERNAME

-c | --checkonly

-d | --deploydir

-l | --testlevel TESTLEVEL

-r | --runtests RUNTESTS

```

# Push

```sh

$ sfdx force:source:push

```

# Open/list

```sh

$ sfdx force:org:list

sfdx force:org:open -u myhuborg

```
# delete

```sh

sfdx force:org:delete
```

# create

```sh

sfdx force:org:create -s -f config/project-scratch-def.json -a alias

-s | --setdefaultusername

-f | --definitionfile DEFINITIONFILE

```

# login

```sh

$ sfdx force:auth:web:login -d -a myhuborg

-d | --setdefaultdevhubusername

-a | --setalias SETALIAS

```

# package

```sh

$ sfdx force:package:create -n packageName -r packagingorg/converted/main/default -t Unlocked -v myhuborg
$ sfdx force:package:version:create -p packageName -d packagingorg/converted/main/defau
lt2   -k test1234 --wait 10 -v hub


$ sfdx force:package:install --wait 10 --publishwait 10 --package sms-integration-Unlock
$ sfdx force:package:version:promote -p sms-Unlock@0.1.0-1


-t | --packagetype PACKAGETYPE

n | --name NAME

-v | --targetdevhubusername

```