({
    validateAge: function (component, event, helper) {
        let isAllValid = true;
        var filterValue = component.get('v.filterList');
        var AgeFrom = component.find('AgeFrom');
        var AgeTo = component.find('AgeTo');
        AgeTo.setCustomValidity('');
        AgeFrom.setCustomValidity('');
        if (filterValue[0].AgeFrom != '' && filterValue[0].AgeTo == '') {
            component.set('v.filterList[0].AgeFrom', filterValue[0].AgeFrom);
            component.set('v.filterList[0].AgeTo', 150);
        } else if (filterValue[0].AgeFrom == '' && filterValue[0].AgeTo != '') {
            component.set('v.filterList[0].AgeFrom', 0);
            component.set('v.filterList[0].AgeTo', filterValue[0].AgeTo);
        } else if (
            filterValue[0].AgeFrom != '' &&
            filterValue[0].AgeTo != '' &&
            parseInt(filterValue[0].AgeFrom) > parseInt(filterValue[0].AgeTo)
        ) {
            AgeTo.setCustomValidity('Invalid Age Range');
            AgeFrom.setCustomValidity('Invalid Age Range');
        } else {
            AgeTo.setCustomValidity('');
            AgeFrom.setCustomValidity('');
        }
        var controlAuraIds = ['AgeFrom', 'AgeTo'];
        isAllValid = controlAuraIds.reduce(function (isValidSoFar, controlAuraId) {
            var inputCmp = component.find(controlAuraId);
            inputCmp.reportValidity();
            return isValidSoFar && inputCmp.checkValidity();
        }, true);
        return isAllValid;
    },

    handleSearchHelper: function (component, event, helper) {
        console.log('insidehelper');
        component.find('Spinnerpopup').show();
        component.set('v.lstPR_no', '');
        component.set('v.lstPR_yes', '');
        component.set('v.SelectedIds', '');
        component.set('v.DeSelectedIds', '');
        component.set('v.count', 0);
        component.set('v.enablePromoteToSH', true);
        component.set('v.PageNumber', 1);
        component.set('v.TotalPages', 0);
        component.set('v.TotalRecords', 0);
        component.set('v.RecordStart', 0);
        component.set('v.RecordEnd', 0);
        component.set('v.pageSize', component.find('pageSize').get('v.value'));
        component.set('v.SortBydefault', component.find('sortby').get('v.value'));
        component.set('v.flagSet', false);
        var RowItemList = component.get('v.filterList');
        var pageNumber = component.get('v.PageNumber');
        var pageSize = component.find('pageSize').get('v.value');
        /**  alert('status-->'+RowItemList[0].Status);
        alert('study-->'+RowItemList[0].Study);
        alert('site--->'+RowItemList[0].StudySites);
        alert('source-->'+RowItemList[0].Source);
        alert('pstatus-->'+RowItemList[0].ParticipantStatus);
        alert('AgeFrom-->'+RowItemList[0].AgeFrom);
        alert('AgeTo-->'+RowItemList[0].AgeTo);
        alert('Ethnicity-->'+RowItemList[0].Ethnicity);
        alert('Sex-->'+RowItemList[0].Sex);
        alert('isHighRiskOccupation-->'+RowItemList[0].isHighRiskOccupation);
        alert('isComorbidities-->'+RowItemList[0].isComorbidities);
        alert('isInitialVisitScheduled-->'+RowItemList[0].isInitialVisitScheduled);
         alert('isExport-->'+RowItemList[0].isExport);  **/

        component.set('v.oStatus', RowItemList[0].Status);
        component.set('v.oStudy', RowItemList[0].Study);
        component.set('v.oStudySites', RowItemList[0].StudySites);
        component.set('v.oSource', RowItemList[0].Source);
        component.set('v.oParticipantStatus', RowItemList[0].ParticipantStatus);
        component.set('v.oAgeFrom', RowItemList[0].AgeFrom);
        component.set('v.oAgeTo', RowItemList[0].AgeTo);
        component.set('v.oEthnicity', RowItemList[0].Ethnicity);
        component.set('v.oSex', RowItemList[0].Sex);
        component.set('v.oisHighRiskOccupation', RowItemList[0].isHighRiskOccupation);
        component.set('v.oisComorbidities', RowItemList[0].isComorbidities);
        component.set('v.oisInitialVisitScheduled', RowItemList[0].isInitialVisitScheduled);

        RowItemList[0].pageNumber = pageNumber;
        RowItemList[0].pageSize = pageSize;
        RowItemList[0].SelectedIds = component.get('v.SelectedIds');
        RowItemList[0].DeselectedIds = component.get('v.DeSelectedIds');
        RowItemList[0].Sortby = component.find('sortby').get('v.value');
        RowItemList[0].highPrioritySelected_YesIds = component.get('v.lstPR_yes');
        RowItemList[0].highPrioritySelected_NoIds = component.get('v.lstPR_no');

        component.set('v.count', 0);
        var filterValue = RowItemList;

        var bol = helper.validateAge(component, event, helper);
        filterValue = JSON.stringify(filterValue);
        var bulkaction = component.get('v.ActionSelected');
        //alert(bulkaction);
        var bulkStatus = component.get('v.statusSelected');
         //alert(bulkStatus);
       
        //console.log('########Search ' +filterValue);
        if (bol) {
            if (!communityService.isInitialized()) return;
            //component.set('v.oldfilterList',component.get("v.filterList"));
            communityService.executeAction(
                component,
                'fetchData',
                {
                    filterJSON: filterValue,
                    bulkAction: bulkaction,
                    BulkStatus: bulkStatus
                    
                },
                function (returnValue) {
                    var result = returnValue;
                    //alert(JSON.stringify(result));
                    // console.log(JSON.stringify(result));
                    component.set('v.PaginationList', result.FilterImpacts);
                    component.set('v.PageNumber', result.pageNumber);
                    component.set('v.TotalRecords', result.totalRecords);
                    component.set('v.filterList[0].perRecordCount', result.totalRecords);
                    component.set('v.RecordStart', result.recordStart);
                    component.set('v.RecordEnd', result.recordEnd);
                    component.set('v.TotalPages', Math.ceil(result.totalRecords / pageSize));
                    component.set('v.IsPromoteToSHLimit', result.IsPromoteToSHLimit);
                    //alert(component.get('v.IsPromoteToSHLimit'));
                    if (component.get('v.RecordEnd') == 0) {
                        component.set('v.RecordStart', 0);
                    }
                    if (result.IsPromoteToSH == false) {
                        component.set('v.PromoteToSH', true);
                    } else {
                        component.set('v.PromoteToSH', false);
                    }
                    component.find('Spinnerpopup').hide();
                    component.set('v.filterList', RowItemList);
                    component.set('v.enablePP', result.enablePP);
                    component.set('v.enableSH', result.enableSH);
                    console.log('Cpp--->'+result.enablePP);
                    console.log('promote--->'+result.enableSH);
                }
            );
            component.set('v.SelectAll', false);
        } else {
            component.find('Spinnerpopup').hide();
        }
    },

    getchunkdataforCSV: function (component, event, helper) {
        var filterValue = component.get('v.filterList');
        filterValue[0].startPos = filterValue[0].endPos + 1;
        filterValue[0].endPos = filterValue[0].endPos + 45000;
        var bulkaction = component.get('v.ActionSelected');
        var bulkStatus = component.get('v.statusSelected');
        communityService.executeAction(
            component,
            'fetchData',
            {
                filterJSON: JSON.stringify(filterValue),
                bulkAction: bulkaction,
                BulkStatus: bulkStatus
            },
            function (returnValue1) {
                console.log('length2 ' + returnValue1.FilterImpacts.length);
                var csvtemp = component.get('v.CsvList');
                var newarr = csvtemp.concat(returnValue1.FilterImpacts);
                console.log('newarr-Length ' + newarr.length);
                //var result = JSON.stringify(returnValue);
                component.set('v.CsvList', newarr);
                var currentCount = newarr.length;
                //  console.log('@@startPos helper ' +filterValue[0].startPos);
                //  console.log('@@endPos helper ' +filterValue[0].endPos);
                //  console.log('@@perRecordCount helper ' +filterValue[0].perRecordCount);
                var counterLimit = component.get('v.counterLimit');
                var finaltotalCount = component.get('v.TotalRecords');
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
                if (
                    filterValue[0].endPos < counterLimit + 45000 &&
                    currentCount < finaltotalCount
                ) {
                    helper.getchunkdataforCSV(component, event, helper);
                } else {
                    // console.log('filterValue ' +JSON.stringify(filterValue));
                    component.set('v.filterList', filterValue);
                    component.set('v.filterList[0].isExport', false);
                    component.set('v.filterList[0].startPos', 1);
                    component.set('v.filterList[0].endPos', 45000);
                    helper.convertArrayOfObjectsToCSV(component, event, helper, newarr);
                }
            }
        );
    },

    getAllFilteredList: function (component, event, helper) {
        component.find('Spinnerpopup').show();
        var RowItemList = component.get('v.filterList');
        RowItemList[0].isExport = true;
        component.set('v.filterList', RowItemList);
        var perRecordCount = component.get('v.TotalRecords');
        var filterValue = component.get('v.filterList');
        //alert(filterValue);
        var bol = helper.validateAge(component, event, helper);
        filterValue = JSON.stringify(filterValue);
        //alert(filterValue);
        // console.table(filterValue);
        if (bol) {
            // console.log("Sellected Filter " + (filterValue));
            if (!communityService.isInitialized()) return;
            var bulkaction = component.get('v.ActionSelected');
            var bulkStatus = component.get('v.statusSelected');
            communityService.executeAction(
                component,
                'fetchData',
                {
                    filterJSON: filterValue,
                    bulkAction: bulkaction,
                    BulkStatus: bulkStatus
                },
                function (returnValue) {
                    var result = returnValue;
                    console.log('length1 ' + result.FilterImpacts.length);
                    var csvFinalList = result.FilterImpacts;
                    component.set('v.CsvList', csvFinalList);
                    filterValue = component.get('v.filterList');
                    //  console.log('@@startPos ' +result.retainFilter.startPos);
                    //  console.log('@@endPos ' +result.retainFilter.endPos);
                    //  console.log('@@perRecordCount ' +perRecordCount);
                    //  console.log('@@filterValue ' +JSON.stringify(filterValue));
                    if (
                        filterValue[0].endPos < 200000 &&
                        filterValue[0].perRecordCount < 200000 &&
                        perRecordCount > 0
                    ) {
                        helper.getchunkdataforCSV(component, event, helper);
                    } else {
                        //var result = JSON.stringify(returnValue);
                        component.set('v.CsvList', result.FilterImpacts);
                        if (result.FilterImpacts.length > 0) {
                            helper.convertArrayOfObjectsToCSV(
                                component,
                                event,
                                helper,
                                result.FilterImpacts
                            );
                        } else {
                            component.find('Spinnerpopup').hide();
                            var toastEvent = $A.get('e.force:showToast');
                            toastEvent.setParams({
                                duration: 400,
                                type: 'error',
                                message: $A.get('$Label.c.RH_Export_Error')
                            });
                            toastEvent.fire();
                        }
                    }
                }
            );
        }
        //spinner.hide();
    },

    convertArrayOfObjectsToCSV: function (component, event, helper, objectRecords) {
        console.time('advf');
        component.set('v.CsvList', '');
        // var spinner = component.find('recordsSpinner');
        //spinner.show();
        // console.log('@@@@@@@@@@@@ '+JSON.stringify(objectRecords));
        console.log('@@@@@@@@@@@@ ' + objectRecords.length);
        var csvStringResult, counter, keys, columnDivider, lineDivider;
        if (objectRecords == null || !objectRecords.length) {
            return null;
        }
        columnDivider = ',';
        lineDivider = '\n';
        // var header = ['Participant Profile Name','Study Code Name',	'Study Site Name','Participant_Status__c','isCheckedlatest'];
        var disclaimer = '"' + $A.get('$Label.c.Disclaimer_Text') + '"';
        disclaimer = disclaimer + columnDivider + lineDivider;
        var header = [
            'Protocol',
            'ID',
            'Source ID',
            'Source',
            'Received Date',
            'First Name',
            'Last Name',
            'Email',
            'Phone',
            'Phone Type',
            'Alternate Phone Number',
            'Alternate Phone Type',
            'Sex',
            'Age',
            'Ethnicity',
            'Comorbidities',
            'BMI',
            'High Risk Occupation',
            'Initial Visit Date',
            'Initial Visit Time',
            'Participant Status',
            'High Priority'
        ];
        header = disclaimer + header;
        csvStringResult = '';
        csvStringResult += header + columnDivider;
        csvStringResult += lineDivider;
      
        
        for (var i = 0; i < objectRecords.length; i++) {
            if (
                objectRecords[i]['pe']['Clinical_Trial_Profile__r']['Protocol_ID__c'] !== undefined
            ) {
                csvStringResult +=
                    '"' +
                    objectRecords[i]['pe']['Clinical_Trial_Profile__r']['Protocol_ID__c'] +
                    '"' +
                    ',';
            } else {
                csvStringResult += '" "' + ',';
            }

            if (objectRecords[i]['pe']['Name'] !== undefined) {
                csvStringResult += '"' + objectRecords[i]['pe']['Name'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }

            //Logic for Source ID start
            if (objectRecords[i]['pe']['Referral_Source__c'] == 'PI') {
                if (objectRecords[i]['pe']['MRN_Id__c'] !== undefined) {
                    csvStringResult += '"' + objectRecords[i]['pe']['MRN_Id__c'] + '"' + ',';
                } else {
                    csvStringResult += '" "' + ',';
                }
            } else if (objectRecords[i]['pe']['Referral_Source__c'] == 'HCP') {
                if (objectRecords[i]['pe']['Patient_ID__c'] !== undefined) {
                    csvStringResult += '"' + objectRecords[i]['pe']['Patient_ID__c'] + '"' + ',';
                } else {
                    csvStringResult += '" "' + ',';
                }
            } else {
                if (objectRecords[i]['pe']['Patient_ID__c'] !== undefined) {
                    csvStringResult += '"' + objectRecords[i]['pe']['Patient_ID__c'] + '"' + ',';
                } else {
                    csvStringResult += '" "' + ',';
                }
            }
            //Logic for Source ID end

            if (objectRecords[i]['pe']['Source_Type__c'] !== undefined) {
                csvStringResult += '"' + objectRecords[i]['pe']['Source_Type__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }

            if (objectRecords[i]['pe']['CreatedDate'] !== undefined) {
                csvStringResult += '"' + objectRecords[i]['pe']['CreatedDate'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }
            if (objectRecords[i]['pe']['Participant__r'] !== undefined && objectRecords[i]['pe']['Participant__r']['First_Name__c'] !== undefined) {
                csvStringResult +=
                    '"' + objectRecords[i]['pe']['Participant__r']['First_Name__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }
            if (objectRecords[i]['pe']['Participant__r'] !== undefined && objectRecords[i]['pe']['Participant__r']['Last_Name__c'] !== undefined) {
                csvStringResult +=
                    '"' + objectRecords[i]['pe']['Participant__r']['Last_Name__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }
            if (objectRecords[i]['pe']['Participant__r'] !== undefined && objectRecords[i]['pe']['Participant__r']['Email__c'] !== undefined) {
                csvStringResult +=
                    '"' + objectRecords[i]['pe']['Participant__r']['Email__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }
            if (objectRecords[i]['pe']['Participant__r'] !== undefined && objectRecords[i]['pe']['Participant__r']['Phone__c'] !== undefined) {
                csvStringResult +=
                    '"' + objectRecords[i]['pe']['Participant__r']['Phone__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }
            if (objectRecords[i]['pe']['Participant__r'] !== undefined && objectRecords[i]['pe']['Participant__r']['Phone_Type__c'] !== undefined) {
                csvStringResult +=
                    '"' + objectRecords[i]['pe']['Participant__r']['Phone_Type__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }
            if (
                objectRecords[i]['pe']['Participant__r'] !== undefined && objectRecords[i]['pe']['Participant__r']['Alternative_Phone_Number__c'] !==
                undefined
            ) {
                csvStringResult +=
                    '"' +
                    objectRecords[i]['pe']['Participant__r']['Alternative_Phone_Number__c'] +
                    '"' +
                    ',';
            } else {
                csvStringResult += '" "' + ',';
            }
            if (
                objectRecords[i]['pe']['Participant__r'] !== undefined && objectRecords[i]['pe']['Participant__r']['Alternative_Phone_Type__c'] !== undefined
            ) {
                csvStringResult +=
                    '"' +
                    objectRecords[i]['pe']['Participant__r']['Alternative_Phone_Type__c'] +
                    '"' +
                    ',';
            } else {
                csvStringResult += '" "' + ',';
            }

            if (objectRecords[i]['pe']['Participant__r'] !== undefined && objectRecords[i]['pe']['Participant__r']['Gender_Technical__c'] !== undefined) {
                csvStringResult +=
                    '"' +
                    objectRecords[i]['pe']['Participant__r']['Gender_Technical__c'] +
                    '"' +
                    ',';
            } else {
                csvStringResult += '" "' + ',';
            }

            if (objectRecords[i]['pe']['Participant__r'] !== undefined && objectRecords[i]['pe']['Participant__r']['Present_Age__c'] !== undefined) {
                csvStringResult +=
                    '"' + objectRecords[i]['pe']['Participant__r']['Present_Age__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }

            if (objectRecords[i]['pe']['Participant__r'] !== undefined && objectRecords[i]['pe']['Participant__r']['Ethnicity__c'] !== undefined) {
                var val = objectRecords[i]['pe']['Participant__r']['Ethnicity__c'];
                var arr = val.split(';');
                // var str = [];
                // var x;
                // for(x of arr){
                //     var arrTemp = x.split('-');
                //     str.push(arrTemp[1]);
                // }
                // console.log('@@@@@######## '+ str);
                // console.log('@@@@@######## '+ str.join());

                csvStringResult += '"' + arr.join() + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }

            if (objectRecords[i]['pe']['Comorbidities__c'] !== undefined) {
                csvStringResult += '"' + objectRecords[i]['pe']['Comorbidities__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }

            if (objectRecords[i]['pe']['Participant__r'] !== undefined && objectRecords[i]['pe']['Participant__r']['BMI__c'] !== undefined) {
                csvStringResult +=
                    '"' + objectRecords[i]['pe']['Participant__r']['BMI__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }

            if (objectRecords[i]['pe']['HighRisk_Indicator__c'] !== undefined) {
                csvStringResult +=
                    '"' + objectRecords[i]['pe']['HighRisk_Indicator__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }

            if (objectRecords[i]['pe']['Initial_visit_scheduled_date__c'] !== undefined) {
                csvStringResult +=
                    '"' + objectRecords[i]['pe']['Initial_visit_scheduled_date__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }

            if (objectRecords[i]['initialVisitScheduleTime'] !== undefined) {
                csvStringResult += '"' + objectRecords[i]['initialVisitScheduleTime'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }

            if (objectRecords[i]['pe']['Participant_Status__c'] !== undefined) {
                if(objectRecords[i]['pe']['Participant_Status__c']=='Eligibility Passed' 
                   && (objectRecords[i]['pe']['Clinical_Trial_Profile__r']['Initial_Visit_Required__c'] == true 
                       || objectRecords[i]['pe']['Clinical_Trial_Profile__r']['Promote_to_SH__c'] == true)){
                    objectRecords[i]['pe']['Participant_Status__c'] = 'Sent to Study Hub';
                }
                csvStringResult +=
                    '"' + objectRecords[i]['pe']['Participant_Status__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }

            if (objectRecords[i]['priorityReferral'] !== undefined) {
                csvStringResult += '"' + objectRecords[i]['priorityReferral'] + '"' + ',';
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
    },
    showToast: function (component, event, helper) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            duration: 400,
            type: 'success',
            message: $A.get('$Label.c.Records_sent_to_SH')
        });
        toastEvent.fire();
    },
    showToastforInvite: function (component, event, helper,count) {
        var toastEvent = $A.get('e.force:showToast');
        //var count = component.get('v.count');
        toastEvent.setParams({
            duration: 400,
            type: 'success',
            message: count+' '+ $A.get('$Label.c.Records_all_invited')
        });
        toastEvent.fire();
    },
    showToastLimit: function (component, event, helper) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            duration: 400,
            type: 'error',
            message: $A.get('$Label.c.ParticipantLimit')
        });
        toastEvent.fire();
    },
    doinitHelper: function (component, event, helper) {
        component.find('Spinnerpopup').show();
        component.set('v.flagSet', false);
        component.set('v.filterList[0].AgeFrom', 0);
        component.set('v.filterList[0].AgeTo', 150);
        component.set('v.lstPR_no', '');
        component.set('v.lstPR_yes', '');
        component.set('v.SelectedIds', '');
        component.set('v.DeSelectedIds', '');
        component.set('v.count', 0);
        component.set('v.enablePromoteToSH', true);
        component.set('v.PageNumber', 1);
        component.set('v.TotalPages', 0);
        component.set('v.TotalRecords', 0);
        component.set('v.RecordStart', 0);
        component.set('v.RecordEnd', 0);
        component.set('v.pageSize', 5);
        component.set('v.SortBydefault', 'Received Date(Oldest First)');
        var perRecordCount = component.get('v.TotalRecords');
        //var spinner = component.find('recordsSpinner');
        //spinner.show();
        var RowItemList = component.get('v.filterList');
        if (RowItemList.length > 0) {
            RowItemList = [];
        }
        var peFilterData = component.get('v.peFilterData');
        var psIfActive = component.get('v.psIfActive');
        RowItemList.push({
            Status: peFilterData.activePE[0].value,
            Study: peFilterData.studies[0].value,
            StudySites: '',
            Source: '',
            ParticipantStatus: psIfActive[1].value,
            isHighRiskOccupation: false,
            isComorbidities: false,
            isInitialVisitScheduled: false,
            AgeFrom: '0',
            AgeTo: '150',
            Ethnicity: '',
            Sex: '',
            pageNumber: '',
            pageSize: '',
            SelectedIds: '',
            DeselectedIds: '',
            isExport: '',
            Sortby: '',
            highPrioritySelected_YesIds: '',
            highPrioritySelected_NoIds: '',
            startPos: 1,
            endPos: 45000,
            perRecordCount: perRecordCount
        });
        component.set('v.filterList', RowItemList);

        var pageNumber = component.get('v.PageNumber');
        var pageSize = component.find('pageSize').get('v.value');
        //alert('status-->'+RowItemList[0].Status);
        //alert('study-->'+RowItemList[0].Study);
        //alert('site--->'+RowItemList[0].StudySites);
        //alert('source-->'+RowItemList[0].Source);
        //alert('pstatus-->'+RowItemList[0].ParticipantStatus);

        component.set('v.oStatus', peFilterData.activePE[0].value);
        component.set('v.oStudy', peFilterData.studies[0].value);
        component.set('v.oStudySites', '');
        component.set('v.oSource', '');
        component.set('v.oParticipantStatus', psIfActive[1].value);
        component.set('v.oAgeFrom', '0');
        component.set('v.oAgeTo', '150');
        component.set('v.oEthnicity', '');
        component.set('v.oSex', '');
        component.set('v.oisHighRiskOccupation', 'false');
        component.set('v.oisComorbidities', 'false');
        component.set('v.oisInitialVisitScheduled', 'false');

        RowItemList[0].pageNumber = pageNumber;
        RowItemList[0].pageSize = pageSize;
        RowItemList[0].SelectedIds = component.get('v.SelectedIds');
        RowItemList[0].DeselectedIds = component.get('v.DeSelectedIds');
        RowItemList[0].Sortby = component.find('sortby').get('v.value');
        RowItemList[0].highPrioritySelected_YesIds = component.get('v.lstPR_yes');
        RowItemList[0].highPrioritySelected_NoIds = component.get('v.lstPR_no');

        component.set('v.count', 0);
        var filterValue = RowItemList;

        var bol = helper.validateAge(component, event, helper);
        filterValue = JSON.stringify(filterValue);

        if (bol) {
            //component.set('v.oldfilterList',component.get("v.filterList"));
            if (!communityService.isInitialized()) return;
            var bulkaction = component.get('v.ActionSelected');
            var bulkStatus = component.get('v.statusSelected');
            communityService.executeAction(
                component,
                'fetchData',
                {
                    filterJSON: filterValue,
                    bulkAction: bulkaction,
                    BulkStatus: bulkStatus
                },
                function (returnValue) {
                    var result = returnValue;
                    //alert(JSON.stringify(result));
                    // console.log(JSON.stringify(result));
                    component.set('v.PaginationList', result.FilterImpacts);
                    component.set('v.PageNumber', result.pageNumber);
                    component.set('v.TotalRecords', result.totalRecords);
                    component.set('v.filterList[0].perRecordCount', result.totalRecords);
                    component.set('v.RecordStart', result.recordStart);
                    component.set('v.RecordEnd', result.recordEnd);
                    component.set('v.TotalPages', Math.ceil(result.totalRecords / pageSize));
                    component.set('v.IsPromoteToSHLimit', result.IsPromoteToSHLimit);
                    if (result.IsPromoteToSH == false) {
                        component.set('v.PromoteToSH', true);
                    } else {
                        component.set('v.PromoteToSH', false);
                    }
                    component.find('Spinnerpopup').hide();
                    //component.set('v.oldfilterList',component.get("v.filterList"));
                    component.set('v.filterList', RowItemList);
                    component.set('v.enablePP', result.enablePP);
                    component.set('v.enableSH', result.enableSH);
                }
            );
        } else {
            component.find('Spinnerpopup').hide();
        }
        component.set('v.isFromDoinit', true);
        component.set('v.SelectAll', false);
    }
});