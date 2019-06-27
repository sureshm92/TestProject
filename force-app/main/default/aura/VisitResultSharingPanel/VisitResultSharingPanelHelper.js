/**
 * Created by Igor Malyuta on 27.06.2019.
 */

({
    takeSnapshot: function (component) {
        return JSON.stringify(component.get('v.options'));
    },

    compareSnapshots : function (component, helper) {
        var prevSnap = component.get('v.dataSnapshot');
        var currentSnap = helper.takeSnapshot(component);

        component.set('v.dataSnapshot', currentSnap);
        return currentSnap === prevSnap;
    }
});