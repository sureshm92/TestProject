/**
 * Created by Alexey Moseev.
 */
({
    doAllViewWaitingContact: function (component, event, helper) {

    },

    refreshData: function(component, event, helper){
        var piData = component.get('v.piData');
        piData.selectedPi = component.get('v.currentPi');
        component.set('v.piData',piData);
    	component.get('v.parent').refresh();
    },

    doinit:function(component, event, helper){
    	var piData = component.get('v.piData');
    	component.set('v.delegatePIPicklistvalues',piData.delegatePIsPicklist);
    	component.set('v.currentPi', piData.selectedPi);
    },
})