/**
 * Created by Andrii Kryvolap.
 */

({
    doUpdateRecords: function (component, event, helper, changedItem) {
        if (component.get('v.skipUpdate')) return;
        var spinner = component.find('recordsSpinner');
        spinner.show();
        var filter = component.get('v.peFilter');
        var searchText = filter.searchText;
        var status = component.get('v.peFilter.participantStatus');
        for (var key in filter) {
            if (key != 'searchText' && filter[key] == '') {
                filter[key] = null;
            }
        }
        var filterJSON = JSON.stringify(filter);
        var paginationJSON = JSON.stringify(component.get('v.paginationData'));

        communityService.executeAction(
            component,
            'getRecords',
            {
                filterJSON: filterJSON,
                paginationJSON: paginationJSON,
                userMode: communityService.getUserMode(),
                changedItem: changedItem,
                delegateId: communityService.getDelegateId(),
                emancipatedPE: component.get('v.showEmancipatedOnly'),
                sponsorName: communityService.getCurrentCommunityTemplateName()
            },
            function (returnValue) {
                if (component.get('v.peFilter').searchText !== searchText) return;
                var result = JSON.parse(returnValue);
                component.set('v.skipUpdate', true);
                component.set('v.pageList', result.peList);
                if(result.peFilter.participantStatus == 'Eligibility Passed' && status == 'Sent to Study Hub'){
                    result.peFilter.participantStatus = 'Sent to Study Hub';
                }
                component.set('v.peFilter', result.peFilter);
                component.set('v.peFilterData', result.peFilterData);
                component.set(
                    'v.paginationData.allRecordsCount',
                    result.paginationData.allRecordsCount
                );
                component.set('v.statusChanged',false);
                component.set('v.paginationData.currentPage', result.paginationData.currentPage);
                component.set(
                    'v.paginationData.currentPageCount',
                    result.paginationData.currentPageCount
                );
                component.set('v.skipUpdate', false);
                /*if (communityService.getUserMode() != 'Participant' && result.peList) {
                for (let pItem in result.peList) {
                    var hasEmancipatedParticipants = false;
                    if (result.peList[pItem].hasEmancipatedParticipants) {
                        hasEmancipatedParticipants = true;
                        break;
                    }
                }
                component.set('v.hasEmancipatedParticipants', hasEmancipatedParticipants);
                component.getEvent('onInit').fire();
            }*/
                spinner.hide();
            }
        );
    },

    exportAllHelper: function (component, event, helper) {
        var spinner = component.find('Spinnerpopup');
        spinner.show();
        var startPos = component.get('v.startPos');
        var endPos = component.get('v.endPos');
        var totalCount = component.get('v.totalCount');
        var peFilterData = component.get('v.peFilterDataBackup');
        var studies = [];
        var studySites = [];
        for (var key in peFilterData.studies) {
            if (peFilterData.studies[key].value != null) {
                studies.push(peFilterData.studies[key].value);
            }
        }
        for (var key in peFilterData.studySites) {
            if (peFilterData.studySites[key].value != null) {
                studySites.push(peFilterData.studySites[key].value);
            }
        }
        var action = component.get('c.getExportAllList');
        action.setParams({
            studies: studies,
            studySites: studySites,
            startPos: startPos,
            endPos: endPos
        });

        action.setCallback(this, function (a) {
            var state = a.getState(); // get the response state
            if (state == 'SUCCESS') {
                var temp = a.getReturnValue();
                component.set('v.totalCount', temp.totalCount);
                var csvFinalList = temp.partLists;
                var csvtemp = component.get('v.CsvList');
                var newarr;
                if (!component.get('v.isFirstTime')) {
                    newarr = csvtemp.concat(csvFinalList);
                } else {
                    newarr = csvFinalList;
                    component.set('v.isFirstTime', false);
                }
                component.set('v.CsvList', newarr);
                var currentCount = newarr.length;
               
                
                var counterLimit = component.get('v.counterLimit');
                var finaltotalCount = component.get('v.totalCount');
               
                if (finaltotalCount > 100000) {
                    finaltotalCount = 100000;
                }
                if (currentCount < finaltotalCount) {
                    counterLimit = counterLimit + 45000;
                    component.set('v.counterLimit', counterLimit);
                }
                console.log('counterLimit new ' + counterLimit);
                if (temp.endPos < counterLimit && currentCount < finaltotalCount) {
                    startPos = endPos + 1;
                    endPos = endPos + 45000;
                    component.set('v.startPos', startPos);
                    component.set('v.endPos', endPos);
                    spinner.hide();
                    helper.exportAllHelper(component, event, helper);
                } else {
                    spinner.hide();
                    helper.downloadCsvFile(component, event, helper, newarr); 
                }
            }
        });
        $A.enqueueAction(action);
    },

    downloadCsvFile: function (component, event, helper, objectRecords) {
        //       component.set('v.CsvList','');
        var spinner = component.find('Spinnerpopup');
        // var spinner = component.find('recordsSpinner');
        spinner.show();
       
         
        var csvStringResult, counter, keys, columnDivider, lineDivider;
        if (objectRecords == null || !objectRecords.length) {
            return null;
        }
        columnDivider = ',';
        lineDivider = '\n';
        // var header = ['Participant Profile Name','Study Code Name',	'Study Site Name','Participant_Status__c','isCheckedlatest'];
        var header = [
            'Participant Profile Name',
            'MRN Id',
            'Patient ID',
            'Referred Date',
            'Study Code Name',
            'Study Site Name',
            'Investigator Name',
            'Participant Status',
            'Status Change Reason',
            'Participant Status Last Changed Date',
            'Last Status Changed Notes',
            'Pre-screening 1 Status',
            'Pre-screening 1 Completed by',
            'Pre-screening Date',
            'Referral Completed by',
            'Referral Source',
            'Initial Visit Date',
            'Initial Visit Time'
        ];

        csvStringResult = '';
        csvStringResult += header.join(columnDivider);
        csvStringResult += lineDivider;
       
        for (var i = 0; i < objectRecords.length; i++) {
           

            if (objectRecords[i]['pe']['Name'] !== undefined) {
                csvStringResult += '"' + objectRecords[i]['pe']['Name'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }

            if (objectRecords[i]['pe']['MRN_Id__c'] !== undefined) {
                csvStringResult += '"' + objectRecords[i]['pe']['MRN_Id__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }

            if (objectRecords[i]['pe']['Patient_ID__c'] !== undefined) {
                csvStringResult += '"' + objectRecords[i]['pe']['Patient_ID__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }
            if (objectRecords[i]['pe']['Referred_Date__c'] !== undefined) {
                csvStringResult += '"' + objectRecords[i]['pe']['Referred_Date__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }

            if (objectRecords[i]['pe']['Clinical_Trial_Profile__r']['Study_Code_Name__c'] !== undefined) {
                csvStringResult +=
                    '"' +
                    objectRecords[i]['pe']['Clinical_Trial_Profile__r']['Study_Code_Name__c'] +
                    '"' +
                    ',';
            } else {
                csvStringResult += '" "' + ',';
            }

            if (objectRecords[i]['pe']['Study_Site__r']['Name'] !== undefined) {
                csvStringResult += '"' + objectRecords[i]['pe']['Study_Site__r']['Name'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }

            if (objectRecords[i]['pe']['PI_Contact__r']['Full_Name__c'] !== undefined) {
                csvStringResult +=
                    '"' + objectRecords[i]['pe']['PI_Contact__r']['Full_Name__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }

            if (objectRecords[i]['pe']['Participant_Status__c'] !== undefined) {
                let pstatus = objectRecords[i]['pe']['Participant_Status__c'];
                if(objectRecords[i]['pe']['Participant_Status__c']=='Eligibility Passed' 
                   && (objectRecords[i]['pe']['Clinical_Trial_Profile__r']['Initial_Visit_Required__c'] == true 
                       || objectRecords[i]['pe']['Clinical_Trial_Profile__r']['Promote_to_SH__c'] == true)){
                    pstatus = 'Sent to Study Hub';
                }
                
                csvStringResult += '"' + pstatus + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }
            if (objectRecords[i]['pe']['Non_Enrollment_Reason__c'] !== undefined) {
                csvStringResult += '"' + objectRecords[i]['pe']['Non_Enrollment_Reason__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }

            if (objectRecords[i]['pe']['Participant_Status_Last_Changed_Date__c'] !== undefined) {
                csvStringResult +=
                    '"' + objectRecords[i]['pe']['Participant_Status_Last_Changed_Date__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }

            if (objectRecords[i]['pe']['Last_Status_Changed_Notes__c'] !== undefined) {
                csvStringResult +=
                    '"' + objectRecords[i]['pe']['Last_Status_Changed_Notes__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }

            if (objectRecords[i]['pe']['Medical_Record_Review_Status__c'] !== undefined) {
                csvStringResult +=
                    '"' + objectRecords[i]['pe']['Medical_Record_Review_Status__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }
            if (objectRecords[i]['pe']['Medical_Record_Review_Completedby_Name__c'] !== undefined) {
                csvStringResult +=
                    '"' + objectRecords[i]['pe']['Medical_Record_Review_Completedby_Name__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }
            if (objectRecords[i]['pe']['Medical_Record_Review_Completed_Date__c'] !== undefined) {
                csvStringResult +=
                    '"' + objectRecords[i]['pe']['Medical_Record_Review_Completed_Date__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }

            if (objectRecords[i]['pe']['Referral_Completedby_Name__c'] !== undefined) {
                csvStringResult +=
                    '"' + objectRecords[i]['pe']['Referral_Completedby_Name__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }

            if (objectRecords[i]['pe']['Referral_Source__c'] !== undefined) {
                csvStringResult += '"' + objectRecords[i]['pe']['Referral_Source__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }
            
            if (objectRecords[i]['pe']['Initial_visit_scheduled_date__c'] !== undefined) {
                csvStringResult += '"' + objectRecords[i]['pe']['Initial_visit_scheduled_date__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }
          
            
            if (objectRecords[i]['initialVisitScheduleTime'] !== undefined) {
               csvStringResult += '"' + objectRecords[i]['initialVisitScheduleTime'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }

            csvStringResult += lineDivider;
        }
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csvStringResult);
        hiddenElement.target = '_self'; //
        hiddenElement.download = 'ExportData.csv'; // CSV file Name* you can change it.[only name not .csv]
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file
        //spinner.hide();
        component.find('Spinnerpopup').hide();
        console.timeEnd('advf');
    }
});