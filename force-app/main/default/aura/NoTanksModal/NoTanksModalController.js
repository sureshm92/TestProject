({
    doShow: function (component) {
        //show Popup
        component.find('noTanksModal').show();
    },

    doHide: function (component) {
        //hide Popup
        component.find('noTanksModal').hide();
    },

    doSetStudyStatus: function (component, event, helper) {

        var spinner = component.find('spinner');
        spinner.show();

        if(event.target.id !== "yes"){
            spinner.hide();
            component.find('noTanksModal').hide();
            return;
        }

        var trialId = component.get('v.trialId');
        var userMode = component.get('v.userMode');

        communityService.executeAction(component, 'deactivateTrial', {
            trialId: trialId,
            userMode: userMode
        }, function (returnValue) {
            var parent = component.get('v.parent');
            if(parent) parent.refresh();
            communityService.showToast("success", "success", $A.get("$Label.c.TST_Study_was_successfully_declined"));
        }, null, function () {
            component.find('noTanksModal').hide();
            spinner.hide();
        });
    }
})