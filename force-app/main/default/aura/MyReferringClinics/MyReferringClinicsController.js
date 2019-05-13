({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) return;
        if (communityService.getUserMode() !== "PI") communityService.navigateToPage('');
        component.set('v.userMode', communityService.getUserMode());
        var isFilterActive = (communityService.getUrlParameter('showPending') === 'true');
        var trialId = communityService.getUrlParameter('id');

        communityService.executeAction(component, 'getClinicDetail', {
            trialId: trialId ? trialId : '',
            userMode: component.get('v.userMode')
        }, function (returnValue) {
            var initData = JSON.parse(returnValue);
            debugger;
            component.set("v.referringClinics", initData.referringClinics);
            component.set("v.filteredReferringClinics", initData.referringClinics);
            component.set("v.summaryContainers", initData.summrayContainers);
            component.set("v.filterInfo", initData.filterInfo);
            component.set("v.showFilterByStudy", !trialId);
            helper.clearInviteFields(component, event, helper)
            component.set("v.studySitesForInvitation",initData.studySitesForInvitation);
            if (isFilterActive) {
                var filterInfo = component.get("v.filterInfo");
                filterInfo.isActive = true;
                component.set("v.filterInfo", filterInfo);
                helper.sortByPending(component, event, helper);
            }
            component.set("v.showSpinner", false);
        })
    },

    showPendingPhysicans: function (component, event, helper) {
        helper.sortByPending(component, event, helper);
    },
    doShowInviteRP: function (component, event, helper) {
        component.find('invite-rp').show();
    },
    doClearInviteAndHide: function (component, event, helper) {
        helper.clearInviteFields(component, event, helper)
        component.find('invite-rp').hide();
    },
    doInviteRP: function (component, event, helper) {
        debugger;
        var rpData = component.get('v.rpData');
        component.find('modalSpinner').show();
        communityService.executeAction(component, 'inviteHCP', {
            firstName: rpData.firstName,
            lastName: rpData.lastName,
            clinicName: rpData.clinicName,
            phone: rpData.phone,
            studySiteId: rpData.studySiteId,
        }, function (returnValue) {
            debugger;
            var initData = JSON.parse(returnValue);
            component.find('modalSpinner').hide();
            helper.clearInviteFields(component, event, helper)
            component.find('invite-rp').hide();
            communityService.showToast("success", "success",  $A.get("$Label.c.TST_Request_to_invite_a_referring_provider"));
        })

    },
    doSelectStudy: function (component, event, helper) {
        debugger;
        var siteId = event.getSource().get('v.value');
        component.set('v.rpData.studySiteId', siteId);
    },
    checkReqFields : function (component, event, helper) {
        var rpData = component.get('v.rpData');
        debugger;
        var reqFieldsFilled = rpData.firstName.trim()!=='' && rpData.lastName.trim()!=='' &&
            rpData.phone.trim()!=='' && rpData.clinicName.trim()!=='';
        component.set('v.reqFieldsFilled',reqFieldsFilled);
    }
})