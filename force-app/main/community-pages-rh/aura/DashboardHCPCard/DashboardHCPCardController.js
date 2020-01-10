/**
 * Created by Andrii Kryvolap.
 */
({
    doActivate: function (component, event, helper) {
        var item =  component.get('v.hcpe');
        var rootCmp = component.get('v.parent');
        rootCmp.find('changeHCPStatusByPIAction').execute(item.data, 'hcpActivate', rootCmp);
    },
    doActivateAll: function (component, event, helper) {
        var item =  component.get('v.hcpe');
        var rootCmp = component.get('v.parent');
        rootCmp.find('changeHCPStatusByPIAction').execute(item.data, 'hcpActivateForAll', rootCmp);
    }
})