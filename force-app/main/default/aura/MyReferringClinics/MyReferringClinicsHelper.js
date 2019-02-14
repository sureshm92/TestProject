({
    sortByPending: function (component, event, helper) {

        component.set("v.filteredReferringClinics", []);
        var isFilterActive = component.get("v.filterInfo").isActive;

        if(isFilterActive){
            var wrappers = component.get("v.referringClinics");
            var newWrappers = [];

            for(var i =0; i < wrappers.length; i++){

                var newObj = {};
                newObj.clinic = wrappers[i].clinic;
                newObj.enrollments = [];

                for(var j = 0; j < wrappers[i].enrollments.length; j++){

                    var status = wrappers[i].enrollments[j].status;
                    
                    if(status.indexOf("Pending") !== -1){

                        newObj.enrollments.push(wrappers[i].enrollments[j]);
                    }
                }

                if(newObj.enrollments.length){
                    newWrappers.push(newObj);
                }
            }

            if(newWrappers.length){
                component.set("v.filteredReferringClinics", newWrappers);
            }
        } else {
            component.set("v.filteredReferringClinics", component.get("v.referringClinics"));
        }
    }
})