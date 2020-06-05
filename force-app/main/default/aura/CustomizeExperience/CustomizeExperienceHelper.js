/**
 * Created by Yehor Dobrovolskyi
 */
({
    valueChange: function (component, event, helper) {
        //debugger;
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
        //component.set('v.displayedItems', arr);
        //console.log("Value of conditionsOfInterestTemp 8 :: "+JSON.stringify(component.get('v.displayedItems')));
        component.find('searchInput').set('v.value', '');
        component.set('v.isSaveList', !component.get('v.isSaveList'));
        var self=this;
        self.saveCOIs(component,event,helper);
        $A.get('e.force:refreshView').fire();
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
        //alert('taList'+JSON.stringify(taList));
        var capturedCheckboxName = event.getSource().get("v.value");
        var selectedCheckBoxes =  component.get("v.selectedValues");
        //alert('selcted'+JSON.stringify(capturedCheckboxName));
        if(selectedCheckBoxes.indexOf(capturedCheckboxName) > -1){
            for (var i = 0; i < taList.length; i++) {
                            if (capturedCheckboxName.coi.Therapeutic_Area__r.Name === taList[i].coi.Therapeutic_Area__r.Name) { 
                                //selectedList.push(pills[i]);
                                taList.splice(i, 1);
                              
                              break;
                            }
                          }
        }else{
            if(selectedCheckBoxes.length<5){
                //alert('inside length<5'+JSON.stringify(capturedCheckboxName));
                selectedCheckBoxes.push(capturedCheckboxName);
                taList.push(capturedCheckboxName);
            }else{
                event.getSource().set('v.checked', false);

            }
            }
        component.set('v.conditionsOfInterestTemp', taList);
    }
})