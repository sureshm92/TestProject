#!/bin/bash -e
set +o pipefail
IFS=$'\n'

# This script is designed as a wrapper for sfdx.
# It should cover all sfdx use cases in CI scripts.
# Some workarounds for known sfdx flaws and inconviniences were developed here.
# Developed by maksym.petrov@customertimes.com

# Needs previously generated output from populate_file_list.
# Two arguments are mandatory:
# $1 - action type  (see valid syntax examples below)
# $2 - variable name with salesforce token, normally git branch name (VARIABLE_WITH_SF_TOKEN)

# valid syntax examples (not all functions yet implemented):
# $0 validate_RunLocalTests     VARIABLE_WITH_SF_TOKEN
# $0 validate_RunSpecifiedTests VARIABLE_WITH_SF_TOKEN
# $0 validate_RunAllTestsInOrg  VARIABLE_WITH_SF_TOKEN
# $0 validate_full              VARIABLE_WITH_SF_TOKEN
# $0 deploy_RunSpecifiedTests   VARIABLE_WITH_SF_TOKEN
# $0 deploy_full                VARIABLE_WITH_SF_TOKEN
# $0 test_RunLocalTests         VARIABLE_WITH_SF_TOKEN
# $0 test_RunApexScripts        VARIABLE_WITH_SF_TOKEN
# $0 initial_push_to_sandbox    VARIABLE_WITH_SF_TOKEN


##############################################################################
# variables
##############################################################################

# export SFDX_IMPROVED_CODE_COVERAGE='true'
# https://releasenotes.docs.salesforce.com/en-us/spring20/release-notes/rn_sf_cli_code_coverage_apextests.htm
# Playing with this variable might be the cause of this error:
# after finishing 'sfdx force:apex:test:run --testlevel=RunLocalTests --codecoverage'
# Error: read ECONNRESET at TLSWrap.onStreamRead (internal/stream_base_commons.js:205:27)
# https://gitmemory.com/issue/forcedotcom/cli/698/719542270

export SFDX_MAX_QUERY_LIMIT=100000
TMOUT_VAL_FULL=90  # Note, this value is used in 2 places, one after another, the gitlab timeout must be doubled
TMOUT_VAL_SPECIF=90
TMOUT_VAL_LOCAL=90
TMOUT_TEST_LOCAL=350
TMOUT_DPL_FULL=90

# directory to move selected files/folders to for partial deploy and validation.
TMP_PKG_DIR="force-app-tmp"
# FILENAME_TSTCLSS="tests-for-validation-comma-space.txt"

# Dirs to move in full validation to split deployment
DIRS_PREFIX='force-app/main/default'
DIRS_TO_MOVE='reports reportTypes staticresources dashboards groups aura labels flexipages permissionsets'

RC=0  # return code (exit code)

# unset TFN  #  TestFileName
declare -A TCN_HASH  # associative array for the TestClassNames

##############################################################################
# initial checks
##############################################################################

echo "[INFO] Checking if the current directory is project root ..."
ls force-app/main/default/ 1>/dev/null || exit 20


GOAL="$1"
echo "[INFO] Checking if 1st argument '$GOAL' is in list of allowed values ..."  # this could be one =~ with very long right shoulder.
#[[ "$GOAL" =~ ^(validate_RunLocalTests|validate_RunSpecifiedTests|validate_full)$ || \
#    "$GOAL" =~ ^(deploy_without_testlevel|deploy_full|initial_push_to_sandbox)$ || \
#    "$GOAL" =~ ^(test_RunLocalTests|test_RunApexScripts)$ ]] || exit 40

