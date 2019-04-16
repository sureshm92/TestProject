/**
 * Created by AlexKetch on 4/16/2019.
 */
({
    handleRecordUpdated: function (component, event, helper) {
       helper.onhandleRecordUpdated(component, event, helper)
    },

    closePopUp :function (component,event,helper) {
        helper.togglePopUp(component,event,helper);
        helper.toggleToast(component,event,helper);
    },

    setupdatedDate :function (component,event,helper) {
        helper.onSetupdatedDate(component,event,helper);
    }
});