/**
 * Created by Alexey Moseev.
 */
({
    doAllViewWaitingContact: function (component, event, helper) {

    },

    refreshData: function(component, event, helper){
        component.set('v.piData.selectedPi',component.get('v.currentPi'));
    	component.get('v.parent').refresh();
    },
})