({
    doInit: function (component, event, helper) {
        helper.prepopulateDate(component, component.get("v.prepopulateDate"));
    },
    handleChange: function (component, event, helper) {

        var inputDate = new Date(component.find("dataField").get("v.value"));
        var selectedDate = new Date(inputDate.getFullYear(), inputDate.getMonth(), inputDate.getDate());
        var now = new Date();
        var today = new Date(now.getFullYear(), now.getMonth(), now.getDate());

        if(selectedDate > today){
            helper.prepopulateDate(component, true);
            component.set("v.errorMessage", "You can not fill date for the future!");
        } else {
            component.set("v.errorMessage", "");
        }
    }
})