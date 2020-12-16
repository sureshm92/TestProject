({
    getPESH : function(component,event,helper) {
        var params = event.getParam('arguments');
        var pe = JSON.parse(JSON.stringify(params.pe));
        communityService.executeAction(
            component,
            'getPESHrecord',
            {
                peId : pe.Id
            }, function (returnValue) {
                component.set('v.dateofSH',returnValue);
            });
    },
    
})