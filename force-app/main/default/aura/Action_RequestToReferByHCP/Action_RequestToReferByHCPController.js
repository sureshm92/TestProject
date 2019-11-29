/**
 * Created by Kryvolap on 26.03.2019.
 */
({
    doExecute: function (component, event) {
        debugger;
        var params = event.getParam('arguments');
        var study = params.study;
        var studySiteId = params.studySiteId;
        var hcpeId = params.hcpeId;
        var refreshSource = params.refreshSource;
        var delegateId = params.delegateId;

        var mainspinner =  refreshSource.find('mainSpinner');
        mainspinner.show();
        component.set('v.study', study);
        component.set('v.refreshSource', refreshSource);

            //if studySiteId defined then send site request for this Study Site
            communityService.executeAction(component, 'requestToReferForHCP', {
                studySiteId: studySiteId,
                hcpeId: hcpeId,
                delegateId: delegateId
            }, function (returnValue) {
                refreshSource.refresh();
                component.find('requestReferralDialog').show();
            }, null, function () {
                mainspinner.hide();
            });
    },
    doCloseDialogs: function (component) {
        component.find('requestReferralDialog').hide();
    }
})