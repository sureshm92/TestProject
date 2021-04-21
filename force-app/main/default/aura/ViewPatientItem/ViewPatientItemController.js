/**
 * Created by Leonid Bartenev
 */
({
    
    doInit: function (component, event, helper) {
        
        helper.prepareCardFields(component, event);
        // added for differntiate PP & RH portals view more button.
        if (component.get('v.userMode') && component.get('v.userMode') == 'Participant')
            component.set('v.isHidden', true);
        component.find('spinner').hide();
        
        component.set('v.authRequired', component.get('v.pe.Clinical_Trial_Profile__r.Patient_Auth_Upload_Required__c'));        
        
    },
    
    //Added for the performance tuning
    preparePathItems: function (component, event, helper) {
        if (component.get('v.pe')) {
            helper.toggleBubbleMap(component, event);
            //helper.preparePathItems(component, event);
            var peId = component.get("v.pe.Id");
            
            communityService.executeAction(component,
                                           'getAuthForm',
                                           {
                                               peId : peId 
                                           },
                                           function (returnValue) {
                                               var responseData = JSON.parse(returnValue); 
                                               component.set('v.subDomain', communityService.getSubDomain());
                                               component.set('v.signedDoc', responseData);
                                           });
        }
    },
    
    doChangeStatus: function (component, event, helper) {
        var rootComponent = component.get('v.parent');
        rootComponent.find('mainSpinner').show();
        var pe = component.get('v.pe');
        var status = event.currentTarget.dataset.statusName;
        var changePEStatusByPIAction = rootComponent.find('changePEStatusByPIAction');
        changePEStatusByPIAction.execute(
            pe,
            status,
            null,
            null,
            function (pe) {
                component.set('v.pe', pe);
                rootComponent.find('mainSpinner').hide();
            },
            function () {
                rootComponent.find('mainSpinner').hide();
            }
        );
    },
    
    showEditParticipantInformation: function (component, event, helper) {
        var rootComponent = component.get('v.parent');
        var pe = component.get('v.pe');
        var actions = component.get('v.actions');
        var isInvited = component.get('v.isInvited');
        var anchor = event.currentTarget.value;
        rootComponent
        .find('updatePatientInfoAction')
        .execute(pe, actions, rootComponent, isInvited, function (enrollment) {
            component.set('v.pe', enrollment);
            //rootComponent.find('updatePatientInfoAction').set('v.pathItems', component.get('v.pathItems'));
            rootComponent.refresh();
        });
    },
    doPreScreening: function (component, event, helper) {
        var rootComponent = component.get('v.parent');
        var pe = component.get('v.pe');
        var frameHeight = component.get('v.frameHeight');
        var isInvited = component.get('v.isInvited');
        //component.set('v.showSpinner', true);
        rootComponent
        .find('openSearch')
        .execute(pe, rootComponent, frameHeight, isInvited, function (enrollment) {
            component.set('v.pe', enrollment);
            rootComponent.refresh();
        });
    },
    closeCard: function (component, event, helper) {
        component.set('v.isHidden', false);
        var appEvent = $A.get('e.c:ViewMore');
        appEvent.fire();
    },
    
    openModel : function(component, event, helper){       
        var signedDoc = component.get("v.signedDoc");
        if (signedDoc.attachments[0].ContentSize < 11534336 ) //In Bytes(in binary)
        {                  
            component.set('v.openmodel',true);
        } 
        else 
        {
            component.set('v.openmodel',false);
        }
    },
    
    closeModal:function(component,event,helper){    
        component.set('v.openmodel',false);
    },
    
});