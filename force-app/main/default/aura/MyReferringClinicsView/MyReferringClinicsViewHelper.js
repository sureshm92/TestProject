({
    getReferredClinics: function (component) {
        var action = component.get('c.getWorkspaceWrapper');
        action.setCallback(this, function (response) {

            var state = response.getState();

            if (state === "SUCCESS" && response.getReturnValue()) {

                var reffClinics = JSON.parse(response.getReturnValue());

                if (reffClinics) {

                    this.setInfo(component, reffClinics);

                    component.set("v.clinicWrappers", reffClinics);
                    this.showAllPhysicians(component);
                    component.set("v.showSpinner", false);
                } else {
                    this.showError(component);
                }
            } else {
                //todo add toast
                this.showError(component);
                console.log("ERROR-gUT: response= " + response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    showAllPhysicians: function (component) {
        component.set("v.filteredClinicWrappers", []);
        component.set("v.filteredClinicWrappers", component.get("v.clinicWrappers"));
    },
    showPendingPhysicians: function (component) {

        var wrappers = component.get("v.clinicWrappers");
        var newWrappers = [];

        for(var key in wrappers){

            var newObj = {};
            newObj.clinic = wrappers[key].clinic;
            newObj.enrollments = [];

            for(var i = 0; i < wrappers[key].enrollments.length; i++){

                var status = wrappers[key].enrollments[i].Status__c;

                if(status.indexOf("Pending") !== -1){

                    newObj.enrollments.push(wrappers[key].enrollments[i]);
                }
            }

            if(newObj.enrollments.length){

                newWrappers.push(newObj);
            }
        }

        if(newWrappers.length){

            component.set("v.filteredClinicWrappers", []);
            component.set("v.filteredClinicWrappers", newWrappers);
        }
    },
    setInfo: function (component, clinicWrappers) {

        var totalClinics = Object.keys(clinicWrappers).length;
        var activated = 0,
            pending = 0,
            deactivated = 0,
            onHold = 0,
            declined = 0;

        for(var key in clinicWrappers){

            for(var i = 0; i < clinicWrappers[key].enrollments.length; i++){

                if(clinicWrappers[key].enrollments[i].Status__c.indexOf("Activated") === 0){
                    activated++;
                } else if(clinicWrappers[key].enrollments[i].Status__c === "Clinic Deactivated for this Trial") {
                    deactivated++;
                } else if(clinicWrappers[key].enrollments[i].Status__c.indexOf("On Hold") === 0) {
                    onHold++;
                } else if(clinicWrappers[key].enrollments[i].Status__c === "Trial Declined") {
                    declined++;
                } else {
                    pending++;
                }
            }
        }

        component.set("v.totalClinics", totalClinics);
        component.set("v.physiciansActivated", activated);
        component.set("v.physiciansDeactivated", deactivated);
        component.set("v.physiciansOnHold", onHold);
        component.set("v.physiciansDeclined", declined);
        component.set("v.pendingPhysicians", pending);
        component.set("v.totalPhysicians", activated + deactivated + onHold + declined + pending);
    },
    showError: function (component) {
        console.log("Error= ");
        // component.set("v.showSpinner", false);
        // component.set("v.showError", true);
    }
})