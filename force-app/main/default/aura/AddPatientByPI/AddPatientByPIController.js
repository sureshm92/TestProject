/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        var isEditMode = component.get('v.isEditMode');
        if(!communityService.isInitialized()) return;
        var ctpId = isEditMode ? null : communityService.getUrlParameter('id');
        var ssId = communityService.getUrlParameter('ssId');
        communityService.executeAction(component, 'getInitData', {
            ctpId: ctpId,
            ssId : ssId ? ssId : null
        }, function (formData) {
            console.log('formData>>>',formData);
            component.set('v.ctp', formData.ctp);
            component.set('v.ss', formData.ss);
            var todayDate = $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD');
            component.set('v.todayDate', todayDate);
            component.set('v.formData', formData);
            if(isEditMode){
                helper.initDataEdit(component,event,helper);
            }else{
                helper.initData(component);
            }
            component.set('v.initialized', true);
            var pe = component.get('v.pe');
            var states = formData.statesByCountryMap['US'];
            component.set('v.statesLVList', states);
        }, null, function () {
            component.find('spinner').hide();
        });
        
    },
    
    doCheckFields: function (component,event,helper) {
       helper.checkFields(component,event,helper);
    },

    doCountryCodeChanged: function(component, event, helper){
        var statesByCountryMap = component.get('v.formData.statesByCountryMap');
        var participant = component.get('v.participant');
        var states = component.get('v.formData.statesByCountryMap')[participant.Mailing_Country_Code__c];
        component.set('v.statesLVList', states);
        //component.set('v.participant.Mailing_State_Code__c', null);
        component.checkFields();
    },

    doCancel: function (component) {
        //communityService.navigateToPage('study-workspace?tab=tab-referrals&id=' + component.get('v.ctp.Id'))
        communityService.navigateToHome();
    },

    doSaveAndExit: function (component, event, helper) {
        helper.createParticipant(component, function () {
           //communityService.navigateToPage('study-workspace?tab=tab-referrals&id=' + component.get('v.ctp.Id'))
            communityService.navigateToHome();
        })
    },

    doSaveAndNew: function (component, event, helper) {
        helper.createParticipant(component, function () {
            helper.initData(component);
        })
    }
})
