/**
 * Created by AlexKetch on 4/16/2019.
 */
({
    handleRecordUpdated: function (component, event, helper) {
       helper.onhandleRecordUpdated(component, event, helper)
    },

    closePopUp :function (component,event,helper) {
        let cmp = component.find('modalDialog');
        $A.util.toggleClass(cmp, 'slds-hide');
    },

    setupdatedDate :function (component,event,helper) {
        helper.onSetupdatedDate(component,event,helper);
    }
});