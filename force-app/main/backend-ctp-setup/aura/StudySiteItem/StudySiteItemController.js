/**
 * Created by Igor Malyuta on 19.09.2019.
 */

({
    doInit: function (component, event, helper) {
//        component.find('spinner').show();
        var options = [];
        options.push({'label':' ' + $A.get("$Label.c.ASSOCIATE_VISIT_PLAN_TO_PE_AND_STUDY_SITE"), 'value': 'option1'});
        options.push({'label':' ' + $A.get("$Label.c.ASSOCIATE_VISIT_PLAN_TO_STUDY_SITE_ONLY"), 'value': 'option2'});
        component.set('v.options',options);
        if (component.get('v.fromComponent') === 'Incentive' && !component.get('v.initilizedMap')) {
            let assignments = component.get('v.item.assignments');
            if (assignments) {
                let allSelectedIPs = component.get('v.selectedGlobalItems');
                for (var j = 0; j < assignments.length; j++) {
                    if (assignments[j] && assignments[j].state) {
                        if (!component.get('v.selectedItem')) {
                            component.set('v.selectedItem', assignments[j].value);
                        }
                        if (!allSelectedIPs[assignments[j].value]) {
                            allSelectedIPs[assignments[j].value] = new Set();
                        }
                        allSelectedIPs[assignments[j].value].add(component.get('v.item').ss.Id);
                    }
                }
                component.set('v.selectedGlobalItems', allSelectedIPs);
            }
            component.set('v.initilizedMap', true);
        }
//        component.find('spinner').hide();
    },

    viewStudySite: function (component, event, helper) {
        var ssId = event.currentTarget.dataset.ssid;
        var pageRef = {
            type: 'standard__recordPage',
            attributes: {
                actionName: 'view',
                objectApiName: 'Study_Site__c',
                recordId: ssId
            }
        };

        component.get('v.parent').find('navLink').navigate(pageRef);
    },

    saveModal: function (component, event, helper) {
        var cmpTarget = component.find('PopupModal');
        $A.util.removeClass(cmpTarget,'slds-backdrop--open');
        let isIncetive = component.get('v.fromComponent') === 'Incentive';
        component.set('v.isModalOpen',false);
        var item = component.get('v.item');
        var c = component.find("currentItemOptions");
        var item = component.get('v.item');
        var visitPlan = event.getSource().get("v.name");
        var checked = event.getSource().get("v.value");
        
        component.set('v.item',item);
        var asgCount = 0;
        var assignments = item.assignments;
        let parent = component.get('v.parent');
        
        for (var j = 0; j < assignments.length; j++) {
            if (isIncetive) {
                let selectedItem = component.get('v.selectedItem');
                if (selectedItem && selectedItem !== assignments[j].value && assignments[j].state) {
                    assignments[j].state = false;
                    communityService.showWarningToast(
                        'Warning!',
                        $A.get('$Label.c.PG_Ref_L_One_Incentive_Plan'),
                        5000
                    );
                } else if (
                    selectedItem &&
                    selectedItem === assignments[j].value &&
                    !assignments[j].state
                ) {
                    component.set('v.selectedItem', '');
                    
                    var allSelectedIPs = component.get('v.selectedGlobalItems');
                    allSelectedIPs[assignments[j].value].delete(component.get('v.item').ss.Id);
                    component.set('v.selectedGlobalItems', allSelectedIPs);
                } else if (!selectedItem && assignments[j].state) {
                    component.set('v.selectedItem', assignments[j].value);
                    
                    var allSelectedIPs = component.get('v.selectedGlobalItems');
                    allSelectedIPs[assignments[j].value].add(component.get('v.item').ss.Id);
                    component.set('v.selectedGlobalItems', allSelectedIPs);
                }
            }
            
            if (assignments[j].state) asgCount++;
        }
        item.emptyAssignments = asgCount === 0;
        component.set('v.item', item);
        component.set('v.enableOKButton',false);
        if(component.get('v.optionselected')=='option1'){
            let studySiteVisitPlan = component.get('v.studySiteVisitPlan');
            let ssId = item.ss.Id;
            if(studySiteVisitPlan === undefined){
                studySiteVisitPlan = {};
                studySiteVisitPlan[item.ss.Id]=component.get('v.selectedVisitPlan');
            }else{
                studySiteVisitPlan[item.ss.Id]=component.get('v.selectedVisitPlan');                      
            }
            component.set('v.studySiteVisitPlan',studySiteVisitPlan);  
        }
        if (parent && parent.doSave) {
            parent.doSave();
        }
    },

    cancelModal: function (component, event, helper) {
        var cmpTarget = component.find('PopupModal');
        $A.util.removeClass(cmpTarget,'slds-backdrop--open');
        let isIncetive = component.get('v.fromComponent') === 'Incentive';
		component.set('v.isModalOpen',false);
        var item = component.get('v.item');
        //var asgCount = 0;
        var assignments = item.assignments;
        let parent = component.get('v.parent');
        var visitPlan = event.getSource().get("v.name");
        var checked = event.getSource().get("v.value");
        let selectedVisitPlan = component.get('v.selectedVisitPlan'); 
        for (var j = 0; j < item.assignments.length; j++) {
            if(item.assignments[j].state == true && 
               item.assignments[j].value == selectedVisitPlan){
                item.assignments[j].state = false;
            }
        }
        component.set('v.selectedVisitPlan',undefined);
        component.set('v.optionselected',undefined);
        component.set('v.item', item);
        component.set('v.enableOKButton',false);        
    },
    
    selectButton: function (component, event, helper) {
        component.set('v.enableOKButton',true);
        var option = event.getParam("value");
        component.set('v.optionselected',option);
    },
    sscCheckboxStateChange: function (component, event, helper) {
		
        let isIncetive = component.get('v.fromComponent') === 'Incentive';
		var c = component.find("currentItemInputCheckbox");
        var company = component.find("currentItemInputCheckbox");
		company = (company!=undefined && Array.isArray(company)) ? company[0].get("v.value") : company.get("v.value");
		var c = (c!=undefined && Array.isArray(c)) ? c[0].get("v.name") : c.get("v.name");
        var item = component.get('v.item');
        var visitPlan = event.getSource().get("v.name");
        var checked = event.getSource().get("v.value");
        component.set('v.selectedVisitPlan',visitPlan);
        var asgCount = 0;
        var assignments = item.assignments;
        let parent = component.get('v.parent');
        if(component.get('v.fromComponent') === 'StudySiteVisit'  && item.emptyAssignments == true && checked == true){
            component.find('spinner').show();
            communityService.executeAction(
                component,
                'totalPEs',
                {
                    ssId: item.ss.Id,
                    ctpId:item.ss.Clinical_Trial_Profile__c
                },
                function (initData) {
                    if(initData.isProgram === true){
                        var options = [];
                        options.push({'label':' ' + $A.get("$Label.c.ASSOCIATE_EVENT_PLAN_TO_PE_AND_STUDY_SITE"), 'value': 'option1'});
                        options.push({'label':' ' + $A.get("$Label.c.ASSOCIATE_EVENT_PLAN_TO_STUDY_SITE_ONLY"), 'value': 'option2'});
                        component.set('v.options',options);
                        component.set('v.popupMessage',$A.get("$Label.c.TOTAL_PE_WITHOUT_EP").replace('##PEs',initData.count));
                    }else{
                        component.set('v.popupMessage',$A.get("$Label.c.TOTAL_PE_WITHOUT_VP").replace('##PEs',initData.count));
                        var options = [];
                        options.push({'label':' ' + $A.get("$Label.c.ASSOCIATE_VISIT_PLAN_TO_PE_AND_STUDY_SITE"), 'value': 'option1'});
                        options.push({'label':' ' + $A.get("$Label.c.ASSOCIATE_VISIT_PLAN_TO_STUDY_SITE_ONLY"), 'value': 'option2'});
                        component.set('v.options',options);
                    }
                    //component.set('v.totalPEs',initData);
                    if(initData === undefined || initData.count === undefined || initData.count<1){
                        component.find('spinner').hide();
                        for (var j = 0; j < assignments.length; j++) {                
                            if (assignments[j].state) asgCount++;
                        }
                        item.emptyAssignments = asgCount === 0;
                        component.set('v.item', item);
                        
                        if (parent && parent.doSave) {
                            parent.doSave();
                        }
                    }else{
                        component.set('v.item', item);
                        component.find('spinner').hide();
                        component.set('v.isModalOpen',true);
                        var cmpTarget = component.find('PopupModal');
                        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
                        
                    }
                }
            );
        }else if(component.get('v.fromComponent') === 'StudySiteVisit'
                 && item.ss.Is_Patient_Visit_Batch_Running__c == true 
                 && checked == false && item.soleVisitPlan!=undefined 
                 && item.soleVisitPlan == visitPlan){
            communityService.executeAction(
                component,
                'getLatestBatchStatusForStudySite',
                {
                    ssIdWithoutChangetoVisitPlan: item.ss.Id
                },
                function (response) {
                    if(response==true){
                        let tochange = false;
                        for (var j = 0; j < item.assignments.length; j++) {
                            if(item.assignments[j].state == false && 
                               item.assignments[j].value == visitPlan){
                                item.assignments[j].state = true;
                                tochange = true;
                                break;
                            }
                        }
                        if(tochange){
                            component.set('v.item', item);
                        }
                        component.set('v.isNotificationModalOpen',true);
                        var cmpTarget = component.find('NotificationPopupModal');
                        $A.util.addClass(cmpTarget, 'slds-fade-in-open'); 
                        
                    }else{
                        for (var j = 0; j < assignments.length; j++) {                
                            if (assignments[j].state) asgCount++;
                        }
                        item.emptyAssignments = asgCount === 0;
                        component.set('v.item', item);
                        
                        if (parent && parent.doSave) {
                            parent.doSave();
                        }           
                    }
                    
                }
            );
        } else{
            for (var j = 0; j < assignments.length; j++) {
                if (isIncetive) {
                    let selectedItem = component.get('v.selectedItem');
                    if (selectedItem && selectedItem !== assignments[j].value && assignments[j].state) {
                        assignments[j].state = false;
                        communityService.showWarningToast(
                            'Warning!',
                            $A.get('$Label.c.PG_Ref_L_One_Incentive_Plan'),
                            5000
                        );
                    } else if (
                        selectedItem &&
                        selectedItem === assignments[j].value &&
                        !assignments[j].state
                    ) {
                        component.set('v.selectedItem', '');
                        
                        var allSelectedIPs = component.get('v.selectedGlobalItems');
                        allSelectedIPs[assignments[j].value].delete(component.get('v.item').ss.Id);
                        component.set('v.selectedGlobalItems', allSelectedIPs);
                    } else if (!selectedItem && assignments[j].state) {
                        component.set('v.selectedItem', assignments[j].value);
                        
                        var allSelectedIPs = component.get('v.selectedGlobalItems');
                        allSelectedIPs[assignments[j].value].add(component.get('v.item').ss.Id);
                        component.set('v.selectedGlobalItems', allSelectedIPs);
                    }
                }
                
                if (assignments[j].state) asgCount++;
            }
            item.emptyAssignments = asgCount === 0;
            component.set('v.item', item);
            
            if (parent && parent.doSave) {
                parent.doSave();
            }
            
        }
    },

    exitNotificationModal: function (component, event, helper) {
        var cmpTarget = component.find('NotificationPopupModal');
        $A.util.removeClass(cmpTarget, 'slds-backdrop--open');  
        component.set('v.isNotificationModalOpen',false);
    },    
    
    sscRadioStateChange: function (component, event, helper) {
        var selected = event.getSource().get('v.label');
        var item = component.get('v.item');
        var asgCount = 0;
        var assignments = item.assignments;

        let parent = component.get('v.parent');
        console.log(selected);
        console.log(JSON.stringify(assignments));
        for (var j = 0; j < assignments.length; j++) {
            if (assignments[j].value !== selected) assignments[j].state = false;
            if (assignments[j].state) asgCount++;
        }
        item.emptyAssignments = asgCount === 0;
        component.set('v.item', item);

        if (parent && parent.doSave) {
            parent.doSave();
        }
    }
});