echo "[INFO] Checking if variable name, passed in 2nd argument '$2' exists and the value looks like Salesforce login token."
eval token='$'"$2"
if [[ ! $token =~ ^(force://.*salesforce.com)$ ]]; then
    echo "[ERROR] No value in variable '$2', please have the Salesforce token in it."
#    exit 50
fi

# Show version of SFDX
echo "[INFO] sfdx --version: $(sfdx --version)"

if [[ -z $CI_PROJECT_DIR ]]; then
    echo "[WARNING] Running on local."
    CI_PROJECT_DIR="$PWD"
fi

##############################################################################
# functions
##############################################################################

# accepts one argument - the variable name with creds to the org.
function login_to_org() {
   
    #echo "${!1}" > authFile
    
    #if [[ $flag == 'deploy' ]]; then
    if expr "${flag}" : "deploy" >/dev/null; then
    
         echo "[INFO] Logging in to org for $1..."
         #Removing dot from from branch name string
         orgVariable=$(echo $1 | sed -e 's/\.//g') 
         echo "${!orgVariable}" > authFile
         sfdx force:auth:sfdxurl:store -f authFile --setalias TargetOrg --setdefaultdevhubusername || true  # since sfdx 7.83 it's sfdx auth:sfdxurl:store
    elif expr "${flag}" : "validate" >/dev/null; then 
       echo "[INFO] Logging in to org for Validation"
       echo "$INF72" > authFile
       sfdx force:auth:sfdxurl:store -f authFile --setalias TargetOrg --setdefaultdevhubusername || true  # since sfdx 7.83 it's sfdx auth:sfdxurl:store   
    else
       echo "[INFO] None of the condition met for validate or deploy"
    fi
     
    rm -rf authFile
    sfdx force:auth:list | grep TargetOrg || (echo "[ERROR] Not authorizd to Salesforce Org."; false )  # since sfdx 7.83 it's sfdx force:org:list
}


function change_sfdx-project-json() { # used as a part of other functions
    echo "[DEBUG] ==== ${FUNCNAME[0]} ===="
    mkdir -p "$TMP_PKG_DIR"
    mv "sfdx-project.json"  "sfdx-project.json.orig" || exit 60
    cat "sfdx-project.json.orig" | jq ".packageDirectories += [ {\"path\": \"$TMP_PKG_DIR\"} ]" \
      > "sfdx-project.json"
}

function copy_file_and_meta_xml() {  # part of copy_listed_and_associated_files_and_fill_RunSpecifiedTests_list
    # echo "[DEBUG] ==== ${FUNCNAME[0]} ===="
    # note that initially committed file is already copied at this point
    if [[ $file =~ ^.*-meta.xml$  ]]; then  # or, if initial file from the list is -meta.xml
        if [[ -f $nometa ]]; then
            cp -pf "$nometa" "$target_dir"
            echo "[INFO] + main file for -meta.xml '$nometa' to '$target_dir'"
        fi
    elif [[ -f $meta ]]; then
        cp -pf "$meta" "$target_dir"
        echo "[INFO] + -meta.xml '$meta' to '$target_dir'"
    fi
}

function copy_listed_and_associated_files_and_fill_RunSpecifiedTests_list() {
    echo "[DEBUG] ==== ${FUNCNAME[0]} ===="
    if [[ ! -s $FILENAME_AM_COL ]]; then
        echo "[ERROR] \$FILENAME_AM_COL must be set and conatain list of files to work with!"
        exit 90
    fi
    change_sfdx-project-json
    while IFS=$'\n' read -r file || [ -n "$file" ]; do  # < "$FILENAME_AM_COL"
            if [[ -f "$file" ]]; then
                local target_path="${file/#force-app/$TMP_PKG_DIR}"
                local source_dir; source_dir=$(dirname "$file")
                local target_dir; target_dir=$(dirname "$target_path")
                local nometa="${file%-meta.xml}"  # predicted filename without -meta.xml suffix. Does not modify $file if not matched.
                local meta="$nometa-meta.xml"  # predicted filename with -meta.xml suffix.
                local baseclassfile="${nometa/%Test\.cls/\.cls}"  # predicted class filename, attempt to replace Test.cls suffix by .cls. (% emphasises to substitute only match before end of string)
                local base_file_name="${file##*/}"
                local bcn; bcn="$(basename ${baseclassfile%.*})"  # predicted base class name. May include values like VT_R5_AllTests4. ( /Test$// )
                local tfn="${baseclassfile%.*}Test.${baseclassfile##*.}"  # predicted test filename. Note, as of 2020-10-13 there are 34 testclass files breaking naming convention, like VT_D1_CaseHandler_Test.cls
                local tcn; tcn="$(basename ${tfn%.*})"  # predicted test name.
                mkdir -p "$target_dir"
                echo "[INFO] Copying '$file' to '$target_dir'"
                cp -pf "$file" "$target_dir"  # copy initial file from the list
                copy_file_and_meta_xml

                if [[ $file =~ ^.*\.cls$ || $file =~ ^.*\.cls-meta\.xml$ ]]; then  # find neighbor files only for classes
                    if [[ $file =~ ^.*\.cls$ ]]; then  #  any class file
                        produce_list_for_RunSpecifiedTests "$file" # adds testclass name to list for RunSpecifiedTests
                    elif [[ $file =~ ^.*\.cls-meta.xml$ ]]; then  #   AllTests0.cls-meta.xml
                        produce_list_for_RunSpecifiedTests "$nometa"  # add class name to list for RunSpecifiedTests
                    fi
                # this logic implies that no class files are stored in /aura/ or /lwc/
                elif [[ ${file%*} =~ /aura/ || ${file%*} =~ /lwc/  ]]; then
                    echo "[INFO] For aura or lwc copying whole subdirectory $source_dir"
                    cp -rpn $source_dir/* $target_dir/
                elif [[ ${file%*} =~ /staticresources/ ]]; then
                    echo "[INFO] For staticresources copying initial file, it's resource-meta.xml and 1st child subdirectory of staticresources."
                    # Following scenarios must be covered:
                    # 1. Direct childs of staticresources (do not have sub-dirs): binary file and resource-meta.xml:
                    # force-app/main/default/staticresources/Apollo_Flourish.resource-meta.xml
                    # force-app/main/default/staticresources/Apollo_Flourish.png

                    # 2. directory with one level childs
                    # force-app/main/default/staticresources/apollo_icons_v2/ediary.svg
                    # force-app/main/default/staticresources/apollo_icons.resource-meta.xml
                    # force-app/main/default/staticresources/apollo_icons/001Person.svg
                    # force-app/main/default/staticresources/apollo_icons/002Plane.svg

                    # 3. directory with variable level childs and complex tree
                    # force-app/main/default/staticresources/slds_icon.resource-meta.xml
                    # force-app/main/default/staticresources/slds_icon/salesforce-lightning-design-system-icons/standard-sprite/svg/symbols.svg

                    # Note that current implementation sometimes copies a bit more than needed.
                    # I.e. force-app/main/default/staticresources/apollo_icons* will expand to dirs: apollo_icons, apollo_icons_lwc, apollo_icons_secure_portal, apollo_icons_v2

                    local sub_path; sub_path=$(dirname ${file#*/staticresources/})   # part of the file path after staticresources
                    local base_sr_path="${file/\/staticresources\/*/\/staticresources}"  # remove all after staticresources
                    local target_sr_root_path="${base_sr_path/#force-app/$TMP_PKG_DIR}"

                    if [[ $sub_path == '.' ]]; then
                        echo "[DEBUG] The file $file is direct child of staticresources."  # $file is already copied
                        local file_no_ext1="${file%.*}"  # removed file extention
                        local file_no_ext2="${file_no_ext1%.resource-meta}"  # removed .resource-meta if it was,
                        local copy_glob="$file_no_ext2*"                     # and added * to make it look like a glob
                    else
                        echo "[DEBUG] The file $file is in sub-dir of staticresources (any depth)."
                        local level_1_sub_path=${sub_path%%/*}  # name of 1st child dir under staticresources
                        local copy_glob="$base_sr_path/$level_1_sub_path*"
                    fi
                    echo "[DEBUG] copy_glob=$copy_glob"
                    set -x
                    cp -rpn --target-directory="$target_sr_root_path/" -- $copy_glob
                    set +x
                fi
            else
                echo -e "[ERROR] File not found: $file\nThis should never happen. Script error?"
                exit 80  # any non-zero value will do, but different numbers are better for local debug
            fi
    done < "$FILENAME_AM_COL"
    printf -v TCN_CSV '%s,' "${!TCN_HASH[@]}"   # making comma separated list from keys
    TCN_CSV="${TCN_CSV%,}"  # removing trailing comma

    # echo "$TFN" > $FILENAME_TSTCLSS  # not yet used, just to save as artifact
}

function produce_list_for_RunSpecifiedTests() {  # needs one arg: $file. Returns: $TCN_CSV.
    # Sub-function of copy_listed_and_associated_files_and_fill_RunSpecifiedTests_list.
    # Filename for the needed test class is sometimes different than <class_filename>Test.cls.
    # New optimized tests invoke test classes from wrapper files named like VT_R5_AllTests3.cls, VT_R5_AllTests5.cls, etc.
    # If the class name of current $file is listed in any of .*_AllTests\d+.cls, then we return their names in TCN.
    echo "[DEBUG] ==== ${FUNCNAME[0]} ===="
    local file="$1"  # it overrides global variable.
    local FOUND_FLAG='false'
    # local newline=$'\n'
    if [[ $base_file_name =~ ^.*\.cls$ && ! $base_file_name =~ ^.*AllTests.*\.cls$ ]]; then
        # if we don't yet have variable with AllTests files - fill it and keep until the end.
        if [[ -z $AllTests_FILENAMES ]]; then
            AllTests_FILENAMES="$(find ./force-app -type f -regextype egrep -regex '.*AllTests.*\.cls')"
        fi
        for allTestsfile in ${AllTests_FILENAMES}; do
            # echo "[DEBUG] Looking into $allTestsfile"
            local atcn; atcn="$(basename ${allTestsfile%.*})"  # class name of allTests

            # removing '//' comments
            local sl; sl="$(grep -vE '^\s*//' "$allTestsfile")"  # removed single-line comments - lines started with '//'
            # removing /* multi-line */ comments from class file
            local oneline; oneline=$(echo "$sl" | awk '{print}' ORS=' ') # replacing line breaks with spaces, producing one line variable
            local filtered; filtered="$(echo "$oneline" | perl -pe 's#(^|\s)\/\*\s*.*?\*\/##g')"  #  /* multi-line */ comments are now all in single line, removing them.

            if  [[ $filtered =~ ${tcn} ]]; then
                echo -e "[DEBUG] $tcn is listed in $allTestsfile"

                if [[ $FOUND_FLAG == 'false' ]]; then
                    FOUND_FLAG='true'
                else
                    echo -e "#\n[WARNING] found mention of $tcn in multiple allTestsfiles: $allTestsfile"
                fi
                # [[ -n $TFN ]] && TFN="${TFN}${newline}${allTestsfile}" || TFN="$allTestsfile"
                TCN_HASH[$atcn]=1  # associative array (hash) helps to avoid duplicates
            fi
        done
        if [[ $FOUND_FLAG == 'false' ]]; then
            echo -e "[DEBUG] not in AllTests files: $file"
            if [[ -f $tfn ]]; then
                # [[ -n $TFN ]] && TFN="${TFN}${newline}${tfn}" || TFN="$tfn"
                TCN_HASH[$tcn]=1  # associative array (hash) helps to avoid duplicates
            else
                echo "#"  # Gitlab collapses empty lines, so this '#' is for Gitlab to leave ~almost~ empty line.
                echo "[WARNING] ##############################################################################################"
                echo "[WARNING]"
                echo "[WARNING] Not found file with testClass for $file."
                echo "[WARNING]"
                echo "[WARNING] ##############################################################################################"
                echo "#"
            fi
        fi
    elif [[  $base_file_name =~ ^.*AllTests.*\.cls$ ]]; then
        echo "[DEBUG] allTestsfile: $file"
        # [[ -n $TFN ]] && TFN="${TFN}${newline}${nometa}" || TFN="$nometa"
        TCN_HASH[$bcn]=1  # associative array (hash) helps to avoid duplicates
    fi
}

function generate_log_basename() { # idea is to store log filename that can be alphabetically sorted.
    # (job name)-(MR ID)-(date in UTC)-(short commit id)
    #    1          2*          3             4

    local DT="$(date --utc +"%Y-%d-%m--%H-%M-UTC")"
    if [[ -n $CI_MERGE_REQUEST_IID ]]; then
        local MRID="-MR-$CI_MERGE_REQUEST_IID"
    else
        local MRID=''
    fi

    LOG_BASENAME="$GOAL$MRID-$DT-$CI_COMMIT_SHORT_SHA"  # this variable (with various suffxes) is used as log filename
}

# Combined deploy / validation function. needs parameter to select behavior.
function full_deploy_or_validation() {  # being done in 2 deployments due to amount of files to deploy is > 10000
    echo "[DEBUG] ==== ${FUNCNAME[0]} ===="
    if [[ $1 == 'deploy' ]]; then
        local flag=''
        local text=''
    elif [[ $1 == 'validate' ]]; then
        local flag='-c'
        local text='(with option "-c" - check only)'
    else
        echo "[ERROR] function ${FUNCNAME[0]} needs one paramerer: 'deploy|validate'"
        exit 60
    fi

    change_sfdx-project-json

    IFS=$' '
    for dir in $DIRS_TO_MOVE; do
        local full_dir_path="$DIRS_PREFIX/$dir"
        local target_dir="${full_dir_path/#force-app/$TMP_PKG_DIR}"
        mkdir -p ${target_dir%/*}
        mv "$full_dir_path" "$target_dir"
    done

    echo -e "#\n[INFO] Deploying $text most types, EXCLUDING following types:\n$DIRS_TO_MOVE."
    generate_log_basename
    set -x
    #time sfdx force:source:deploy -u TargetOrg -p force-app $flag -w $TMOUT_VAL_FULL >> $LOG_BASENAME.sfdx.log 2>&1
    time sfdx force:source:deploy -u TargetOrg -p force-app $flag -w $TMOUT_VAL_FULL 
    set +x

    echo "[INFO] modifying .forceignore for deployment from $TMP_PKG_DIR."
    sed -i "s@/force-app/@/$TMP_PKG_DIR/@g" .forceignore

    echo -e "#\n#\n#\n#\n#\n[INFO] Deploying $text only following types:\n$DIRS_TO_MOVE."
    generate_log_basename
    set -x
    #time sfdx force:source:deploy -u TargetOrg -p "$TMP_PKG_DIR" $flag -w $TMOUT_VAL_FULL >> $LOG_BASENAME.sfdx.log 2>&1
    time sfdx force:source:deploy -u TargetOrg -p "$TMP_PKG_DIR" $flag -w $TMOUT_VAL_FULL
    set +x

    echo -e "#\n[INFO] done."
}

function deploy_full() {
    full_deploy_or_validation 'deploy'
}

function validate_full() {
    full_deploy_or_validation 'validate'
}

# VALIDATION FUNCTIONS
function validate_RunSpecifiedTests() {
    # populate_file_list should already be invoked !
    copy_listed_and_associated_files_and_fill_RunSpecifiedTests_list  # iterates through $FILENAME_AM_COL, copies all to $TMP_PKG_DIR and makes list for RunSpecifiedTests
    echo "[DEBUG] ==== ${FUNCNAME[0]} ===="
    echo "[INFO] RunSpecifiedTests --runtests parameter size: ${#TCN_CSV} chars; number of items: ${#TCN_HASH[@]}"

    if [[ -n $TCN_CSV ]]; then
        generate_log_basename
        set -x
        time sfdx force:source:deploy -u TargetOrg -p "$TMP_PKG_DIR" -c -w $TMOUT_VAL_SPECIF \
            --testlevel RunSpecifiedTests --runtests "$TCN_CSV" >> $LOG_BASENAME.sfdx.log 2>&1 || RC=$?
        set +x
        # echo -e "[DEBUG] Selected TestClass filenames for RunSpecifiedTests (TFN):\n$TFN"
        echo -e "[DEBUG] Selected TestClass names for RunSpecifiedTests (TCN_CSV):\n$TCN_CSV"
    else  # no classfiles in commit(s) or no testfiles for classfiles
        echo "[INFO] no classfiles in commit(s) or no testfiles for classfiles. Running deploy with NO testlevel."
        generate_log_basename
        set -x
        #time sfdx force:source:deploy -u TargetOrg -p "$TMP_PKG_DIR" -c -w $TMOUT_VAL_FULL >> $LOG_BASENAME.sfdx.log 2>&1 || RC=$?
        #time sfdx force:source:deploy -u TargetOrg -p "$TMP_PKG_DIR" -c -w $TMOUT_VAL_FULL >> $LOG_BASENAME.sfdx.log 2>&1 || RC=$?
        time sfdx force:source:deploy -u TargetOrg -p "$TMP_PKG_DIR" -c -w $TMOUT_VAL_FULL || RC=$?
        set +x
        #if (grep -Eq '\.cls$' $FILENAME_AM_COL); then
        #    echo "#"  # Gitlab collapses empty lines, so this '#' is for Gitlab to leave ~almost~ empty line alone.
        #    echo "[WARNING] ##############################################################################################"
        #    echo "[WARNING]"
        #    echo "[WARNING]  .cls files were detected in commit, but no matching files with testclasses were found."
        #    echo "[WARNING]"
        #    echo "[WARNING] ##############################################################################################"
        #    echo "#"
        #    [[ $RC -eq 0 ]] && RC=100  # this will lead to error on exit even if validation above was succesful.
        #    echo "[ERROR] Validation is forced to fail due to no tests were provided."
        #fi
    fi
}

function validate_RunLocalTests() {
    echo "[DEBUG] ==== ${FUNCNAME[0]} ===="
    copy_listed_and_associated_files_and_fill_RunSpecifiedTests_list
    generate_log_basename
    set -x
    time sfdx force:source:deploy -u TargetOrg -p "$TMP_PKG_DIR" -c -w $TMOUT_VAL_LOCAL \
        --testlevel RunLocalTests >> $LOG_BASENAME.sfdx.log 2>&1 || RC=$?
    set +x
}

# function validate_RunAllTestsInOrg() {
#     echo "[DEBUG] ==== ${FUNCNAME[0]} ===="
#     copy_listed_and_associated_files_and_fill_RunSpecifiedTests_list
#     set -x
#     time sfdx force:source:deploy -u TargetOrg -p "$TMP_PKG_DIR" -c -w $TMOUT_VAL_ALL_ORG \
#         --testlevel RunAllTestsInOrg
#     set +x
# }

# DEPLOYMENT FUNCTIONS
# full deployment is being done in function full_deploy_or_validation

function deploy_RunSpecifiedTests() {  # Not yet tested
    echo "[DEBUG] ==== ${FUNCNAME[0]} ===="
    copy_listed_and_associated_files_and_fill_RunSpecifiedTests_list
    generate_log_basename
    set -x
    time sfdx force:source:deploy -u TargetOrg -p "$TMP_PKG_DIR" -w $TMOUT_VAL_SPECIF \
            --testlevel RunSpecifiedTests --runtests "$TCN_CSV" >> $LOG_BASENAME.sfdx.log 2>&1 || RC=$?
    set +x
}
function deploy_without_testlevel() {  # Not yet tested
    echo "[DEBUG] ==== ${FUNCNAME[0]} ===="
    copy_listed_and_associated_files_and_fill_RunSpecifiedTests_list
    generate_log_basename
    set -x
    time sfdx force:source:deploy -u TargetOrg -p "$TMP_PKG_DIR" -w $TMOUT_DPL_FULL || RC=$?
    #time sfdx force:source:deploy -u TargetOrg -p "$TMP_PKG_DIR" -w $TMOUT_DPL_FULL >> $LOG_BASENAME.sfdx.log 2>&1 || RC=$?
    set +x
}

function test_RunSpecifiedTests() {
    echo "[DEBUG] ==== ${FUNCNAME[0]} ===="
    copy_listed_and_associated_files_and_fill_RunSpecifiedTests_list
    echo "[ERROR] not yet implemented!"
    exit 33
}

function test_RunLocalTests() {  # it should run
    echo "[DEBUG] ==== ${FUNCNAME[0]} ===="
    generate_log_basename
    set -x
    time sfdx force:apex:test:run -u TargetOrg \
      --testlevel=RunLocalTests \
      --codecoverage -r human \
      -w $TMOUT_TEST_LOCAL >> $LOG_BASENAME.sfdx.log 2>&1 || RC=$?
    set +x

    TEST_RUN_ID="$(grep -m 1 "Test Run Id" $LOG_BASENAME.sfdx.log | sed -e 's/Test Run Id//' -e 's/[[:space:]]//g')"
    if [[ -z $TEST_RUN_ID ]]; then
        echo "[ERROR] Empty TEST_RUN_ID. $TEST_RUN_ID Please view $LOG_BASENAME.sfdx.log and make sure job timeout is correct."
        exit 110
    fi
    echo "[INFO] Now getting test results in junit and json formats for Test Run Id: $TEST_RUN_ID"
    set -x
    # sfdx force:apex:test:report -u TargetOrg -i $TEST_RUN_ID -r junit >> $LOG_BASENAME.sfdx.junit.xml 2>&1 || RC=$?  # without coverage
    sfdx force:apex:test:report -u TargetOrg -i $TEST_RUN_ID --codecoverage -r junit >> $LOG_BASENAME.coverage.sfdx.junit.xml 2>&1 || RC=$?
    sfdx force:apex:test:report -u TargetOrg -i $TEST_RUN_ID --codecoverage -r json >> $LOG_BASENAME.coverage.sfdx.json 2>&1 || RC=$?
    set +x
    ls -l -- *.sfdx.log *.junit.xml *.sfdx.json
}

function test_RunApexScripts() {  # not yet used / tested as it is dangerous
    echo "[DEBUG] ==== ${FUNCNAME[0]} ===="
    local changed_apex_scripts; changed_apex_scripts=$(grep -e .apex$ "$FILENAME_AM_COL" || true)
    for apexfile in $changed_apex_scripts; do
        # run apex scripts
        generate_log_basename
        echo -e "#\n#\n#\n[INFO] executing apex script $apexfile." | tee -a $LOG_BASENAME.sfdx.log
        echo "[INFO] See output in artifact file $LOG_BASENAME.sfdx.log."
        set -x
        time sfdx force:apex:execute -u TargetOrg -f "$apexfile" >> $LOG_BASENAME.sfdx.log 2>&1 || RC=$?
        set +x
    done
    ls -l -- *.sfdx.log || true
}


function initial_push_to_sandbox() {
    generate_log_basename
    echo "[INFO] Deploying custom labels"
    echo "[INFO] Please see output log in $LOG_BASENAME.sfdx.log"
    set -x
    time sfdx force:source:deploy -u TargetOrg  -p 'force-app/main/default/labels' -w 60 >> $LOG_BASENAME.sfdx.log 2>&1
    set +x
    echo "[INFO] Moving directories from force-app"
    IFS=$' '
    for dir in $DIRS_TO_MOVE; do
        mv "$DIRS_PREFIX/$dir" "$dir"
    done

    generate_log_basename
    echo "[INFO] Pushing the main part of the project, see output log $LOG_BASENAME.sfdx.log"
    set -x
    time sfdx force:source:push -f -u TargetOrg >> $LOG_BASENAME.sfdx.log 2>&1
    set +x

    echo "[INFO] Moving directories back to force-app"
    for dir in $DIRS_TO_MOVE; do
        mv "$dir" "$DIRS_PREFIX/$dir"
    done

    generate_log_basename
    echo "[INFO] Pushing the rest part of the project, see output log $LOG_BASENAME.sfdx.log"
    set -x
    time sfdx force:source:push -f -u TargetOrg >> $LOG_BASENAME.sfdx.log 2>&1
    set +x

    generate_log_basename
    echo "[INFO] Pulling from org to complete sync, see output log $LOG_BASENAME.sfdx.log"
    set -x
    time sfdx force:source:pull -f -u TargetOrg >> $LOG_BASENAME.sfdx.log 2>&1
    set +x

    echo "[INFO] Zipping .sfdx directory."
    zip -r .sfdx.zip .sfdx

    echo "[INFO] Everything went perfect, congratulations!"
}

function de_duplicate_log_lines() { # not yet used
    # needs some tweaks like leaving empty lines
    # https://iridakos.com/programming/2019/05/16/remove-duplicate-lines-preserving-order-linux
    awk -i inline '!visited[$0]++ { print $0 }' *.sfdx.log
}

######################################################################################################
###  start
######################################################################################################

rm -rf $TMP_PKG_DIR  # only local debug needs this
login_to_org $2
$GOAL  # <<<<<<<<<<<<<<<<<<<<<<<<<<<  this invokes one of valid functions.


echo -e "#\nExit code: $RC"
exit $RC

#TODO Deploy communities!  sfdx force:source:deploy -u TargetOrg -p unpackaged/communities -w 60
