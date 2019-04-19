/**
 * Created by Leonid Bartenev
 */
({
    doInit: function(component, event, helper){
        helper.updatePathSteps(component);
    },

    doProcessCollapse: function (component, event, helper) {
        var isCollapsed = component.get('v.isCollapsed');
        if(!isCollapsed){
            component.find('statusHistory').loadHistory();
        }
    }
})