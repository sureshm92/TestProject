({
    editAccountAddress: function (component, event, helper) {
        component.set('v.isEdited',true);
        var index = component.get('v.accIndex');
        var accountsList = JSON.parse(JSON.stringify(component.get('v.studySiteAccounts')));
        
        var studySite = component.get('v.studySite');
        
        var account;
        if(!$A.util.isUndefinedOrNull(index)){
            account = accountsList[index];
            component.set('v.account',account);
            component.set('v.editLocations',true);
        }
        if (!account) {
            account = {
                BillingCountryCode: studySite.BillingCountryCode,
                BillingStateCode: studySite.BillingStateCode,
                sobjectType: 'Account'
            };
        }
        component.find('editLocation').execute(account, studySite.siteId, function (account) {
            if (index) {
                accountsList[index] = account;
            } else {
                accountsList.push(account);
            }
            
            helper.sortAndSetAccountsByName(component, accountsList);
            studySite.site = account.Id;
            component.find('modalSpinner').hide();
            communityService.showToast(
                'success',
                'success',
                $A.get('$Label.c.SS_Success_Save_Message')
            );
            component.set('v.editLocation',false);
            // component.get('v.callback')(studySite, accountsList);
            component.set('v.account',account);
            component.set('v.studySite',studySite);
        });
         
         var cmpEvent = component.getEvent("CloseEvent"); 
         //Set event attribute value
         cmpEvent.setParams({"EditIndex" : index}); 
         cmpEvent.fire(); 
         
     },
    
    closeTab: function (component, event, helper) {
        component.set('v.editLocations',false);
        var p = component.get('v.gparent');
        p.tabClosed();
    },
    
    refreshTable: function (component, event, helper)  {
        var p = component.get('v.gparent');
        p.refreshTable();
    },
    
    changeRadioMarker: function (component, event, helper) {
        component.set('v.account',event.getSource().get('v.value'));
        component.set('v.editedAccount', event.getSource().get('v.value').Id);
        var accountChecked = event.getSource().get('v.value');
        var studySite = component.get('v.studySite');
        studySite.site = accountChecked.Id;
        component.set('v.studySite',studySite);
        component.set('v.isStudyInfoModified',true);
    }
    
})