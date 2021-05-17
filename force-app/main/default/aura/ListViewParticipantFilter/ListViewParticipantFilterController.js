({
    doInit: function (component, event, helper) {
        component.set('v.isFromDoinit', true);
        component.set('v.lstPR_no', '');
        component.set('v.lstPR_yes', '');
        component.set('v.SelectedIds', '');
        component.set('v.DeSelectedIds', '');
        component.set('v.count', 0);
        component.set('v.enablePromoteToSH', true);
        var perRecordCount = component.get('v.TotalRecords');
        //var spinner = component.find('recordsSpinner');
        //spinner.show();
        var RowItemList = component.get('v.filterList');
        if (RowItemList.length > 0) {
            RowItemList = [];
        }
        var sexList = [];
        var obj = {};
        obj.label = $A.get('$Label.c.AF_All');
        obj.value = 'All';
        sexList.push(obj);
        obj = {};
        
        obj.label = $A.get('$Label.c.AF_Male');
        obj.value = 'M';
        sexList.push(obj);
        obj = {};
        
        obj.label = $A.get('$Label.c.AF_Female');
        obj.value = 'F';
        sexList.push(obj);
        obj = {};
        component.set('v.optionSex', sexList);
        
        var sortBy = [];
        var obj1 = {};
        obj1.label = $A.get('$Label.c.AF_ReceivedDate_OF');
        obj1.value = 'Received Date(Oldest First)';
        sortBy.push(obj1);
        obj1 = {};
        
        obj1.label = $A.get('$Label.c.AF_ReceivedDate_NF');
        obj1.value = 'Received Date(Newest First)';
        sortBy.push(obj1);
        obj1 = {};
        
        obj1.label = $A.get('$Label.c.AF_ID_D');
        obj1.value = 'Descending';
        sortBy.push(obj1);
        obj1 = {};
        
        obj1.label = $A.get('$Label.c.AF_ID_A');
        obj1.value = 'Ascending';
        sortBy.push(obj1);
        obj1 = {};
        component.set('v.SortBy', sortBy);
        
        var PR = [];
        var obj2 = {};
        obj2.label = $A.get('$Label.c.Yes');
        obj2.value = 'Yes';
        PR.push(obj2);
        obj2 = {};
        
        obj2.label = $A.get('$Label.c.No');
        obj2.value = 'No';
        PR.push(obj2);
        obj2 = {};
        component.set('v.PriorityReferral', PR);
        
        var peFilterData = component.get('v.peFilterData');
        RowItemList.push({
            Status: peFilterData.activePE[0].value,
            Study: peFilterData.studies[0].value,
            StudySites: '',
            Source: peFilterData.source[0].value,
            ParticipantStatus: peFilterData.statuses[1].value,
            isHighRiskOccupation: false,
            isComorbidities: false,
            isInitialVisitScheduled: false,
            AgeFrom: '0',
            AgeTo: '150',
            Ethnicity: peFilterData.ethnicity[0].value,
            Sex: '',
            pageNumber: '',
            pageSize: '',
            SelectedIds: '',
            DeselectedIds: '',
            isExport: '',
            Sortby: '',
            highPrioritySelected_YesIds: '',
            highPrioritySelected_NoIds: '',
            startPos: 0,
            endPos: 45000,
            perRecordCount: perRecordCount
        });
        component.set('v.filterList', RowItemList);
        helper.handleSearchHelper(component, event, helper);
        
    },
    handleChangeActive: function (component, event, helper) {
        //var spinner = component.find('recordsSpinner');
        //spinner.show();
        var selectedOptionValue = component.get('v.filterList[0].Status');
        var studyId = component.get('v.filterList[0].Study');
        // alert(component.get("v.peFilterData.statuses"));
        component.set('v.filterList[0].Status', selectedOptionValue);
        
        var params = {
            activePE: selectedOptionValue,
            studyId: studyId
        };
        if(component.get('v.isSSListUpdated')==true){
            params = {
                activePE: selectedOptionValue,
                studyId: studyId,
                isPromoteToSH: component.get('v.PromoteToSH')==false?true:false,
                isInitVisitReqd: component.get('v.isInitVisitReqd')==true?true:false
            }
        }  
        communityService.executeAction(
            component,
            'getParticipantStatus',
            params,
            function (returnValue) {
                component.set('v.peFilterData.statuses', returnValue);
                if (
                    selectedOptionValue == 'Inactive' &&
                    component.get('v.filterList[0].ParticipantStatus') != 'null' &&
                    component.get('v.filterList[0].ParticipantStatus') != 'Received'
                ) {
                    component.set(
                        'v.filterList[0].ParticipantStatus',
                        component.get('v.filterList[0].ParticipantStatus')
                    );
                }
                if (
                    selectedOptionValue == 'Inactive' &&
                    component
                    .get('v.actStatus')
                    .includes(component.get('v.filterList[0].ParticipantStatus'))
                ) {
                    component.set('v.filterList[0].ParticipantStatus', 'null');
                }
                //  alert(component.get('v.filterList[0].ParticipantStatus'));
                if (selectedOptionValue == 'Active' && !component.get('v.isFromDoinit')) {
                    component.set('v.filterList[0].ParticipantStatus', returnValue[1].value);
                }
                if (selectedOptionValue == 'Active') {
                    var arr = [];
                    for (var i = 0; i < returnValue.length; i++) {
                        arr.push(returnValue[i].value);
                    }
                    component.set('v.actStatus', arr);
                    component.set('v.psIfActive', returnValue);
                }
                if (
                    selectedOptionValue == 'Active' &&
                    !component
                    .get('v.actStatus')
                    .includes(component.get('v.filterList[0].ParticipantStatus'))
                ) {
                    component.set('v.filterList[0].ParticipantStatus', 'null');
                }
                //spinner.hide();
            }
        );
    },
    reset: function (component, event, helper) {
        component.set('v.isFromDoinit', false);
        component.set("v.isActionSelected",false);
        component.set("v.statusChange",false);
        component.set("v.isCheckboxhidden",false); 
        component.set('v.ActionSelected','null');
        component.set("v.turnON",true);
        var menuItem = component.find('menuItem');
        $A.util.removeClass(menuItem, 'slds-is-open');
        helper.doinitHelper(component, event, helper);
    },
    handleChangeSex: function (component, event, helper) {
        //var spinner = component.find('recordsSpinner');
        //spinner.show();
        var selectedOptionValue = component.get('v.filterList[0].Sex');
        component.set('v.filterList[0].Sex', selectedOptionValue);
        //spinner.hide();
    },
    handleChangePartStatus: function (component, event, helper) {
        //var spinner = component.find('recordsSpinner');
        //spinner.show();
        var selectedOptionValue = component.get('v.filterList[0].ParticipantStatus');
        //  alert(selectedOptionValue);
        component.set('v.filterList[0].ParticipantStatus', selectedOptionValue);
        //spinner.hide();
    },
    handleChangeSource: function (component, event, helper) {
        //var spinner = component.find('recordsSpinner');
        //spinner.show();
        var selectedOptionValue = component.get('v.filterList[0].Source');
        component.set('v.filterList[0].Source', selectedOptionValue);
        //spinner.hide();
    },
    handleChangeSites: function (component, event, helper) {
        //var spinner = component.find('recordsSpinner');
        //spinner.show();
        var selectedOptionValue = component.get('v.filterList[0].StudySites');
        //alert(component.get("v.filterList[0].StudySites"));
        component.set('v.filterList[0].StudySites', selectedOptionValue);
        //spinner.hide();
    },
    handleChangeEthnicity: function (component, event, helper) {
        //var spinner = component.find('recordsSpinner');
        //spinner.show();
        var selectedOptionValue = component.get('v.filterList[0].Ethnicity');
        component.set('v.filterList[0].Ethnicity', selectedOptionValue);
        //spinner.hide();
    },
    handleCheckboxHRO: function (component, event, helper) {
        //var spinner = component.find('recordsSpinner');
        //spinner.show();
        var selectedOptionValue = event.getSource().get('v.checked');
        var RowItemList = component.get('v.filterList');
        RowItemList[0].isHighRiskOccupation = selectedOptionValue;
        component.set('v.filterList', RowItemList);
        //spinner.hide();
    },
    handleCheckboxCBD: function (component, event, helper) {
        //var spinner = component.find('recordsSpinner');
        //spinner.show();
        var selectedOptionValue = event.getSource().get('v.checked');
        var RowItemList = component.get('v.filterList');
        RowItemList[0].isComorbidities = selectedOptionValue;
        component.set('v.filterList', RowItemList);
        //spinner.hide();
    },
    handleCheckboxIVS: function (component, event, helper) {
        //var spinner = component.find('recordsSpinner');
        //spinner.show();
        var selectedOptionValue = event.getSource().get('v.checked');
        var RowItemList = component.get('v.filterList');
        RowItemList[0].isInitialVisitScheduled = selectedOptionValue;
        component.set('v.filterList', RowItemList);
        //spinner.hide();
    },
    handleAgeFrom: function (component, event, helper) {
        var selectedOptionValue = event.getParam('value');
        var RowItemList = component.get('v.filterList');
        RowItemList[0].AgeFrom = selectedOptionValue;
        component.set('v.filterList', RowItemList);
    },
    handleAgeTo: function (component, event, helper) {
        var selectedOptionValue = event.getParam('value');
        var RowItemList = component.get('v.filterList');
        RowItemList[0].AgeTo = selectedOptionValue;
        component.set('v.filterList', RowItemList);
    },
    handleSearch: function (component, event, helper) {
        component.set("v.isActionSelected",false);
        component.set("v.statusChange",false);
        component.set("v.isCheckboxhidden",false); 
        component.set('v.ActionSelected','null');
        component.set("v.turnON",false);
        var menuItem = component.find('menuItem');
        $A.util.removeClass(menuItem, 'slds-is-open');
        helper.handleSearchHelper(component, event, helper);
    },
    handleTable: function (component, event, helper) {
        component.find('Spinnerpopup').show();
        var RowItemList = component.get('v.oldfilterList');
        RowItemList = [];
        //var pageNumber = 1;
        var pageNumber =component.get('v.PageNumber');
        var pageSize = component.find('pageSize').get('v.value');
        
        RowItemList.push({
            Status: component.get('v.oStatus'),
            Study: component.get('v.oStudy'),
            StudySites: component.get('v.oStudySites'),
            Source: component.get('v.oSource'),
            ParticipantStatus: component.get('v.oParticipantStatus'),
            isHighRiskOccupation: component.get('v.oisHighRiskOccupation'),
            isComorbidities: component.get('v.oisComorbidities'),
            isInitialVisitScheduled: component.get('v.oisInitialVisitScheduled'),
            AgeFrom: component.get('v.oAgeFrom'),
            AgeTo: component.get('v.oAgeTo'),
            Ethnicity: component.get('v.oEthnicity'),
            Sex: component.get('v.oSex'),
            pageNumber: pageNumber,
            pageSize: pageSize,
            SelectedIds: component.get('v.SelectedIds'),
            DeselectedIds: component.get('v.DeSelectedIds'),
            isExport: '',
            Sortby: component.find('sortby').get('v.value'),
            highPrioritySelected_YesIds: component.get('v.lstPR_yes'),
            highPrioritySelected_NoIds: component.get('v.lstPR_no')
        });
        
        /**  RowItemList[0].pageNumber = pageNumber;
        RowItemList[0].pageSize = pageSize; 
        RowItemList[0].SelectedIds = component.get('v.SelectedIds');
        RowItemList[0].DeselectedIds = component.get('v.DeSelectedIds');
        RowItemList[0].Sortby = component.find("sortby").get("v.value");
        RowItemList[0].highPrioritySelected_YesIds = component.get('v.lstPR_yes');
        RowItemList[0].highPrioritySelected_NoIds = component.get('v.lstPR_no'); **/
        component.set('v.oldfilterList', RowItemList);
        
        var filterValue = component.get('v.oldfilterList');
        
        /** alert('status-->'+filterValue[0].Status);
        alert('study-->'+filterValue[0].Study);
        alert('site--->'+filterValue[0].StudySites);
        alert('source-->'+filterValue[0].Source);
        alert('pstatus-->'+filterValue[0].ParticipantStatus);
        alert('AgeFrom-->'+filterValue[0].AgeFrom);
        alert('AgeTo-->'+filterValue[0].AgeTo);
        alert('Ethnicity-->'+filterValue[0].Ethnicity);
        alert('Sex-->'+filterValue[0].Sex);
        alert('isHighRiskOccupation-->'+filterValue[0].isHighRiskOccupation);
        alert('isComorbidities-->'+filterValue[0].isComorbidities);
        alert('isInitialVisitScheduled-->'+filterValue[0].isInitialVisitScheduled); **/
        
        //var bol = helper.validateAge(component, event, helper);
        filterValue = JSON.stringify(filterValue);
        var bulkaction = component.get('v.ActionSelected');
        console.table(filterValue);
        var statusChangeto = component.get('v.StatusChangeto');
        if (!communityService.isInitialized()) return;
        communityService.executeAction(
            component,
            'fetchData',
            {
                filterJSON: filterValue,
                bulkAction: bulkaction,
                statusChangeto: statusChangeto
            },
            function (returnValue) {
                console.log('@@@@@@@ReturnValue ' + returnValue);
                
                var result = returnValue;
                
                component.set('v.PaginationList', result.FilterImpacts);
                component.set('v.PageNumber', result.pageNumber);
                component.set('v.TotalRecords', result.totalRecords);
                component.set('v.filterList[0].perRecordCount', result.totalRecords);
                component.set('v.RecordStart', result.recordStart);
                component.set('v.RecordEnd', result.recordEnd);
                component.set('v.TotalPages', Math.ceil(result.totalRecords / pageSize));
                component.set('v.IsPromoteToSHLimit', result.IsPromoteToSHLimit);
                if (component.get('v.RecordEnd') == 0) {
                    component.set('v.RecordStart', 0);
                }
                if (result.IsPromoteToSH == false) {
                    component.set('v.PromoteToSH', true);
                } else {
                    component.set('v.PromoteToSH', false);
                }
                component.set('v.enablePP', result.enablePP);
                component.set('v.enableSH', result.enableSH);
                var PaginationList = component.get('v.PaginationList');
                var SelectedLength = 0;
                var NotLockedLen = 0;
                var SelectionLock = 0;
                for (var i = 0; i < PaginationList.length; i++) {
                    if (PaginationList[i].isCheckedlatest == true) {
                        SelectedLength++;
                    }
                    if (PaginationList[i].selectionlock == false) {
                        NotLockedLen++;
                    } else {
                        SelectionLock++;
                    }
                }
                if (NotLockedLen == SelectedLength && SelectionLock != PaginationList.length) {
                    component.set('v.SelectAll', true);
                } else {
                    component.set('v.SelectAll', false);
                }
                component.find('Spinnerpopup').hide();
            }
        );
        //component.find('recordsSpinner').hide();
    },
    checkboxSelected: function (component, event, helper) {
        var totalCount = component.get('v.count');
        //alert(totalCount);
        var selection = '';
        if (event.getSource().get('v.value') == true) {
            selection = 1;
        } else {
            selection = 0;
        }
        //alert(component.get('v.IsPromoteToSHLimit'));
        if (totalCount + selection > component.get('v.IsPromoteToSHLimit')) {
            var index = event.getSource().get('v.name');
            //alert('index'+index);
            var updatedPaginationList = [];
            var PaginationList = component.get('v.PaginationList');
            //alert('l'+PaginationList.length);
            for (var i = 0; i < PaginationList.length; i++) {
                if (index == i) {
                    PaginationList[i].isCheckedlatest = false;
                }
                updatedPaginationList.push(PaginationList[i]);
            }
            component.set('v.PaginationList', updatedPaginationList);
            helper.showToastLimit(component, event, helper);
        } else {
            var selectedRec = event.getSource().get('v.value');
            if (selectedRec == true) {
                component.get('v.SelectedIds').push(event.getSource().get('v.text'));
                var count = component.get('v.count');
                count++;
                component.set('v.count', count);
                var index = event.getSource().get('v.name');
                var updatedPaginationList = [];
                var PaginationList = component.get('v.PaginationList');
                
                for (var i = 0; i < PaginationList.length; i++) {
                    if (index == i) {
                        PaginationList[i].isCheckedlatest = true;
                    }
                    updatedPaginationList.push(PaginationList[i]);
                }
                component.set('v.PaginationList', updatedPaginationList);
            } else {
                var count = component.get('v.count');
                count--;
                component.set('v.count', count);
                var selectids = component.get('v.SelectedIds');
                var index = selectids.indexOf(event.getSource().get('v.text'));
                if (index != -1) {
                    selectids.splice(index, 1);
                    component.set('v.SelectedIds', selectids);
                }
                var sids = component.get('v.SelectedIds');
                component.set('v.SelectAll', false);
                var index = event.getSource().get('v.name');
                var updatedPaginationList = [];
                var PaginationList = component.get('v.PaginationList');
                for (var i = 0; i < PaginationList.length; i++) {
                    if (index == i) {
                        PaginationList[i].isCheckedlatest = false;
                    }
                    updatedPaginationList.push(PaginationList[i]);
                }
                component.set('v.PaginationList', updatedPaginationList);
            }
        }
        if (component.get('v.count') > 0 ) {
            component.set('v.enablePromoteToSH', false);
            component.set("v.turnON",false);
        } else {
            component.set('v.enablePromoteToSH', true);
            component.set("v.turnON",true);
        }
    },
    selectAllCheckbox: function (component, event, helper) {
        var totalCount = component.get('v.count');
        var selectAllTrue = event.getSource().get('v.value');
        var PaginationLists = component.get('v.PaginationList');
        var selection = 0;
        for (var i = 0; i < PaginationLists.length; i++) {
            if (selectAllTrue) {
                if (
                    PaginationLists[i].isCheckedlatest == false &&
                    PaginationLists[i].selectionlock == false
                ) {
                    selection++;
                }
            }
        }
        if (totalCount + selection > component.get('v.IsPromoteToSHLimit')) {
            helper.showToastLimit(component, event, helper);
            component.set('v.SelectAll', false);
        } else {
            var selectedRecval = event.getSource().get('v.value');
            //alert(selectedRecval);
            var updatedPaginationList = [];
            var PaginationList = component.get('v.PaginationList');
            
            var count = component.get('v.count');
            var selectids = component.get('v.SelectedIds');
            var getvalue = '';
            for (var i = 0; i < PaginationList.length; i++) {
                if (selectedRecval == true) {
                    if (
                        PaginationList[i].isCheckedlatest == false &&
                        PaginationList[i].selectionlock == false
                    ) {
                        PaginationList[i].isCheckedlatest = true;
                        component.get('v.SelectedIds').push(PaginationList[i].pe.Id);
                        count++;
                    }
                    component.set('v.count', count);
                } else {
                    if (
                        PaginationList[i].isCheckedlatest == true &&
                        PaginationList[i].selectionlock == false
                    ) {
                        PaginationList[i].isCheckedlatest = false;
                        
                        getvalue = selectids.indexOf(PaginationList[i].pe.Id);
                        if (getvalue != -1) {
                            selectids.splice(getvalue, 1);
                            component.set('v.SelectedIds', selectids);
                        }
                        count--;
                        component.set('v.count', count);
                    }
                }
                updatedPaginationList.push(PaginationList[i]);
            }
            component.set('v.PaginationList', updatedPaginationList);
        }
        if (component.get('v.count') > 0 ) {
            component.set('v.enablePromoteToSH', false);
            component.set("v.turnON",false);
        } else {
            component.set('v.enablePromoteToSH', true);
            component.set("v.turnON",true);
        }
    },
    onClickCardView: function (component, event, helper) {
        communityService.navigateToPage('my-referrals');
    },
    handleNext: function (component, event, helper) {
        component.find('Spinnerpopup').show();
        //component.set('v.showspinner','true');
        
        var RowItemList = component.get('v.oldfilterList');
        RowItemList = [];
        var pageNumber = component.get('v.PageNumber');
        var pageSize = component.find('pageSize').get('v.value');
        
        pageNumber++;
        RowItemList.push({
            Status: component.get('v.oStatus'),
            Study: component.get('v.oStudy'),
            StudySites: component.get('v.oStudySites'),
            Source: component.get('v.oSource'),
            ParticipantStatus: component.get('v.oParticipantStatus'),
            isHighRiskOccupation: component.get('v.oisHighRiskOccupation'),
            isComorbidities: component.get('v.oisComorbidities'),
            isInitialVisitScheduled: component.get('v.oisInitialVisitScheduled'),
            AgeFrom: component.get('v.oAgeFrom'),
            AgeTo: component.get('v.oAgeTo'),
            Ethnicity: component.get('v.oEthnicity'),
            Sex: component.get('v.oSex'),
            pageNumber: pageNumber,
            pageSize: pageSize,
            SelectedIds: component.get('v.SelectedIds'),
            DeselectedIds: component.get('v.DeSelectedIds'),
            isExport: '',
            Sortby: component.find('sortby').get('v.value'),
            highPrioritySelected_YesIds: component.get('v.lstPR_yes'),
            highPrioritySelected_NoIds: component.get('v.lstPR_no')
        });
        
        /** RowItemList[0].pageNumber = pageNumber;
        RowItemList[0].pageSize = pageSize; 
        RowItemList[0].SelectedIds = component.get('v.SelectedIds');
        RowItemList[0].DeselectedIds = component.get('v.DeSelectedIds');
        RowItemList[0].Sortby = component.find("sortby").get("v.value");
        RowItemList[0].highPrioritySelected_YesIds = component.get('v.lstPR_yes');
        RowItemList[0].highPrioritySelected_NoIds = component.get('v.lstPR_no'); **/
        
        component.set('v.oldfilterList', RowItemList);
        
        var filterValue = component.get('v.oldfilterList');
        var bulkaction = component.get('v.ActionSelected')
        var bol = helper.validateAge(component, event, helper);
        filterValue = JSON.stringify(filterValue);
        
        console.log('Selected Filter Next ' + filterValue);
        var statusChangeto = component.get('v.StatusChangeto');
        if (!communityService.isInitialized()) return;
        communityService.executeAction(
            component,
            'fetchData',
            {
                filterJSON: filterValue,
                bulkAction: bulkaction,
                statusChangeto: statusChangeto
            },
            function (returnValue) {
                console.log('@@@@@@@ReturnValue ' + returnValue);
                //var result = JSON.parse(returnValue);
                var result = returnValue;
                //var result = JSON.stringify(returnValue);
                component.set('v.PaginationList', result.FilterImpacts);
                component.set('v.PageNumber', result.pageNumber);
                component.set('v.TotalRecords', result.totalRecords);
                component.set('v.filterList[0].perRecordCount', result.totalRecords);
                component.set('v.RecordStart', result.recordStart);
                component.set('v.RecordEnd', result.recordEnd);
                component.set('v.TotalPages', Math.ceil(result.totalRecords / pageSize));
                component.set('v.IsPromoteToSHLimit', result.IsPromoteToSHLimit);
                if (component.get('v.RecordEnd') == 0) {
                    component.set('v.RecordStart', 0);
                }
                if (result.IsPromoteToSH == false) {
                    component.set('v.PromoteToSH', true);
                } else {
                    component.set('v.PromoteToSH', false);
                }
                
                var PaginationList = component.get('v.PaginationList');
                var SelectedLength = 0;
                var NotLockedLen = 0;
                var SelectionLock = 0;
                for (var i = 0; i < PaginationList.length; i++) {
                    if (PaginationList[i].isCheckedlatest == true) {
                        SelectedLength++;
                    }
                    if (PaginationList[i].selectionlock == false) {
                        NotLockedLen++;
                    } else {
                        SelectionLock++;
                    }
                }
                if (NotLockedLen == SelectedLength && SelectionLock != PaginationList.length) {
                    component.set('v.SelectAll', true);
                } else {
                    component.set('v.SelectAll', false);
                }
                component.find('Spinnerpopup').hide();
            }
        );
    },
    
    handlePrev: function (component, event, helper) {
        component.find('Spinnerpopup').show();
        var RowItemList = component.get('v.oldfilterList');
        RowItemList = [];
        var pageNumber = component.get('v.PageNumber');
        var pageSize = component.find('pageSize').get('v.value');
        
        pageNumber--;
        
        RowItemList.push({
            Status: component.get('v.oStatus'),
            Study: component.get('v.oStudy'),
            StudySites: component.get('v.oStudySites'),
            Source: component.get('v.oSource'),
            ParticipantStatus: component.get('v.oParticipantStatus'),
            isHighRiskOccupation: component.get('v.oisHighRiskOccupation'),
            isComorbidities: component.get('v.oisComorbidities'),
            isInitialVisitScheduled: component.get('v.oisInitialVisitScheduled'),
            AgeFrom: component.get('v.oAgeFrom'),
            AgeTo: component.get('v.oAgeTo'),
            Ethnicity: component.get('v.oEthnicity'),
            Sex: component.get('v.oSex'),
            pageNumber: pageNumber,
            pageSize: pageSize,
            SelectedIds: component.get('v.SelectedIds'),
            DeselectedIds: component.get('v.DeSelectedIds'),
            isExport: '',
            Sortby: component.find('sortby').get('v.value'),
            highPrioritySelected_YesIds: component.get('v.lstPR_yes'),
            highPrioritySelected_NoIds: component.get('v.lstPR_no')
        });
        
        /**  RowItemList[0].pageNumber = pageNumber;
     RowItemList[0].pageSize = pageSize; 
     RowItemList[0].SelectedIds = component.get('v.SelectedIds');
     RowItemList[0].DeselectedIds = component.get('v.DeSelectedIds');
     RowItemList[0].Sortby = component.find("sortby").get("v.value");
     RowItemList[0].highPrioritySelected_YesIds = component.get('v.lstPR_yes');
     RowItemList[0].highPrioritySelected_NoIds = component.get('v.lstPR_no'); **/
        
        component.set('v.oldfilterList', RowItemList);
        
        var filterValue = component.get('v.oldfilterList');
        var bulkaction = component.get('v.ActionSelected');
        var bol = helper.validateAge(component, event, helper);
        filterValue = JSON.stringify(filterValue);
        
        console.log('Sellected Filter ' + filterValue);
        var statusChangeto = component.get('v.StatusChangeto');
        if (!communityService.isInitialized()) return;
        communityService.executeAction(
            component,
            'fetchData',
            {
                filterJSON: filterValue,
                bulkAction: bulkaction,
                statusChangeto: statusChangeto
            },
            function (returnValue) {
                console.log('@@@@@@@ReturnValue ' + returnValue);
                //var result = JSON.parse(returnValue);
                var result = returnValue;
                //var result = JSON.stringify(returnValue);
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
                if (component.get('v.RecordEnd') == 0) {
                    component.set('v.RecordStart', 0);
                }
                var PaginationList = component.get('v.PaginationList');
                var SelectedLength = 0;
                var NotLockedLen = 0;
                var SelectionLock = 0;
                for (var i = 0; i < PaginationList.length; i++) {
                    if (PaginationList[i].isCheckedlatest == true) {
                        SelectedLength++;
                    }
                    if (PaginationList[i].selectionlock == false) {
                        NotLockedLen++;
                    } else {
                        SelectionLock++;
                    }
                }
                if (NotLockedLen == SelectedLength && SelectionLock != PaginationList.length) {
                    component.set('v.SelectAll', true);
                } else {
                    component.set('v.SelectAll', false);
                }
                component.find('Spinnerpopup').hide();
            }
        );
    },
    StudyAction: function (component, event, helper) {
        component.set('v.flagSet', true);
    },
    doStudyChanged: function (component, event, helper) {
        var studyId = component.get('v.filterList[0].Study');
        component.set('v.filterList[0].Study', studyId);
        var selectedOptionValue = component.get('v.filterList[0].Status');
        if (studyId != '') {
            communityService.executeAction(
                component,
                'getSSList',
                {
                    studyId: studyId,
                    activePE: selectedOptionValue
                },
                function (returnValue) {
                    component.set('v.peFilterData.studySites', returnValue.StudySites);
                    if (returnValue.isPromoteToSH == false) {
                        component.set('v.PromoteToSH', true);
                    } else {
                        component.set('v.PromoteToSH', false);
                    }
                    if (returnValue.isInitVisitReqd == false) {
                        component.set('v.isInitVisitReqd', true);
                    } else {
                        component.set('v.isInitVisitReqd', false);
                    }

                    component.set('v.isSSListUpdated',true);
                    component.set('v.peFilterData.statuses',returnValue.statusFilterData);
                }
            );
        }
    },
    
    showEditParticipantInformation: function (component, event, helper) {
        var PeIndex = event.getSource().get('v.name');
        console.log('>>PeIndex>' + PeIndex);
        var rootComponent = $A.get('e.c:ListViewParticipantFilter');
        var pe = component.get('v.PaginationList')[PeIndex];
        console.log('>>peee>' + JSON.stringify(pe));
        // alert('>>particpant>>'+component.get('v.PaginationList')[PeIndex].Participant_Contact__c )
        console.log(
            '>>contact pagination>>>' +
            component.get('v.PaginationList')[PeIndex].pe.Participant_Contact__c
        );
        var actions = component.get('v.actions');
        var isInvited = component.get('v.isInvited');
        var anchor = event.currentTarget.value;
        var contactId;
        
        if (component.get('v.PaginationList')[PeIndex].pe.Participant_Contact__c != null) {
            contactId = component.get('v.PaginationList')[PeIndex].pe.Participant_Contact__c;
        } else {
            contactId = null;
        }
        console.log('>>contactId>>' + contactId);
        if (contactId != null) {
            console.log('>>contact not null>');
            communityService.executeAction(
                component,
                'getParticipantData',
                {
                    peId: component.get('v.PaginationList')[PeIndex].pe.Id,
                    contactid: contactId
                },
                function (returnValue) {
                    var getParticpantDetal = JSON.parse(returnValue);
                    var PE = getParticpantDetal.PE;
                    var isInvited = getParticpantDetal.isInvited;
                    component
                    .find('OpenPatientInfoAction')
                    .execute(PE, actions, rootComponent, isInvited, function (enrollment) {
                        console.log('>>enrollment>>' + JSON.stringify(enrollment));
                        component.set('v.pe', enrollment);
                        component.set('v.isInvited', component.get('v.InviteStatus'));
                    });
                    
                    // component.set('v.InviteStatus', JSON.parse(returnValue));
                }
            );
            component.refreshTable();
        }
        //  alert(JSON.parse(returnValue));
    },
    handlePromoteSH: function (component, event, helper) {
        var count = component.get('v.count');
        
        if (count > 0 && count <= component.get('v.IsPromoteToSHLimit')) {
            component.find('Spinnerpopup').show();
            var sid = [];
            sid = component.get('v.SelectedIds');
            console.log('sid--->'+sid);
            communityService.executeAction(
                component,
                'updateParticipantData',
                {
                    peIdList: sid,
                    yesHighPriorityList: component.get('v.lstPR_yes'),
                    noHighPriorityList: component.get('v.lstPR_no')
                },
                function (returnValue) {
                    helper.showToast();
                    component.find('Spinnerpopup').hide();
                }
            );
            helper.handleSearchHelper(component, event, helper);
            component.set('v.lstPR_no', '');
            component.set('v.lstPR_yes', '');
            component.set('v.SelectedIds', '');
            component.set('v.DeSelectedIds', '');
            component.set('v.count', 0);
            component.set('v.enablePromoteToSH', true);
            component.set("v.turnON",true);
        } else {
            helper.showToastLimit(component, event, helper);
        }
    },
    handleExport: function (component, event, helper) {
        if (communityService.isMobileSDK()) {
            communityService.showWarningToast(
                'Warning!',
                $A.get('$Label.c.Pdf_Not_Available'),
                100
            );
            return;
        }
        //var spinner = component.find('recordsSpinner');
        //spinner.show();
        component.set('v.startPos', 0);
        component.set('v.endPos', 45000);
        component.set('v.counterLimit', 45000);
        helper.getAllFilteredList(component, event, helper);
        //spinner.hide();
    },
    handlePriorityReferral: function (component, event, helper) {
        if (event.getSource().get('v.value') == 'Yes') {
            var ids_PRno = component.get('v.lstPR_no');
            var index = ids_PRno.indexOf(event.getSource().get('v.name'));
            if (index != -1) {
                ids_PRno.splice(index, 1);
                component.set('v.lstPR_no', ids_PRno);
                component.get('v.lstPR_yes').push(event.getSource().get('v.name'));
            } else {
                component.get('v.lstPR_yes').push(event.getSource().get('v.name'));
            }
            //alert(component.get('v.lstPR_yes').length);
        } else {
            var ids_PRyes = component.get('v.lstPR_yes');
            var index = ids_PRyes.indexOf(event.getSource().get('v.name'));
            if (index != -1) {
                ids_PRyes.splice(index, 1);
                component.set('v.lstPR_yes', ids_PRyes);
                component.get('v.lstPR_no').push(event.getSource().get('v.name'));
            } else {
                component.get('v.lstPR_no').push(event.getSource().get('v.name'));
            }
            //alert(component.get('v.lstPR_no').length);
        }
    },
    onSubmit: function(component, event, helper) {
        //if status changed, get reason and notes on modal
        if(component.get("v.statusChange")){
            component.set("v.isOpen", true);
            component.find('openStatusPopup').execute();
            component.find('Spinnerpopup').show();
            var sid = [];
            sid = component.get('v.SelectedIds');
            component.find('Spinnerpopup').hide();
        }else{
            var action =  component.get('v.ActionSelected');
            if(action == 'Send to Study Hub')
            {  
                //call handlePromoteSH
                component.handlePromoteSHMethod();
            }
            if(action == 'Invite to Patient Portal')
            {
                //call InvitetoPP
                //alert('InvitetoPP');
                component.handleInviteToPPMethod();
            }
        }
    },
    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.isOpen", false);
    },
    
    likenClose: function(component, event, helper) {
        // Display alert message on the click on the "Like and Close" button from Model Footer 
        // and set set the "isOpen" attribute to "False for close the model Box.
        //alert('thanks for like Us :)');
        component.set("v.isOpen", false);
    },
    itemclick : function(cmp, event, helper) {
        var val = event.currentTarget.getAttribute("data-value");
        cmp.set('v.value',val);
    },
    showSubMenu : function(cmp, event, helper) {
        var cmpTarget = cmp.find('sub-menu');
        $A.util.removeClass(cmpTarget, 'slds-hide');
    },
    hideSubMenu : function(cmp, event, helper) {
        var cmpTarget = cmp.find('sub-menu');
        $A.util.addClass(cmpTarget, 'slds-hide');
    },
    toggleVisibility : function(cmp, event, helper) {
        var menuItem = cmp.find('menuItem');
        if(cmp.get('v.enableSH') || cmp.get('v.enablePP') || (cmp.get('v.TotalRecords') >0)){
            $A.util.toggleClass(menuItem,'slds-is-open');
        }
    },
    hideOnBlur : function(component, event, helper){
        var myMenu = component.find('menuItem');
        if(myMenu){
            $A.util.removeClass(myMenu, 'slds-is-open');
        }
        var cmpTarget = component.find('sub-menu');
        if(cmpTarget){
            $A.util.addClass(cmpTarget, 'slds-hide');
        }
    },
    selectAction : function(component, event, helper) {
        
        var val = event.currentTarget.getAttribute("data-value");
        component.set('v.ActionSelected',val);
        if(val == 'Invite to Patient Portal')
        {
            component.set("v.isActionSelected",true);
            component.set("v.isCheckboxhidden",true);  
            component.set("v.turnON",true);  
             helper.handleSearchHelper(component, event, helper);
        }
       
        if(val == 'Send to Study Hub')
        {
            component.set("v.isActionSelected",true);
            if(!component.get('v.PromoteToSH')){
                component.set("v.isCheckboxhidden",true); 
            }
            component.set("v.turnON",true);
           helper.handleSearchHelper(component, event, helper);
        }
        
        if(val == 'Change Participant Status'){
            var status = component.get('v.oParticipantStatus');
            var ssId = component.get('v.oStudy');
            if(status == 'null'){
                communityService.showToast(
                    'error',
                    'error',
                    $A.get('$Label.c.ListView_Change_Status')
                );
            }
            else{
                communityService.executeAction(
                    component,
                    'getAvailableStatuses',
                    {
                        status : status,
                        StudyId : ssId
                    },
                    function (returnValue) {
                        console.log('returnvalue'+JSON.stringify(returnValue))
                        if(returnValue[1] != undefined || returnValue[1] != null){
                            component.set("v.isActionSelected",true);
                            component.set("v.statusChange",true); 
                            component.set('v.availableStatuses', returnValue);
                            //component.set('v.StatusChangeto',returnValue[1]);
                            helper.handleSearchHelper(component, event, helper);
                            
                            component.set("v.isCheckboxhidden",true);
                            component.set("v.turnON",true);
                        }else{
                            communityService.showToast(
                                'error',
                                'error',
                                $A.get('$Label.c.ListView_Status_Not_Available')
                            );
                            component.set('v.StatusChangeto','null');
                            helper.setDefault(component, event, helper);
                        }
                       
                        
                    }
                );
                  
            }
        }
    },
    noAction : function(component, event, helper) {
        helper.setDefault(component, event, helper);
    },
    
    inviteToPP : function(component,event,helper){
        var count = component.get('v.count');
        
        if (count > 0 && count <= component.get('v.IsPromoteToSHLimit')) {
            component.find('Spinnerpopup').show();
            var sid = [];
            sid = component.get('v.SelectedIds');
            console.log('InvitePP--sid--->'+sid);
            communityService.executeAction(
                component,
                'createUserForPatientProtal',
                {
                    peId: sid,
                    sendEmails: true
                },
                function (returnValue) {
                    helper.showToastforInvite(component, event, helper,count);
                    component.find('Spinnerpopup').hide();
                }
            );
            helper.handleSearchHelper(component, event, helper);
            component.set('v.lstPR_no', '');
            component.set('v.lstPR_yes', '');
            component.set('v.SelectedIds', '');
            component.set('v.DeSelectedIds', '');
            component.set('v.count', 0);
            component.set('v.enablePromoteToSH', true);
            component.set("v.turnON",true);
        }else {
            helper.showToastLimit(component, event, helper);
        }
    },
   doValueChangeStatus: function (component, event, helper) {
       //alert(component.get('v.statusSelected'));
       component.set('v.StatusChangeto',component.get('v.statusSelected'));
       component.set("v.isCheckboxhidden",true);
       component.set("v.turnON",true);
       helper.handleSearchHelper(component, event, helper);
    },
    
    changeStatusTo: function (component, event, helper) {
        helper.setDefault(component, event, helper);
        component.set('v.lstPR_no', '');
        component.set('v.lstPR_yes', '');
        component.set('v.SelectedIds', '');
        component.set('v.DeSelectedIds', '');
        component.set('v.count', 0);
        component.set('v.enablePromoteToSH', true);
    },

});