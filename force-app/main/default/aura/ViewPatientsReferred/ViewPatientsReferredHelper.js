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
        // alert('@@@@@@ startPos   ' +startPos);
        // alert('@@@@@@ endPos     ' +endPos);
        // alert('@@@@@@ totalCount ' +totalCount);
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
                //console.log('partlistlength-->'+temp.partList.length);
                 //console.log('temp--->'+JSON.stringify(temp));
                component.set('v.totalCount', temp.totalCount);
                var csvFinalList = temp.partList;
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
                console.log('currentCount ' + currentCount);
                console.log('finaltotalCount ' + finaltotalCount);
                console.log('counterLimit ' + counterLimit);
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
                    console.log('in else');
                    helper.downloadCsvFile(component, event, helper, temp);
                }
            }
        });
        $A.enqueueAction(action);
    },

    downloadCsvFile: function (component, event, helper, objectRecords) {
        console.time('advf');
        //       component.set('v.CsvList','');
        var spinner = component.find('Spinnerpopup');
        // var spinner = component.find('recordsSpinner');
        spinner.show();
           //console.log('@@@@@@@@@@@@----------> '+JSON.stringify(objectRecords));
        //console.log('@@@@@@@@@@@@---> ' + objectRecords.partList.length);
        //   console.table(objectRecords);
        var csvStringResult, counter, keys, columnDivider, lineDivider;
        if (objectRecords.partList == null || !objectRecords.partList.length) {
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
        //console.log('@@@@@@ ' + objectRecords.partList.length);
        for (var i = 0; i < objectRecords.partList.length; i++) {
             //console.log('objectRecords ' +(objectRecords.partList[i]['Name']));

            if (objectRecords.partList[i]['Name'] !== undefined) {
                csvStringResult += '"' + objectRecords.partList[i]['Name'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }

            if (objectRecords.partList[i]['MRN_Id__c'] !== undefined) {
                csvStringResult += '"' + objectRecords.partList[i]['MRN_Id__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }

            if (objectRecords.partList[i]['Patient_ID__c'] !== undefined) {
                csvStringResult += '"' + objectRecords.partList[i]['Patient_ID__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }
            if (objectRecords.partList[i]['Referred_Date__c'] !== undefined) {
                csvStringResult += '"' + objectRecords.partList[i]['Referred_Date__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }

            if (objectRecords.partList[i]['Clinical_Trial_Profile__r']['Study_Code_Name__c'] !== undefined) {
                csvStringResult +=
                    '"' +
                    objectRecords.partList[i]['Clinical_Trial_Profile__r']['Study_Code_Name__c'] +
                    '"' +
                    ',';
            } else {
                csvStringResult += '" "' + ',';
            }

            if (objectRecords.partList[i]['Study_Site__r']['Name'] !== undefined) {
                csvStringResult += '"' + objectRecords.partList[i]['Study_Site__r']['Name'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }

            if (objectRecords.partList[i]['PI_Contact__r']['Full_Name__c'] !== undefined) {
                csvStringResult +=
                    '"' + objectRecords.partList[i]['PI_Contact__r']['Full_Name__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }

            if (objectRecords.partList[i]['Participant_Status__c'] !== undefined) {
                csvStringResult += '"' + objectRecords.partList[i]['Participant_Status__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }
            if (objectRecords.partList[i]['Non_Enrollment_Reason__c'] !== undefined) {
                csvStringResult += '"' + objectRecords.partList[i]['Non_Enrollment_Reason__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }

            if (objectRecords.partList[i]['Participant_Status_Last_Changed_Date__c'] !== undefined) {
                csvStringResult +=
                    '"' + objectRecords.partList[i]['Participant_Status_Last_Changed_Date__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }

            if (objectRecords.partList[i]['Last_Status_Changed_Notes__c'] !== undefined) {
                csvStringResult +=
                    '"' + objectRecords.partList[i]['Last_Status_Changed_Notes__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }

            if (objectRecords.partList[i]['Medical_Record_Review_Status__c'] !== undefined) {
                csvStringResult +=
                    '"' + objectRecords.partList[i]['Medical_Record_Review_Status__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }
            if (objectRecords.partList[i]['Medical_Record_Review_Completedby_Name__c'] !== undefined) {
                csvStringResult +=
                    '"' + objectRecords.partList[i]['Medical_Record_Review_Completedby_Name__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }
            if (objectRecords.partList[i]['Medical_Record_Review_Completed_Date__c'] !== undefined) {
                csvStringResult +=
                    '"' + objectRecords.partList[i]['Medical_Record_Review_Completed_Date__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }

            if (objectRecords.partList[i]['Referral_Completedby_Name__c'] !== undefined) {
                csvStringResult +=
                    '"' + objectRecords.partList[i]['Referral_Completedby_Name__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }

            if (objectRecords.partList[i]['Referral_Source__c'] !== undefined) {
                csvStringResult += '"' + objectRecords.partList[i]['Referral_Source__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }
            
            if (objectRecords.partList[i]['Initial_visit_scheduled_date__c'] !== undefined) {
                csvStringResult += '"' + objectRecords.partList[i]['Initial_visit_scheduled_date__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }
            //console.log('objectRecords[i] ' +(objectRecords.initialVisitScheduleTime[i]));
            
            if (objectRecords.initialVisitScheduleTime[i] !== undefined) {
               csvStringResult += '"' + objectRecords.initialVisitScheduleTime[i] + '"' + ',';
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