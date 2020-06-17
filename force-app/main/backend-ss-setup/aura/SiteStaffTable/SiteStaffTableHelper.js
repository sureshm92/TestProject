({
    doInit: function (component, event, helper) {
        component.find('spinner').show();
        communityService.executeAction(component, 'getInitData', {
            ssId: component.get('v.recordId')
        }, function (initData) {
            component.set('v.initData', initData);
            component.find('spinner').hide();
        });
    },
});