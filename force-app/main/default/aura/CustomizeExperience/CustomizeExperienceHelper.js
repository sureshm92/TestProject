/**
 * Created by Yehor Dobrovolskyi
 */
({
    valueChange: function (component, event, helper) {
    component.set('v.bypass', false);
    let value = event.getSource().get('v.value');
    if (!value) {
        value = null;
    }
    communityService.executeAction(component, 'searchConditionOfInterest', {
        nameTA: value
    }, function (returnValue) {
        let coiList = component.get('v.conditionsOfInterestTemp');
        let coiWrappers = returnValue;
        var unselecteditems =[];
        coiWrappers.forEach(function (coiWrapper) {
            if (coiList.some(function (coiEl) {
                return coiEl.coi.Therapeutic_Area__c === coiWrapper.coi.Therapeutic_Area__c
            })) {
                coiWrapper.isSelected = true;
            }
        });
        
        
        if(coiWrappers){
            for(let i = 0; i < coiWrappers.length; i++){
                if(!coiWrappers[i].isSelected){
                    unselecteditems.push(coiWrappers[i]);
                }
            
            }
        }
        component.set('v.displayedItems', unselecteditems);
    });
    },
    
    saveElement: function (component,event,helper) {
    
    const deleteCOI = component.get('v.conditionOfInterestList');
    const conditionsOfInterestTemp = component.get('v.conditionsOfInterestTemp');
    let deleteCoiId = [];
    conditionsOfInterestTemp.sort(function (a, b) {
        return a.coi.Condition_Of_Interest_Order__c - b.coi.Condition_Of_Interest_Order__c;
    });
    for (var i = deleteCOI.length - 1; i >= 0; i--) {
        for (var j = 0; j < conditionsOfInterestTemp.length; j++) {
            if (deleteCOI[i] && (deleteCOI[i].coi.Id == conditionsOfInterestTemp[j].coi.Id)) {
                deleteCOI.splice(i, 1);
            }
        }
    }
    if (deleteCOI) {
        deleteCoiId = deleteCOI.map(function (e) {
            return e.coi.Id;
        });
    }
    if (deleteCoiId) {
        communityService.executeAction(component, 'deleteCOI', {
            coiIds: deleteCoiId
        }, function (returnValue) {
        });
    }
    
    let copy = JSON.parse(JSON.stringify(conditionsOfInterestTemp));
    component.set('v.conditionsOfInterest', copy);
    let arr = [];
    component.find('searchInput').set('v.value', '');
    component.set('v.isSaveList', !component.get('v.isSaveList'));
    var self=this;
    self.saveCOIs(component,event,helper);
    //component.find('displayeditm').refresh();
    communityService.showToast('success', 'success', $A.get('$Label.c.PP_Profile_Update_Success'));
    },
    saveCOIs: function (component,event,helper) {
    try{
    let coiWrapperList = component.get('v.conditionsOfInterest');
    let coiList = [];
    var bool = false;
    for (let i = 0; i < coiWrapperList.length; i++) {
        let coi = coiWrapperList[i].coi;
        coi.Condition_Of_Interest_Order__c = i + 1;
        coiList.push(coi);
        bool=true;
    }
    if (bool) {
        communityService.executeAction(component, 'upsertListCoi', {
            cois: coiList
        }, function (returnValue) {
            let coiSaveWrapperList = [];
            returnValue.forEach(function (e) {
                let coiSave = {};
                coiSave.isSelected = true;
                coiSave.coi = e;
                coiSaveWrapperList.push(coiSave);
            });
            var tempt= component.get('v.displayedItems');
            if(coiSaveWrapperList.size>0){
                component.set('v.displayedItems',coiSaveWrapperList);
                component.set('v.showPills',true); 
            }
            component.set('v.showmenu',false);
            component.set('v.conditionOfInterestList', coiSaveWrapperList);
            component.set('v.showSpinner', false);
        });
        communityService.executeAction(component, 'createSubscribeConnection', {
            cois: coiList
        });
    }
    }catch(e){
        console.log('value of excep ::: '+JSON.stringify(e));
    }
    },
    changeCheckBox: function (component, event) {
    let taList = component.get('v.conditionsOfInterestTemp');
    var capturedCheckboxName = event.getSource().get("v.value");
    var selectedCheckBoxes =  component.get("v.selectedValues");
    var index = event.getSource().get("v.name");
    let uncheckedValues=[];
    let finalSelectedvalues=[];
    if(!event.getParam('checked')){
    for(let i=0;i<taList.length;i++){
        if(taList[i].coi.Therapeutic_Area__r.Name===capturedCheckboxName.coi.Therapeutic_Area__r.Name){
            uncheckedValues.push(capturedCheckboxName.coi.Therapeutic_Area__r.Name);
    
    
        }
    }
    if(uncheckedValues){
        for(let j=0;j<taList.length;j++){
    if(uncheckedValues.includes(taList[j].coi.Therapeutic_Area__r.Name)){
        
       
    
    }
    else{
        finalSelectedvalues.push(taList[j]);
    
    
    }
    
        }
        taList=finalSelectedvalues;
    
    }
    
    
    }
    else{
    if(taList.length<5){
        selectedCheckBoxes.push(capturedCheckboxName);
        taList.push(capturedCheckboxName);
    }else{
        event.getSource().set('v.checked',false);
    }
    }
    
    component.set('v.conditionsOfInterestTemp', taList);
    },
    handleClearPill:function(component,event){
    var pillName = event.getSource().get('v.name');
    var pills = component.get('v.conditionsOfInterestTemp');
    var selectedList=[];
    for (var i = 0; i < pills.length; i++) {
        if (pillName === pills[i].coi.Therapeutic_Area__r.Name) { 
            selectedList.push(pills[i]);
            pills.splice(i, 1);
            
            break;
        }
        }
        component.set('v.conditionsOfInterestTemp', pills);
        component.set('v.displayedItems', pills);
    
    }
    })