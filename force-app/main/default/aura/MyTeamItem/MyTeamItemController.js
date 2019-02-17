({

    doSaveChanges: function (component, event, helper) {
        var delegate = component.get('v.delegate');
        component.get('v.parentComponent').find('saveDelegateLevelChanges').execute(delegate, component,false);
    },

    doRefresh: function (component, event, helper) {
        component.set('v.changedLevels',[]);
        component.set('v.refreshSDLITrigger', !component.get('v.refreshSDLITrigger'));
    },
})