({

    doSaveChanges: function (component, event, helper) {
        var delegate = component.get('v.delegate');
        var parentComponent = component.get('v.parentComponent');
        component.get('v.parentComponent').find('saveDelegateLevelChanges').execute(delegate, parentComponent,false);
    },

    doRefresh: function (component, event, helper) {
        component.set('v.changedLevels',[]);
    }
})