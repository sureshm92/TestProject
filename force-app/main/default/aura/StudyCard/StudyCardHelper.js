/**
 * Created by Nikita Abrazhevitch on 21-Aug-19.
 */

({
    onEmailClick: function (component) {
        let currentStudy = component.get('v.currentStudy');
        var parent = component.get('v.parent');
        parent.find('emailModal').show(currentStudy.trial.Id);
    },

    onFacebookClick: function (component, url, text) {
        window.open(
            'https://www.facebook.com/sharer/sharer.php?u=' +
                encodeURIComponent(url) +
                '&quote=' +
                text
        );
    },

    onTwitterClick: function (component, url, text) {
        window.open(
            'https://twitter.com/intent/tweet?text=' + text + '&url=' + encodeURIComponent(url)
        );
    },

    onLinkedInClick: function (component, url) {
        window.open(
            'https://www.linkedin.com/shareArticle?mini=true&url=' + encodeURIComponent(url)
        );
    },

    checkIsMrrAvaiable: function(component, event, helper) {
        var action = component.get("c.isMrrAvaiable");
        var currentStudy = component.get('v.currentStudy');
        var trialId = currentStudy.trial.Id;
        action.setParams({ ctpId :trialId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(!response.getReturnValue()){
                    component.set('v.disableMRR',true);
                }
            }
        });
        $A.enqueueAction(action);
    }
});