/**
 * Created by Kryvolap on 04.09.2019.
 */
({
    doRefresh: function (component, event, helper) {
        var siteDelegateLevelItems = component.find('site-level');
        if (siteDelegateLevelItems) {
            for (var i = 0; i < siteDelegateLevelItems.length; i++) {
                siteDelegateLevelItems[i].refresh();
            }
        }
    }
})