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
                    $A.get('$Label.c.SS_Success_Save_Message')
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
        console.log('hhh'+index);
        var accountsList = JSON.parse(JSON.stringify(component.get('v.studySiteAccounts')));
        
        var studySite = component.get('v.studySite');
        var account;
        if(!$A.util.isUndefinedOrNull(index)){
            account = accountsList[index];
           
        }
        component.set('v.editLocation',true);
         var currentIndex=component.get('v.CurrenIndexOpen');
         if(currentIndex != null || currentIndex != 'null' || currentIndex != "new"){
             var childComponent = component.find("siteloc")[currentIndex];
            console.log('aura id-->'+component.find("siteloc")[currentIndex]);
            childComponent.closeTab();
         }
        component.set('v.CurrenIndexOpen',"new");
        if (!account) {
            account = {
                BillingCountryCode: studySite.BillingCountryCode,
                BillingStateCode: studySite.BillingStateCode,
                sobjectType: 'Account'
            };
        }
        //component.set('v.editLocation',true);
        component.find('editLocation').execute(account, studySite.siteId, function (account) {
            if (index) {
                accountsList[index] = account;
            } else {
                accountsList.push(account);
            }
            
            helper.sortAndSetAccountsByName(component, accountsList);
            studySite.siteId = account.Id;
            studySite.Site__r = account;
            var radioBtns = component.find('radioBtn');
            for (let i = 0; i < radioBtns.length; i++) {
                if (radioBtns[i].get('v.value').Id == account.Id) {
                    radioBtns[i].set('v.checked', true);
                } else {
                    radioBtns[i].set('v.checked', false);
                }
            }
            
            communityService.showToast(
                'success',
                'success',
                $A.get('$Label.c.SS_Success_Save_Message')
            );
            component.get('v.callback')(studySite, accountsList);
        });
        
    },
    
    refreshTable: function (component, event, helper)  {
        console.log('account11'+JSON.stringify(component.get('v.account')));
        var piId = component.get('v.piId');
        helper.getCountryData(component, event, helper);
        communityService.executeAction(
            component, 'getAccountData',
            {
                ContactId : piId
            },
            function (returnValue) 
            {
                component.set('v.studySiteAccounts',returnValue);
            });
    },
    
    handleSectionToggle: function (component, event, helper)  {
        component.find('modalSpinner').show();
        var piId = component.get('v.piId');
        var openSections = event.getParam('openSections');
        component.set('v.editLocation',false);
       
        if (openSections.length === 0) {
            component.set('v.sectionOpen', true);
        }
        helper.getCountryData(component, event, helper);
        communityService.executeAction(
            component, 'getAccountData',
            {
                ContactId : piId
            },
            function (returnValue) 
            {
                component.set('v.studySiteAccounts',returnValue);
            });
         if(component.get('v.sectionOpen')){
            component.set('v.sectionOpen',false);
        }else{
             component.set('v.sectionOpen',true);
        }
        component.find('modalSpinner').hide();
    },
    CloseOtherAccTab:function (component, event, helper)  {
        var index = event.getParam("EditIndex"); 
        var currentIndex=component.get('v.CurrenIndexOpen');
        if(currentIndex == null || currentIndex == 'null' || currentIndex == "new"){
          component.set('v.CurrenIndexOpen',index);
          component.set('v.editLocation',false);
        }else{
            var childComponent = component.find("siteloc")[currentIndex];
            console.log('aura id-->'+component.find("siteloc")[currentIndex]);
            childComponent.closeTab();
            component.set('v.CurrenIndexOpen',index);
        }
       
    },
     tabClosed:function (component, event, helper)  {
          component.set('v.CurrenIndexOpen',"null");
     },
    closeTab: function (component, event, helper) {
          component.set('v.editLocation',false);
           component.set('v.CurrenIndexOpen',"null");
     }
});