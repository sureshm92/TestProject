/**
 * Created by Leonid Bartenev
 */
({
    doExecute: function (component, event) {
        var params = event.getParam('arguments');
        var study = params.study;
        var hcpeId = params.hcpeId;
        var studySiteId = params.studySiteId;
        var refreshSource = params.refreshSource;
        var mainspinner =  refreshSource.find('mainSpinner');
        mainspinner.show();
        component.set('v.study', study);
        component.set('v.refreshSource', refreshSource);

        if(studySiteId){
            //if studySiteId defined then send site request for this Study Site
            communityService.executeAction(component, 'changeStudyForHCP', {
                studySiteId: studySiteId,
                hcpeId: hcpeId
            }, function (returnValue) {
                refreshSource.refresh();
                component.find('studyChangedDialog').show();
            }, null, function () {
                mainspinner.hide();
            });
        }else{
            //if studySiteId not defined then send no site selected
            communityService.executeAction(component, 'selectNoSites', {
                hcpeId: hcpeId
            }, function (returnValue) {
                refreshSource.refresh();
                component.find('noOneStudySelectedDialog').show();
            }, null, function () {
                mainspinner.hide();
            });
        }
    },

    doCloseDialogs: function (component) {
        component.find('studyChangedDialog').hide();
        component.find('noOneStudySelectedDialog').hide();
    }

})