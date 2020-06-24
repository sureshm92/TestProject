/**
 * Created by Nargiz Mamedova on 12/9/2019.
 */

({
    doInit: function (component, event, helper) {
        communityService.executeAction(component, 'getInitData', {
            ctpId : component.get('v.recordId')
         }, function (initData) {
            component.set('v.ctp', initData.ctp);
            component.set('v.user_has_permission', initData.user_has_permission);
            component.set('v.noVisitPlansMessage', initData.noVisitPlansMessage);
            component.find('spinner').hide();
        });

    },
	
    savePostEnrollment: function (component, event, helper) {
        try{
        if(!component.find('tvToggle').get('v.checked')){
            component.find('cToggle').set('v.checked', false);
            component.find('ruToggle').set('v.checked', false);
        }
        helper.saveCTPHelper(component, event, helper);
            }catch(e){
            alert(e.message);
        }
    },

    saveConsentThroughEnrolledOrRandomized: function (component, event, helper) {
        try{
        helper.saveCTPHelper(component, event, helper);
            }catch(e){
            alert(e.message);
        }
    },
    
    saveCTP: function (component, event, helper) {
		helper.saveCTPHelper(component, event, helper);
    }
});