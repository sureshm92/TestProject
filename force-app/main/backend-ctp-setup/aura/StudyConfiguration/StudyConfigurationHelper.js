({
    saveCTPHelper: function (component, event, helper) {
        var source = event.getSource().get('v.name');
        console.log('Source: ' + source);
        var appEvent = $A.get('e.c:TaskToggleEvent');
        if (source === 'studyWorkspaceToggle') {
            let stworkValue = component.find('stworkspaceToggle').get('v.checked');
            component.find('prToggle').set('v.checked', !stworkValue);
        }
        if (source === 'programToggle') {
            let prValue = component.find('prToggle').get('v.checked');
            component.find('stworkspaceToggle').set('v.checked', !prValue);
        }
        if (source === 'visitScheduleToggle' && (component.get('v.ctp').CommunityTemplate__c != "PatientPortal")) {
            let vsValue = component.find('vsToggle').get('v.checked');
            component.find('stToggle').set('v.checked', !vsValue);
        }
        if (source === 'statusTimelineToggle') {
            let stValue = component.find('stToggle').get('v.checked');
            component.find('vsToggle').set('v.checked', !stValue);
        }
        if (source === 'medicalVendorToggle') {
            let stValue = component.find('mdToggle').get('v.checked');
            component.find('mdToggle').set('v.checked', stValue);
        }
        //Teleevisit Starts
        if (source === 'TelevisitToggle') {
            let stValue = component.find('teleToggle').get('v.checked');
            component.find('teleToggle').set('v.checked', stValue);
        }
        //Ends
        if(source === 'saveDelayDays'){
            component.set('v.delay_days', component.get("v.ctp.Delayed_No_Of_Days__c"));
        }
        else{
            component.set('v.ctp.Delayed_No_Of_Days__c', component.get("v.delay_days"));
        }
        //eCOA toggle logic
        if(source === 'saveECOAGUIDs'){
            component.set('v.study_guid', component.get("v.ctp.Study_GUID__c"));
            component.set('v.study_version_guid', component.get("v.ctp.Study_Version_GUID__c"));
        }
        else{
            //Initialize the GUIDs with the actual GUIds saved in database when other toggle action gets perform.
            component.set('v.ctp.Study_GUID__c', component.get("v.study_guid"));
            component.set('v.ctp.Study_Version_GUID__c', component.get("v.study_version_guid"));
        }
        //IQVIA Outreach
        if (source === 'IqviaOutreach') {
            let stValue = component.find('iqviaToggle').get('v.checked');
            component.find('iqviaToggle').set('v.checked', stValue);
        }
        
        
        component.find('spinner').show();
        //check if source is saveECOAGUIDs and study GUID and study Version GUID inputs are valid. 
        var saveGUIDsforECOAToggle = source === 'saveECOAGUIDs' && component.find('studyGUID').reportValidity() && component.find('studyVersionGUID').reportValidity();
        //check if the source is other than saveDelayDays and saveECOAGUIDs. 
        var saveOtherToggles = source !== 'saveDelayDays' && source !== 'saveECOAGUIDs';
        if((source === 'saveDelayDays' && component.find('delayedDays').reportValidity()) || saveGUIDsforECOAToggle || saveOtherToggles){
            communityService.executeAction(
                component,
                'saveChanges',
                {
                    ctp: component.get('v.ctp')
                },
                function () {
                    component.find('spinner').hide();
                    
                    if(source === 'TelevisitToggle'){
                        const lmsTest = {
                            recordId: "TestRecord",
                            name: "Burlington Textiles of America"
                          };
                        component.find("sampleMessageChannel").publish(lmsTest);
                    }
                    if(source === 'E-Consent_Configuration'){
                        var appEvent = $A.get("e.c:EconsentEvent"); 
                        appEvent.fire(); 
                    }
                    communityService.showSuccessToast('Success', 'Study Configuration setting saved!');
                }
            );
        }
        else{
            component.find('spinner').hide();
            //  communityService.showToast('Error', 'error', 'The incentive program already exists');
        }
        if (source === 'tasksToggle') {
            $A.get('e.force:refreshView').fire();
            appEvent.fire();
        }
    }
});