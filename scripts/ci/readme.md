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

#### Get Authentication URL for set in Gitlab variables:

1) Login to target org and define your own alias instead 'sandBoxAlias':
    ```
    sfdx force:auth:web:login -a sandBoxAlias -r https://test.salesforce.com
    ```
2) Output sandbox credentials:
    ```
    sfdx force:org:display -u sandBoxAlias --verbose
    ```
3) Copy to clipboard 'Sfdx Auth Url' value and set new variable in Gitlab
