/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        if(!communityService.isInitialized()) return;
        var ctpId = communityService.getUrlParameter('id');
        communityService.executeAction(component, 'getInitData', {
            ctpId: ctpId
        }, function (formData) {
            component.set('v.ctp', formData.ctp);
            component.set('v.formData', formData);
            helper.initData(component);
            component.set('v.initialized', true);
            window.setTimeout(
                $A.getCallback(function() {
                    component.find('editForm').set('v.handleChangesEnabled', true);
                }), 100
            );
        }, null, function () {
            component.find('spinner').hide();
        });
    },

    doCancel: function (component) {
        communityService.navigateToPage('study-workspace?tab=tab-referrals&id=' + component.get('v.ctp.Id'))
    },

    doSaveAndExit: function (component, event, helper) {
        helper.createParticipant(component, function () {
            communityService.navigateToPage('study-workspace?tab=tab-referrals&id=' + component.get('v.ctp.Id'))
        })
    },

    doSaveAndNew: function (component, event, helper) {
        helper.createParticipant(component, function () {
            helper.initData(component);
        })
    }
})