/**
 * Created by Leonid Bartenev
 */
({
    setStudyStatus: function (component, event) {
        var trialId = component.get('v.trialId');
        var ssId = component.get('v.ssId');
        var piPaysValue;
        if(event){
            var piPaysValues = [ 'Yes', 'No', 'Unknown'];
            var btnIndex = event.target.id;
            piPaysValue = piPaysValues[btnIndex];
        }
        communityService.executeAction(component, 'setTrialAcceptedForPI', {
            trialId: trialId,
            piPaysForReferralActivity: piPaysValue,
            ssId : ssId
        }, function (returnValue) {
            var parent = component.get('v.parent');
            if(parent) parent.refresh();
        }, null, function () {
            component.find('reimbursmentModal').hide();
            component.find('spinner').hide();
        });
    }
})