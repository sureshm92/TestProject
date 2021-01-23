({
	doExecute : function(component, event, helper) {
        
        component.find('dialog').show();
        component.set('v.siteInfoComplete',component.get('v.studyInformation.siteInfoComplete'));
        component.set('v.trainingComplete',component.get('v.studyInformation.trainingComplete'));
        component.set('v.supressEmail',component.get('v.studyInformation.receivePIEmail'));
        var ssId = component.get('v.studyInformation').siteId;
        communityService.executeAction(
            component, 'getDelegateMap',
            {
                StudySiteId : ssId
            },
            function (returnValue) 
            {
                component.set('v.delegateList',returnValue);
            });
	},
    doCancel: function (component, event, helper) {
        var comp = component.find('dialog');
        comp.hide();
    },
     doSave: function (component, event, helper) {
          var childComponent = component.find("childCmp");
          childComponent.childMessageMethod();
    }
})