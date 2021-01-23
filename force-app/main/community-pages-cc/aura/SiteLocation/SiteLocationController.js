({
	 editAccountAddress: function (component, event, helper) {
        //component.find("accordion").set('v.activeSectionName', 'SSL');
        //component.handleSectionToggle();
        //var index = event.currentTarget.dataset.index;
        var index = component.get('v.accIndex');
        var accountsList = JSON.parse(JSON.stringify(component.get('v.studySiteAccounts')));
        
        var studySite = component.get('v.studySite');
        var account;
        if(!$A.util.isUndefinedOrNull(index)){
            account = accountsList[index];
            component.set('v.editLocations',true);
        }
       
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
    }

})