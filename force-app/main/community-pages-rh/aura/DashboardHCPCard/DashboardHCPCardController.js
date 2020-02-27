/**
 * Created by Andrii Kryvolap.
 */
({
    doActivate: function (component, event, helper) {
        var item =  component.get('v.hcpe');
        rootCmp.find('changeHCPStatusByPIAction').execute(item.data, 'hcpActivate', component);
    },
    doActivateAll: function (component, event, helper) {
        var item =  component.get('v.hcpe');
        rootCmp.find('changeHCPStatusByPIAction').execute(item.data, 'hcpActivateForAll', component);
    },
    doActivateOrientation: function (component, event, helper) {
        var item =  component.get('v.hcpe');
        rootCmp.find('changeHCPStatusByPIAction').execute(item.data, 'hcpOrientationAttendedAndActivate', component);
    },

    doRefresh: function(component, event, helper){
    	var rootCmp = component.get('v.parent');
    	rootCmp.refresh();
    },
})