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
            component.set("v.PIForInvetation",initData.PIForInvetation);
            component.find('modalSpinner').hide();
        })
    },
    doExecute: function (component, event, helper) {
        component.find('modalSpinner').hide();
        helper.clearInviteFields(component, event, helper);
        component.set('v.refreshView', true);
        component.set('v.refreshView', false);
        component.set('v.isDuplicate', false);
        component.set('v.providerFound', false);
        component.checkfields(component,event,helper);
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
        var isDuplicate = component.get('v.isDuplicate');
        var hcpContactId = component.get('v.hcpContactId');
        var piIds = component.get('v.checkboxGroupValues');
        component.find('modalSpinner').show();
        if (!hcpContactId) {
            communityService.executeAction(component, 'inviteNewHCP', {
                firstName: firstName,
                lastName: lastName,
                //clinicName: clinicName,
                phone: phone,
                email: emailS,
                studySiteId: studySiteId,
                protocolId: protocolId,
                piIds: piIds
            }, function (returnValue) {
                var initData = JSON.parse(returnValue);
                component.find('modalSpinner').hide();
                helper.clearInviteFields(component, event, helper)
                component.find('inviteRPDialog').hide();
                communityService.showToast("success", "success", $A.get("$Label.c.TST_Request_to_invite_a_referring_provider"));
            });
        } else {
            communityService.executeAction(component, 'inviteExistingHCP', {
                hcpContactId: hcpContactId,
                piIds: piIds
            }, function (returnValue) {
                component.find('modalSpinner').hide();
                if (returnValue != $A.get('$Label.c.RP_Is_Already_Invited')) {
                    helper.clearInviteFields(component, event, helper)
                    component.find('inviteRPDialog').hide();
                    communityService.showToast("success", "success", $A.get("$Label.c.TST_Request_to_invite_a_referring_provider"));
                } else {
                    communityService.showSuccessToast('',  $A.get('$Label.c.RP_Is_Already_Invited'));
                }
            });
        }
    },
    doSelectStudy: function (component, event, helper) {
        var siteId = event.getSource().get('v.value');
        component.set('v.studySiteId', siteId.Id);
        component.set('v.protocolId', siteId.protocolId);
    },
    checkReqFields : function (component, event, helper) {
        helper.checkFields(component,event,helper);
    },
    doClearInviteAndHide: function (component, event, helper) {
        helper.clearInviteFields(component, event, helper)
        component.find('inviteRPDialog').hide();
    },

    checkContact: function(component, event, helper){
        var email = event.getSource().get('v.value');
        if(email && communityService.isValidEmail(email)) {
            event.getSource().setCustomValidity('');
            event.getSource().reportValidity();
            component.find('modalSpinner').show();
            communityService.executeAction(component, 'checkDuplicate', {
                email: email
            }, function (returnValue) {
                if (returnValue.firstName) {
                    component.set('v.firstName', returnValue.firstName);
                    component.set('v.lastName', returnValue.lastName);
                    component.set('v.providerFound', true);
                    component.set('v.isDuplicate', returnValue.isDuplicate);
                    component.set('v.hcpContactId', returnValue.hcpContactId);
                    component.find('modalSpinner').hide();
                } else {
                    if(component.get('v.providerFound')) {
                        component.set('v.firstName', '');
                        component.set('v.lastName', '');
                    }
                    component.set('v.isDuplicate', returnValue.isDuplicate);
                    component.set('v.hcpContactId', returnValue.hcpContactId);
                    component.set('v.providerFound', false);
                    component.find('modalSpinner').hide();
                }
            });
        } else {
            if(email && !communityService.isValidEmail(email)){
                event.getSource().setCustomValidity($A.get('$Label.c.TST_Invalid_email_address'));
                event.getSource().reportValidity();
            }
        }
    },

    doSelectAll: function (component, event, helper) {
        var value = component.get('v.isSelectAllChecked');
        var val = [];
        if (value) {
            var pi = component.get('v.PIForInvetation');
            for (let i = 0; i < pi.length; i++) {
                val.push(pi[i].value);
            }
            component.set('v.checkboxGroupValues', val);
        } else {
            component.set('v.checkboxGroupValues', val);
        }
        helper.checkFields(component,event,helper);
    },

    checkSelectAll: function(component, event, helper){
        var values = component.get('v.checkboxGroupValues');
        var pi = component.get('v.PIForInvetation');
        var cmp = component.find('selectAllCheckbox');
        if(values.length == pi.length){
            if(cmp.length) cmp[0].set('v.checked', true);
            else cmp.set('v.checked', true);
        } else {
            if(cmp.length) cmp[0].set('v.checked', false);
            else cmp.set('v.checked', false);
        }
        helper.checkFields(component,event,helper);
    },
})