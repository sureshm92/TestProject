/**
 * Created by Yehor Dobrovolskyi
 */
({
    doInit: function (component, event, helper) {
        communityService.executeAction(component, 'getConditionOfInterest', {}, function (returnValue) {
            
        component.set('v.conditionOfInterestList', returnValue);
        
        let copy = JSON.parse(JSON.stringify(component.get('v.conditionOfInterestList')));

        component.set('v.conditionsOfInterestTemp', copy);
        
        helper.valueChange(component, event, helper);
            });
        
        
    },

      setReferralSearchResult : function(component, event) { 
        //Get the event message attribute
        var refResult = event.getParam("refResult");
        var sobjectName = event.getParam("sobjectName");
        var isChanged = event.getParam("isChanged");
        var referralResult = component.get('v.referralResult');
        if(sobjectName == 'Referral_Network__c') {
            component.set('v.referralResult', refResult);
        if(isChanged === true)
            component.set('v.isReferalChange' , false);
        else
            component.set('v.isReferalChange' , true); 
        
        }   
        if(sobjectName == 'Therapeutic_Area__c') {
            component.set('v.therapeticResult', refResult); 
                if(isChanged === true)
                component.set('v.isTherapChange' , false);
            else
                component.set('v.isTherapChange' , true); 
        
            }  
         // console.log('refResult'+ refResult);
               
    } ,
    show: function (component, event, helper) {
        helper.valueChange(component, event, helper);
        component.find('searchModal').show();
    },

    hide: function(component, event, helper) {
        component.find('searchModal').hide();
    },

    bulkSearch: function (component, event, helper) {
        var bypass = component.get('v.bypass');
        var coival = component.find("searchInput").get("v.value");
        if(coival){
            component.set('v.itemshow',true);
        }else{
           component.set('v.itemshow',false); 
        } 
        component.set('v.showmenu',true);
        if (bypass) {
            return;
        } else {
            component.set('v.bypass', true);
            window.setTimeout(
                $A.getCallback(function () {
                    helper.valueChange(component, event, helper);
                }), 500
            );
        }
    },

    handleChange: function (component, event, helper) {
        helper.changeCheckBox(component, event);
    },

    doSave: function (component, event, helper) {
        helper.saveElement(component,event,helper);
    },
    handleRemoveOnly: function (component, event,helper) {
        event.preventDefault();
        helper.handleClearPill(component,event,helper);       
        }
    
,    
   savechanges : function (component, event) {
      
		var referralResult = component.get('v.referralResult');//, refResult);
        var therapeticResult =  component.get('v.therapeticResult');//, refResult);
       var referrals = [];
       for(var i in referralResult) {
          
       		referrals.push(referralResult[i]);
       }
       for(var i in therapeticResult) {
       		referrals.push(therapeticResult[i]);
       }  
       console.log('referrals'+ JSON.stringify(referrals));
        communityService.executeAction(component, 'saveReferralNetworksNew', {
            referralNetworkJSON: JSON.stringify(referrals)
        }, function (returnValue) {
            component.set('v.showSpinner',false);
            component.set('v.isReferalChange', true);
             component.set('v.isTherapChange', true);
         // console.log(returnValue);
             communityService.showToast('success', 'success', $A.get('$Label.c.PP_Profile_Update_Success'),100);
        });
    }
    
})