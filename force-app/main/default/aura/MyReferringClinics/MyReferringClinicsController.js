({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) return;
        if (communityService.getUserMode() !== "PI") communityService.navigateToPage('');
        component.set('v.userMode', communityService.getUserMode());
       // var isFilterActive = (communityService.getUrlParameter('showPending') === 'true');
        var trialId = communityService.getUrlParameter('id');
        var ssId = communityService.getUrlParameter('ssId');
        communityService.executeAction(component, 'getClinicDetail', {
            trialId: trialId ? trialId : null,
            userMode: component.get('v.userMode'),
            ssId : ssId ? ssId : null,
            studyWasChanged: component.get('v.studyWasChanged')
        }, function (returnValue) {
            var initData = JSON.parse(returnValue);
            console.log('FILTER DATA>>',initData);
            component.set("v.referringClinics", initData.referringClinics);
            component.set("v.filteredReferringClinics", initData.referringClinics);
            component.set("v.summaryContainers", initData.summrayContainers);
            component.set("v.filterInfo", initData.filterInfo);
            component.set('v.studySitePickList',initData.studySitePickList);
            component.set('v.studyPickList',initData.studyPickList);
            component.set('v.trialId',initData.trialId);
            component.set('v.ssId',initData.ssId);
            helper.clearInviteFields(component, event, helper);
            component.set("v.studySitesForInvitation",initData.studySitesForInvitation);
            /*if (isFilterActive) {
                var filterInfo = component.get("v.filterInfo");
                filterInfo.isActive = true;
                component.set("v.filterInfo", filterInfo);
                helper.sortByPending(component, event, helper);
            }*/
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
        var rpData = component.get('v.rpData');
        component.find('modalSpinner').show();
        communityService.executeAction(component, 'inviteHCP', {
            firstName: rpData.firstName,
            lastName: rpData.lastName,
            clinicName: rpData.clinicName,
            phone: rpData.phone,
            studySiteId: rpData.studySiteId,
            protocolId: rpData.protocolId,
        }, function (returnValue) {
            var initData = JSON.parse(returnValue);
            component.find('modalSpinner').hide();
            helper.clearInviteFields(component, event, helper)
            component.find('invite-rp').hide();
            communityService.showToast("success", "success",  $A.get("$Label.c.TST_Request_to_invite_a_referring_provider"));
        })

    },
    doSelectStudy: function (component, event, helper) {
        var siteId = event.getSource().get('v.value');
        component.set('v.rpData.studySiteId', siteId.Id);
        component.set('v.rpData.protocolId', siteId.protocolId);
    },
    checkReqFields : function (component, event, helper) {
        var rpData = component.get('v.rpData');
        var inputPattern = new RegExp('[!+@#$%^&*(),.?":{}|<>]','g');
        var phonePattern = new RegExp('[!@#$%^&*,.?":{}|<>]','g');
        var reqFieldsFilled = (inputPattern.test(rpData.firstName) || !rpData.firstName.trim()) ||
                              (inputPattern.test(rpData.lastName) || !rpData.lastName.trim()) ||
                              (phonePattern.test(rpData.phone) || !rpData.phone.trim()) ||
                              (inputPattern.test(rpData.clinicName) || !rpData.clinicName.trim());
        component.set('v.reqFieldsFilled',reqFieldsFilled);
    },

    filterData: function(component,event,helper){
        if(component.get('v.filterWasChanged')) {
            component.set("v.showSpinner", true);
            var trialId = component.get('v.trialId');
            var ssId = component.get('v.ssId');
            communityService.executeAction(component, 'getClinicDetail', {
                trialId: trialId ? trialId : null,
                userMode: component.get('v.userMode'),
                ssId: ssId ? ssId : null,
                studyWasChanged: component.get('v.studyWasChanged')
            }, function (returnValue) {
                var initData = JSON.parse(returnValue);
                component.set('v.studySitePickList', initData.studySitePickList);
                component.set('v.studyPickList', initData.studyPickList);
                component.set("v.referringClinics", initData.referringClinics);
                component.set("v.filteredReferringClinics", initData.referringClinics);
                component.set("v.summaryContainers", initData.summrayContainers);
                component.set("v.filterInfo", initData.filterInfo);
                component.set('v.trialId', initData.trialId);
                component.set('v.ssId', initData.ssId);
                component.set('v.filterWasChanged', false);
                component.set('v.studyWasChanged', false);
                helper.clearInviteFields(component, event, helper)
                component.set("v.studySitesForInvitation", initData.studySitesForInvitation);
                component.set("v.showSpinner", false);
            })
        }
    },
})