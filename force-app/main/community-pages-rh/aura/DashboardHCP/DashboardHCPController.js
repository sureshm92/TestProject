/**
 * Created by Leonid Bartenev
 */
({
    doReferParticipant: function (component, event, helper) {
        var peId = event.currentTarget.dataset.peId;
        var trialId =  event.currentTarget.dataset.trialId;
        communityService.navigateToPage('referring?id=' + trialId + '&peid=' + peId);
    }
})