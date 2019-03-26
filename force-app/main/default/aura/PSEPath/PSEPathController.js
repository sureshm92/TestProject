/**
 * Created by Leonid Bartenev
 */
({
    doProcessCollapse: function (component, event, helper) {
        var isCollapsed = component.get('v.isCollapsed');
        if(!isCollapsed){
            component.find('statusHistory').loadHistory();
        }
    }
})