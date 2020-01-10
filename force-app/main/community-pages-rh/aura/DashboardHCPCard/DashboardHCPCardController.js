/**
 * Created by Andrii Kryvolap.
 */
({
    doAction: function (component, event, helper) {
        var item =  component.get('v.hcpe');
        var rootCmp = component.get('v.parent');
        rootCmp.find('changeHCPStatusByPIAction').execute(item.data, item.action.id, rootCmp);
    },
    doActionAll: function (component, event, helper) {
        var item =  component.get('v.hcpe');
        var rootCmp = component.get('v.parent');
        rootCmp.find('changeHCPStatusByPIAction').execute(item.data, item.action.id, rootCmp);
    }
})