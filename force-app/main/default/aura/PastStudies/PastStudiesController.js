({
    doInit: function (component, event, helper) {
        communityService.executeAction(component, 'getPastStudyRecords', null, function (pastStudies) {
            component.set('v.pastStudiesList', pastStudies);
            component.set('v.initialized', true);
            component.find('spinner').hide();
        });
    }

});