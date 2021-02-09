({
    doExecute: function (component, event, helper) {
        var params = event.getParam('arguments');
        var ssWrapper = JSON.parse(JSON.stringify(params.studySiteWrapper));
        component.set('v.studySite', ssWrapper.studySite);
        helper.sortAndSetAccountsByName(component, ssWrapper.accounts);
        if (params.callback) component.set('v.callback', $A.getCallback(params.callback));
        component.find('manageLocation').show();
    },
    
    changeRadioMarker: function (component, event, helper) {
        var radioBtns = component.find('radioBtn');
        for (let i = 0; i < radioBtns.length; i++) {
            radioBtns[i].set('v.checked', false);
        }
        event.getSource().set('v.checked', true);
        component.set('v.checkedAccount', event.getSource().get('v.value'));
        component.set('v.locationWasChanged', true);
    },
    
    changeStudySiteAddress: function (component, event, helper) {
        component.find('modalSpinner').show();
        var studySite = component.get('v.studySite');
        studySite.Site__r = component.get('v.checkedAccount');
        studySite.Site__c = component.get('v.checkedAccount').Id;
        communityService.executeAction(
            component,
            'changeSSAccount',
            { ssId: studySite.Id, accountId: studySite.Site__c },
            function () {
                communityService.showToast(
                    'success',
                    'success',
                    $A.get('$Label.c.CC_Success_Save_Message')
                );
                component.set('v.locationWasChanged', false);
                component.find('modalSpinner').hide();
                component.find('manageLocation').hide();
                component.get('v.callback')(studySite);
            }
        );
    },
    
    doCancel: function (component, event, helper) {
        component.find('manageLocation').cancel();
    },
    newAccountAddress: function (component, event, helper) {
        component.find("accordion").set('v.activeSectionName', 'SSL');
        //component.handleSectionToggle();
        // if(component.get('v.sectionOpen')){
         //component.find("accordion").set('v.activeSectionName', 'SSL');
         //}
        var index = event.currentTarget.dataset.index;
        var accountsList = JSON.parse(JSON.stringify(component.get('v.studySiteAccounts')));
        
        var studySite = component.get('v.studySite');
        var account;
        if(!$A.util.isUndefinedOrNull(index)){
            account = accountsList[index];
           
        }
        component.set('v.CurrenIndexOpen',"new");
        component.set('v.isEdited',true);
         var currentIndex=component.get('v.CurrenIndexOpen');
         
         if(currentIndex != null && currentIndex != 'null' && currentIndex != 'new'){
             var childComponent = component.find("siteloc")[currentIndex];
            childComponent.closeTab();
        }
        if (!account) {
            account = {
                BillingCountryCode: studySite.BillingCountryCode,
                BillingStateCode: studySite.BillingStateCode,
                sobjectType: 'Account'
            };
        }
        component.set('v.editLocation',true);
        component.find('editLocation').execute(account, studySite.siteId, function (account) {
            if (index) {
                accountsList[index] = account;
            } else {
                accountsList.push(account);
            }
            studySite.site = account.Id;
            component.set('v.account',account);
            component.set('v.studySite',studySite);
            helper.sortAndSetAccountsByName(component, accountsList);
            component.set('v.editLocation',false);
            component.find('modalSpinner').hide();
            communityService.showToast(
                'success',
                'success',
                $A.get('$Label.c.SS_Success_Save_Message')
            );
            var cmpEvent = component.getEvent("CloseEvent"); 
            //Set event attribute value
            cmpEvent.setParams({"EditIndex" : index}); 
            cmpEvent.fire(); 
        });
        
    },
    
    refreshTable: function (component, event, helper) {
        var piId = component.get('v.piId');
        helper.getCountryData(component, event, helper);
        communityService.executeAction(
            component, 
            'getAccountData',
            {
                ContactId: piId
            },
            function (returnValue) {
                component.set('v.studySiteAccounts', returnValue);
            }
        );
    },
    
    handleSectionToggle: function (component, event, helper) {
        component.find('modalSpinner').show();
        var piId = component.get('v.piId');
        var openSections = event.getParam('openSections');
        component.set('v.editLocation', false);
       
        if (openSections.length === 0) {
            component.set('v.sectionOpen', true);
        }
        helper.getCountryData(component, event, helper);
        var StudySiteAccount;
        communityService.executeAction(
            component,
            'getAccountData',
            {
                ContactId: piId
            },
            function (returnValue) {
                StudySiteAccount = returnValue ;
                helper.sortAndSetAccountsByName(component, StudySiteAccount); 
            });
      /*  if(!$A.util.isUndefinedOrNull(StudySiteAccount))
        {
           helper.sortAndSetAccountsByName(component, StudySiteAccount); 
        } */
         if(component.get('v.sectionOpen')){
            component.set('v.sectionOpen',false);
            component.set('v.isEdited',false);
        }else{
             component.set('v.sectionOpen',true);
        }
        component.find('modalSpinner').hide();
    },
    CloseOtherAccTab: function (component, event, helper) {
        var index = event.getParam('EditIndex'); 
        var currentIndex = component.get('v.CurrenIndexOpen');
        if (currentIndex == null || currentIndex == 'null' || currentIndex == 'new') {
          component.set('v.CurrenIndexOpen', index);
          component.set('v.editLocation', false);
        } else {
            var childComponent = component.find('siteloc')[currentIndex];
            childComponent.closeTab();
            component.set('v.CurrenIndexOpen', index);
        }
    },
     tabClosed: function (component, event, helper) {
          component.set('v.CurrenIndexOpen', 'null');
     },
    closeTab: function (component, event, helper) {
          component.set('v.editLocation', false);
           component.set('v.CurrenIndexOpen', 'null');
     }
});