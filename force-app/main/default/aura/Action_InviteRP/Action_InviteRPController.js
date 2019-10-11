/**
 * Created by Kryvolap on 13.08.2019.
 */
({
    doInit: function (component, event, helper) {
        component.find('modalSpinner').show();
        communityService.executeAction(component, 'getInviteDetail', {
        }, function (returnValue) {
            var initData = JSON.parse(returnValue);
            helper.clearInviteFields(component, event, helper);
            component.set("v.studySitesForInvitation",initData.studySitesForInvitation);
            component.find('modalSpinner').hide();
        })
    },
    doExecute: function (component, event, helper) {
        component.find('modalSpinner').hide();
        helper.clearInviteFields(component, event, helper);
        component.set('v.isDuplicate', false);
        component.set('v.providerFound', false);
        component.find('inviteRPDialog').show();
    },
    doInviteRP: function (component, event, helper) {
        var firstName = component.get('v.firstName');
        var lastName = component.get('v.lastName');
        //var clinicName = component.get('v.clinicName');
        var phone = component.get('v.phone');
        var emailS = component.get('v.emailS');
        var studySiteId = component.get('v.studySiteId');
        var protocolId = component.get('v.protocolId');
        component.find('modalSpinner').show();
        communityService.executeAction(component, 'inviteHCP', {
            firstName: firstName,
            lastName: lastName,
            //clinicName: clinicName,
            phone: phone,
            email: emailS,
            studySiteId: studySiteId,
            protocolId: protocolId,
        }, function (returnValue) {
            var initData = JSON.parse(returnValue);
            component.find('modalSpinner').hide();
            helper.clearInviteFields(component, event, helper)
            component.find('inviteRPDialog').hide();
            communityService.showToast("success", "success",  $A.get("$Label.c.TST_Request_to_invite_a_referring_provider"));
        })

    },
    doSelectStudy: function (component, event, helper) {
        var siteId = event.getSource().get('v.value');
        component.set('v.studySiteId', siteId.Id);
        component.set('v.protocolId', siteId.protocolId);
    },
    checkReqFields : function (component, event, helper) {
        var firstName = component.get('v.firstName');
        var lastName = component.get('v.lastName');
        //var clinicName = component.get('v.clinicName');
        var phone = component.get('v.phone');
        var emailS = component.get('v.emailS');
        var inputPattern = new RegExp('[!+@#$%^&*(),.?":{}|<>]','g');
        var phonePattern = new RegExp('[!@#$%^&*,.?":{}|<>]','g');
        var reqFieldsFilled = (inputPattern.test(firstName) || !firstName.trim()) ||
            (inputPattern.test(lastName) || !lastName.trim()) ||
            ((phonePattern.test(phone) || !phone.trim()) &&
                (emailS == undefined || emailS == ''));// ||
            //(inputPattern.test(clinicName) || !clinicName.trim());
        component.set('v.reqFieldsFilled',reqFieldsFilled);
    },
    doClearInviteAndHide: function (component, event, helper) {
        helper.clearInviteFields(component, event, helper)
        component.find('inviteRPDialog').hide();
    },

    checkContact: function(component, event, helper){
        var email = event.getSource().get('v.value');
        if(email && communityService.isValidEmail(email)) {
            component.find('modalSpinner').show();
            communityService.executeAction(component, 'checkDuplicate', {
                email: email
            }, function (returnValue) {
                if (returnValue.firstName) {
                    component.set('v.firstName', returnValue.firstName);
                    component.set('v.lastName', returnValue.lastName);
                    component.set('v.providerFound', true);
                    component.set('v.isDuplicate', returnValue.isDuplicate);
                    component.find('modalSpinner').hide();
                } else {
                    component.set('v.firstName', '');
                    component.set('v.lastName', '');
                    component.set('v.isDuplicate', returnValue.isDuplicate);
                    component.set('v.providerFound', false);
                    component.find('modalSpinner').hide();
                }
            });
        }
    },
})