/**
 * Created by Nargiz Mamedova on 2/14/2020.
 */

({
    updateCoi: function (component, event, helper) {
        var conditions = 'none';
        if (component.get('v.conditions')) conditions = component.get('v.conditions');
        component.set('v.coirecordIds', conditions);
    }
});
