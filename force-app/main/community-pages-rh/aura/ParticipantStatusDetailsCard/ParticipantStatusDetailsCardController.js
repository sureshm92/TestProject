/**
 * Created by Andrii Kryvolap.
 */
({
    doInit: function (component, event, helper) {
        let todayDate = $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD');
        component.set('v.todayDate', todayDate);
        let stepWrapper = component.get('v.stepWrapper');
        
        
        let sendToSH = true;
        sendToSH = component.get('v.participantWorkflowWrapper').sendToSH == false && component.get('v.participantWorkflowWrapper').sendToSHDate!=undefined?false:true;
        component.set(
            'v.stepWrapper.currentOutcomeSuccess',
            stepWrapper.successOutcomes.indexOf(stepWrapper.outcome) !== -1
        );
        component.set('v.sendToSH',sendToSH);
        component.set('v.reasonList', stepWrapper.reasonMap[stepWrapper.outcome]);
        component.set('v.previousSelectedOutcome', stepWrapper.outcome);
        component.set('v.disableReason', true);
        component.set('v.stepWrapper.reason', '');
        
        helper.checkValidity(component, event, helper, stepWrapper);
        //@krishna Mahto - For REF-1390- start
        // Display the error message when current step is contact Attemp
        console.log('********stepWrapper.cardTitle ' + stepWrapper.cardTitle);
        console.log('********stepWrapper.Status ' + stepWrapper.status);
        if (
            stepWrapper.cardTitle != null &&
            stepWrapper.cardTitle == $A.get('$Label.c.PWS_Contact_Card_Name') &&
            stepWrapper.isCurrentStep == true &&
            component.get('v.isDateTimeFieldsAvailable') == true
        ) {
            component.set('v.isSuccessfullyContacted', true);
        } else {
            component.set('v.isSuccessfullyContacted', false);
        }
        //@krishna Mahto - For REF-1390- end
        let fovhis = component.get('v.participantWorkflowWrapper').fovhistory;
       
        if(stepWrapper.title == 'Contact')
        {
            //console.log('msg--successfully contacted111-->'+JSON.stringify(stepWrapper));
            //console.log('Test--->'+JSON.stringify(component.get('v.participantWorkflowWrapper').sc));
            //console.log('history-->'+component.get('v.participantWorkflowWrapper').fovCreatedby.length);  
            //console.log('stepWrapper.stepHistory-->'+ stepWrapper.stepHistory.length);
            if(fovhis == 'notnull'){
                let contactHistorysize = stepWrapper.stepHistory.length;
                let fovHistorysize =  component.get('v.participantWorkflowWrapper').fovCreatedby.length;
                let fovModifieddate = component.get('v.participantWorkflowWrapper').fovCreateddate; 
                let fovModifiedby = component.get('v.participantWorkflowWrapper').fovCreatedby;  
                let contactHistory=stepWrapper.stepHistory;
                
                var historyList = [];
                var obj = {}; 
                for (var i = 0; i < contactHistorysize; i++) {
                    
                    if(contactHistory[i].isAdditionalNote){
                       
                        var str = contactHistory[i].detail;
                        var month = str.substring(4, 7);
                       
                        if(month == 'Jan')
                        {
                            month='01';
                        }else if(month == 'Feb'){
                            month='02';
                        }else if(month == 'Mar'){
                            month='03';
                        }else if(month == 'Apr'){
                            month='04';
                        }else if(month == 'May'){
                            month='05';
                        }else if(month == 'Jun'){
                            month='06';
                        }else if(month == 'Jul'){
                            month='07';
                        }else if(month == 'Aug'){
                            month='08';
                        }else if(month == 'Sep'){
                            month='09';
                        }else if(month == 'Oct'){
                            month='10';
                        }else if(month == 'Nov'){
                            month='11';
                        }else if(month == 'Dec'){
                            month='12';
                        }
                        var dt = str.substring(8, 10);
                       
                        var yr = str.substring(11, 15);
                       
                        var hr = str.substring(17, 19);
                        
                        var mn = str.substring(20, 22);
                       
                        var ampm = str.substring(23, 26);
                       
                        let ap = ampm;
                       
                        if(ap.includes("A")){
                           
                            if(hr == '12'){ hr ='00';}       
                        }else{
                          
                            if(hr == '1' || hr == '01'){
                                hr ='13';}else if(hr == '2' || hr == '02'){
                                    hr ='14';}else if(hr == '3' || hr == '03'){
                                        hr ='15';}else if(hr == '4' || hr == '04'){
                                            hr ='16';}else if(hr == '5' || hr == '05'){
                                                hr ='17';}else if(hr == '6' || hr == '06'){
                                                    hr ='18';}else if(hr == '7' || hr == '07'){
                                                        hr ='19';}else if(hr == '8' || hr == '08'){
                                                            hr ='20';}else if(hr == '9' || hr == '09'){
                                                                hr ='21';}else if(hr == '10' || hr == '010'){
                                                                    hr ='22';}else if(hr == '11' || hr == '011'){
                                                                        hr ='23';}
                        }
                        var finaldt=yr+'-'+month+'-'+dt+'T'+hr+':'+mn+':00.000Z';
                       
                        var createby = str.substring(28, str.length-1);
                       
                        obj.detailDate =finaldt; console.log('$$$$$%%%%-- ++++>'+  obj.detailDate); 
                        obj.createdBy = createby;
                        obj.title = contactHistory[i].title;
                        obj.string = true;
                        historyList.push(obj);
                        obj = {};                        
                    }else{
                        
                        obj.detailDate =  contactHistory[i].detailDate;
                        obj.createdBy = contactHistory[i].createdBy;
                        obj.title = contactHistory[i].title;
                        obj.string = false;
                        historyList.push(obj);
                        obj = {};
                    }  
                }
                for (var i = 0; i < fovHistorysize; i++) {
                   
                    obj.detailDate =  fovModifieddate[i];
                    obj.createdBy = fovModifiedby[i];
                    obj.title = $A.get('$Label.c.Initial_Visit_modified');
                    obj.string = false;
                    historyList.push(obj);
                    obj = {};
                }
                
                historyList.sort(function(a,b){
                    return new Date(a.detailDate) - new Date(b.detailDate)
                })
               
                component.set('v.historyList', historyList.reverse());  
            }else{
                let contactHistorysize = stepWrapper.stepHistory.length;  
                let contactHistory=stepWrapper.stepHistory;
                
                var historyList = [];
                var obj = {}; 
                for (var i = 0; i < contactHistorysize; i++) {
                    
                    if(contactHistory[i].isAdditionalNote){
                        
                        var str = contactHistory[i].detail;
                        var month = str.substring(4, 7);
                       
                        if(month == 'Jan')
                        {
                            month='01';
                        }else if(month == 'Feb'){
                            month='02';
                        }else if(month == 'Mar'){
                            month='03';
                        }else if(month == 'Apr'){
                            month='04';
                        }else if(month == 'May'){
                            month='05';
                        }else if(month == 'Jun'){
                            month='06';
                        }else if(month == 'Jul'){
                            month='07';
                        }else if(month == 'Aug'){
                            month='08';
                        }else if(month == 'Sep'){
                            month='09';
                        }else if(month == 'Oct'){
                            month='10';
                        }else if(month == 'Nov'){
                            month='11';
                        }else if(month == 'Dec'){
                            month='12';
                        }
                        var dt = str.substring(8, 10);
                       
                        var yr = str.substring(11, 15);
                       
                        var ampm = str.substring(23, 26);
                       
                        var hr = str.substring(17, 19);
                       
                        var mn = str.substring(20, 22);
                       
                        let ap = ampm;
                       
                        if(ap.includes("A")){
                            if(hr == '12')
                                hr ='00';
                        }else{
                            if(hr == '1' || hr == '01'){
                                hr ='13';}else if(hr == '2' || hr == '02'){
                                    hr ='14';}else if(hr == '3' || hr == '03'){
                                        hr ='15';}else if(hr == '4' || hr == '04'){
                                            hr ='16';}else if(hr == '5' || hr == '05'){
                                                hr ='17';}else if(hr == '6' || hr == '06'){
                                                    hr ='18';}else if(hr == '7' || hr == '07'){
                                                        hr ='19';}else if(hr == '8' || hr == '08'){
                                                            hr ='20';}else if(hr == '9' || hr == '09'){
                                                                hr ='21';}else if(hr == '10' || hr == '010'){
                                                                    hr ='22';}else if(hr == '11' || hr == '011'){
                                                                        hr ='23';}
                        }
                        var finaldt=yr+'-'+month+'-'+dt+'T'+hr+':'+mn+':00.000Z';
                        
                        var createby = str.substring(28, str.length-1);
                       
                        component.set('v.lastModifiedDate', finaldt);
                        obj.detailDate = component.get('v.lastModifiedDate');
                        obj.createdBy = createby;
                        obj.title = contactHistory[i].title;
                        obj.string = true;
                        historyList.push(obj);
                        obj = {};                        
                    }else{
                        obj.detailDate =  contactHistory[i].detailDate;
                        obj.createdBy = contactHistory[i].createdBy;
                        obj.title = contactHistory[i].title;
                        obj.string = false;
                        historyList.push(obj);
                        obj = {};
                    }  
                }
                component.set('v.historyList', historyList); 
            } 
            
        }
    },
    updateReasonList: function (component, event, helper) {
        let stepWrapper = component.get('v.stepWrapper');
        let previousSelectedOutcome = component.get('v.previousSelectedOutcome');
        let selectedOutcome = component.find('outcomeList').get('v.value');
        let outcomePlaceholder = component.get('v.stepWrapper.outcomePlaceholder');
        let parent = component.get('v.parent');
        var selectedOptionValue = event.getParam('value');
        //alert(selectedOutcome);
        if(selectedOutcome == 'Pre-review Failed' || selectedOutcome == 'Contacted - Not Suitable' || selectedOutcome == 'Unable to Reach'){
            component.set('v.validateFOV',true);
        }else{
            component.set('v.validateFOV',false);
        }
        if (!$A.util.isUndefinedOrNull(selectedOutcome) && selectedOutcome !== outcomePlaceholder) {
            component.set('v.stepWrapper.outcome', selectedOutcome);
            component.set(
                'v.stepWrapper.currentOutcomeSuccess',
                stepWrapper.successOutcomes.indexOf(stepWrapper.outcome) !== -1
            );
            let reasonList = stepWrapper.reasonMap[stepWrapper.outcome];
            component.set('v.reasonList', reasonList);
            component.set('v.disableReason', false);
            let reasonValue =
                reasonList === undefined || reasonList.length == 0 ? '' : reasonList[0].value;
            component.set('v.stepWrapper.reason', reasonValue);
            component.find('reasonList').set('v.value', reasonValue);
            component.set('v.previousSelectedOutcome', stepWrapper.outcome);
            component.set(
                'v.notesRequired',
                stepWrapper.notesRequiredMap[selectedOutcome + ';' + reasonValue]
            );
            var changesMap = { title: 'outcome', type: 'picklist', isChanged: true };
            parent.notifyParent(changesMap);
            //console.log('##outcome Will make a call to notifyParent');
            helper.checkValidity(component, event, helper, stepWrapper);
        }
    },
    updateNotesRequired: function (component, event, helper) {
        let stepWrapper = component.get('v.stepWrapper');
        let selectedReason = component.find('reasonList').get('v.value');
        component.set('v.stepWrapper.reason', selectedReason);
        component.set(
            'v.notesRequired',
            stepWrapper.notesRequiredMap[stepWrapper.outcome + ';' + stepWrapper.reason]
        );
        helper.checkValidity(component, event, helper, stepWrapper);
    },
    checkNotesRequiredValidity: function (component, event, helper) {
        let stepWrapper = component.get('v.stepWrapper');
        helper.checkValidity(component, event, helper, stepWrapper);
    },
    doUpdateFieldValidity: function (component, event, helper) {
        let inputFields = component.find('statusDetailField');
        if (inputFields !== undefined && !Array.isArray(inputFields)) {
            inputFields.checkValidity();
        } else if (inputFields !== undefined && Array.isArray(inputFields)) {
            inputFields.forEach(function (input) {
                input.checkValidity();
            });
        }
    }
});