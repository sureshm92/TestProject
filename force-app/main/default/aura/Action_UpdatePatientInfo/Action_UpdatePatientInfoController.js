/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, hepler) {
        communityService.executeAction(component, 'getInitData', null, function (formData) {
            var todayDate = $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD');
            component.set('v.formData', formData);
            component.set('v.initialized', true);
        }, null, function () {
            component.find('spinner').hide();
        });
    },

    doExecute: function (component, event, hepler) {
        try{
            var params = event.getParam('arguments');
            var pe = JSON.parse(JSON.stringify(params.pe));
            var formComponent = component.find('editForm');
            component.set('v.pe', pe);
            component.set('v.participant', pe.Participant__r);
            component.set('v.callback', $A.getCallback(params.callback));
            component.set('v.isFinalUpdate', params.isFinalUpdate);
            if(params.cancelCallback) component.find('dialog').set('v.closeCallback', $A.getCallback(params.cancelCallback));
            formComponent.createDataStamp();
            formComponent.checkFields();
            if(params.isFinalUpdate && formComponent.get('v.isValid')){
                params.callback(pe);
            }else{
                if(params.isFinalUpdate) communityService.showSuccessToast('',  $A.get('$Label.c.RP_Missing_Fields', 1000));
                component.find('dialog').show();
            }
        }catch (e) {
            console.error(e);
        }
    },

    doUpdate: function(component, event, helper){
        var participant = component.get('v.participant');
        var pe = component.get('v.pe');
        component.find('spinner').show();
        communityService.executeAction(component, 'updatePatientInfo', {
            participantJSON: JSON.stringify(participant),
            peJSON: JSON.stringify(pe)
        }, function () {
            component.get('v.callback')(pe);
            component.find('dialog').hide();
        }, null, function () {
            component.find('spinner').hide();
        })
    },

    doCancel : function (component) {
        component.find('dialog').cancel();
    },


})