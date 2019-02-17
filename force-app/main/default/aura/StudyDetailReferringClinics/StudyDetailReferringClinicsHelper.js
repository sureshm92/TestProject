({

    setFilterOptions: function (component) {
        var sortOptions = [
            {"label": $A.get("$Label.c.PG_MRZ_L_Last_Added"), "value": "last-added"},
            {"label": $A.get("$Label.c.PG_MRZ_L_Last_Modified"), "value": "last-modified"},
            {"label": $A.get("$Label.c.PG_MRZ_L_Alphabetical_A_Z"), "value": "a-z"},
            {"label": $A.get("$Label.c.PG_MRZ_L_Alphabetical_Z_A"), "value": "z-a"}
        ];
        var entriesOptions = [
            {"label": "10", "value": "10"},
            {"label": "25", "value": "25"},
            {"label": "50", "value": "50"},
            {"label": "100", "value": "100"},
            {"label": "1", "value": "1"},
            {"label": $A.get("$Label.c.PG_SDRC_L_All"), "value": "0"}
        ];
        this.setStatusOptions(component);
        component.set("v.sortOptions", sortOptions);
        component.set("v.entriesOptions", entriesOptions);
    },
    setStatusOptions: function (component) {
        var optionList = [];
        var action = component.get('c.getStatusOptions');
        action.setCallback(this, function (response) {

            var state = response.getState();


            if (state === "SUCCESS" && response.getReturnValue()) {

                var options = JSON.parse(response.getReturnValue());
                var optionMap = {};

                for (var i = 0; i < options.length; i++) {
                    optionMap[options[i].split(' (')[0]] = options[i];
                }

                for (var key in optionMap) {
                    var opt = {};
                    opt.label = key;
                    opt.value = key;
                    optionList.push(opt);
                }

                component.set("v.statusOptions", optionList);
            } else {
                console.log("ERROR-gSO: response= " + response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    setFilters: function (component) {
        this.setStatusFilter(component);
        this.setSortFilter(component);
    },
    resetFilters: function (component) {
        component.set("v.searchText", '');
        component.set("v.sortBy", '');
    },
    setStatusFilter: function (component) {

        var clinics = component.get("v.clinicWrappers");
        var status = component.get("v.statusFilter");
        var filteredClinics = [];
        var addClinic = false;

        if (!status) {
            component.set("v.allObjects", clinics);
            return;
        }

        for (var i = 0; i < clinics.length; i++) {

            var newClinic = {};
            newClinic.clinic = clinics[i].clinic;
            newClinic.enrollments = [];

            for (var j = 0; j < clinics[i].enrollments.length; j++) {

                if (clinics[i].enrollments[j].Status__c.split(' (')[0] === status) {

                    addClinic = true;
                    newClinic.enrollments.push(clinics[i].enrollments[j]);
                }
            }

            if (addClinic) {
                filteredClinics.push(newClinic);
                addClinic = false;
            }
        }
        component.set("v.allObjects", filteredClinics);
    },
    setSortFilter: function (component) {

        var clinics = component.get("v.allObjects");
        var sortBy = component.get("v.sortBy");

        if (!sortBy) return;

        if (sortBy === "a-z" || sortBy === "z-a") {
            //sort by clinic name
            switch (sortBy) {
                case "a-z":
                    clinics.sort(function (valA, valB) {

                        var firstVal = valA.clinic.Name.toLowerCase();
                        var secondVal = valB.clinic.Name.toLowerCase();

                        return firstVal < secondVal ? -1 : firstVal > secondVal ? 1 : 0;
                    });
                    break;
                case "z-a":
                    clinics.sort(function (valA, valB) {

                        var firstVal = valA.clinic.Name.toLowerCase();
                        var secondVal = valB.clinic.Name.toLowerCase();

                        return firstVal > secondVal ? -1 : firstVal < secondVal ? 1 : 0;
                    });
                    break;
            }
        } else {
            //enrolments sort
            for (var i = 0; i < clinics.length; i++) {

                if (!clinics[i].enrollments.length) continue;

                switch (sortBy) {
                    case "last-modified":
                        clinics[i].enrollments.sort(function (dateA, dateB) {

                            var firstVal = new Date(dateA.LastModifiedDate);
                            var secondVal = new Date(dateB.LastModifiedDate);

                            return firstVal > secondVal ? -1 : firstVal < secondVal ? 1 : 0;
                        });
                        break;
                    case "last-added":
                    default:
                        clinics[i].enrollments.sort(function (dateA, dateB) {

                            var firstVal = new Date(dateA.CreatedDate);
                            var secondVal = new Date(dateB.CreatedDate);

                            return firstVal > secondVal ? -1 : firstVal < secondVal ? 1 : 0;
                        });
                }
            }
        }
        component.set("v.allObjects", clinics);
    }
})