## Scripts for CI / CD and manual deployments

#### Yaml CI/CD scripts:
1) deploy.sh - used only in .gitlab-ci.yml script for deploy source code into specified org
2) run-tests.sh - used only in .gitlab-ci.yml script for run-tests in specified org
3) validate.sh - used only in .gitlab-ci.yml script for validate source code in specified org

#### Manual deploy code to specified org:

1) Retrieve branch you want to deploy 
2) Login to specified org if this org not in logged list (you can check with command: sfdx force:org:list)
    ```sh
    sfdx force:auth:web:login -a orgAlias -r https://test.salesforce.com
    ```
3) Execute from root directory command:
    ```sh
    . ./scripts/ci/deploy-manual.sh orgAlias
    ```
4) Discard changes in repository after script complete