/**
 * Created by Leonid Bartenev
 */
({
    doAction: function (component, event, helper) {
        var item =  helper.getItem(component, event.currentTarget.dataset.hcpeId);
        if(item) {
            var rootCmp = component.get('v.parent');
            rootCmp.find('changeHCPStatusByPIAction').execute(item.data, item.action.id, rootCmp);
        }
    }
})