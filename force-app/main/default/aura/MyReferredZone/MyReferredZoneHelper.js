({
    headerObjectName: "",

    entriesOptions: [
        {"label": "5", "value": "5"},
        {"label": "10", "value": "10"},
        {"label": "25", "value": "25"},
        {"label": "50", "value": "50"}
    ],
    enrollmentStatusOptions: [],
    studiesStatusOption: [],
    setFilterOptions: function (component) {
        var sortOptions = [
            {"label": $A.get("$Label.c.PG_MRZ_L_Last_Added"), "value": "last-added"},
            {"label": $A.get("$Label.c.PG_MRZ_L_Last_Modified"), "value": "last-modified"},
            {"label": $A.get("$Label.c.PG_MRZ_L_Alphabetical_A_Z"), "value": "a-z"},
            {"label": $A.get("$Label.c.PG_MRZ_L_Alphabetical_Z_A"), "value": "z-a"}
        ];
        this.setStatusOptions(component);
        component.set("v.sortOptions", sortOptions);
        component.set("v.entriesOptions", this.entriesOptions);
    },
    setStatusOptions: function (component) {

        var userMode = component.get("v.userMode");
        var action = component.get('c.getStatusOptions');
        action.setParams({
            userMode: userMode
        });
        action.setCallback(this, function (response) {

            if (response.getState() === "SUCCESS" && response.getReturnValue()) {

                var filterStatusOptions = JSON.parse(response.getReturnValue());

                this.enrollmentStatusOptions = filterStatusOptions['HCP_Enrollment__c'];
                this.studiesStatusOption = filterStatusOptions['Study_Site__c'];

                // for (var key in filterStatusOptions) {
                //
                //     var optionMap = {};
                //     for (var i = 0; i < filterStatusOptions[key].length; i++) {
                //         optionMap[filterStatusOptions[key][i].split(' (')[0]] = filterStatusOptions[key][i];
                //     }
                //
                //     for (var jkey in optionMap) {
                //         var opt = {};
                //         opt.label = jkey;
                //         opt.value = jkey;
                //
                //         if (key === "HCP_Enrollment__c") {
                //             this.enrollmentStatusOptions.push(opt);
                //         } else if (key === "Study_Site__c") {
                //             this.studiesStatusOption.push(opt);
                //         }
                //     }
                // }

                if (userMode === "HCP") {
                    component.set("v.statusOptions", this.enrollmentStatusOptions);
                    //todo secondary status
                } else if (userMode === "PI") {
                    // component.set("v.statusOptions", this.studiesStatusOption);
                    //todo secondary status
                    component.set("v.statusOptions", this.enrollmentStatusOptions);
                }
            } else {
                communityService.logErrorFromResponse(response);
            }
        });
        $A.enqueueAction(action);
    },
    setLabels: function (component) {

        if (communityService.getUserMode() === "HCP") {
            component.set("v.statusFilterPlaceholder", $A.get("$Label.c.PG_MRZ_L_Provider_Status"));
            component.set("v.searchTextPlaceholder", $A.get("$Label.c.PG_MRZ_L_Search_for_a_study_site"));
            component.set("v.objectLabel", "referring study sites");
            this.headerObjectName = "studySite";
        } else if (communityService.getUserMode() === "PI") {
            component.set("v.statusFilterPlaceholder", $A.get("$Label.c.PG_MRZ_L_Provider_Status"));
            component.set("v.searchTextPlaceholder", $A.get("$Label.c.PG_MRZ_L_Search_for_a_referring_clinic"));
            component.set("v.objectLabel", "referring clinics");
            this.headerObjectName = "clinic";
        }
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
        debugger;
        var wrappers = component.get("v.workspaceWrapper");
        var status = component.get("v.statusFilter");
        var filteredWrappers = [];
        var addWrapper = false;

        if (!status) {
            component.set("v.allObjects", wrappers);
            return;
        }

        for (var i = 0; i < wrappers.length; i++) {

            var newWrapper = {};
            newWrapper[this.headerObjectName] = wrappers[i][this.headerObjectName];
            newWrapper.enrollments = [];

            for (var j = 0; j < wrappers[i].enrollments.length; j++) {

                if (wrappers[i].enrollments[j].enrollment.Status__c === status) {
                    addWrapper = true;
                    newWrapper.enrollments.push(wrappers[i].enrollments[j]);
                }
            }

            if (addWrapper) {
                filteredWrappers.push(newWrapper);
                addWrapper = false;
            }
        }
        component.set("v.allObjects", filteredWrappers);
    },
    setSortFilter: function (component) {

        var sortBy = component.get("v.sortBy");
        if (!sortBy) return;
        var wrappers = component.get("v.allObjects");
        var userMode = component.get("v.userMode");

        if (sortBy === "a-z" || sortBy === "z-a") {
            //sort by headerObject name
            var headerObjectName = this.headerObjectName;
            switch (sortBy) {
                case "a-z":
                    wrappers.sort(function (valA, valB) {
                        var stringA, stringB;
                        stringA = valA[headerObjectName].Name;
                        stringB = valB[headerObjectName].Name;
                        var firstVal = stringA.toLowerCase();
                        var secondVal = stringB.toLowerCase();
                        return firstVal < secondVal ? -1 : firstVal > secondVal ? 1 : 0;
                    });
                    break;
                case "z-a":
                    wrappers.sort(function (valA, valB) {
                        var stringA, stringB;
                        stringA = valA[headerObjectName].Name;
                        stringB = valB[headerObjectName].Name;
                        var firstVal = stringA.toLowerCase();
                        var secondVal = stringB.toLowerCase();
                        return firstVal > secondVal ? -1 : firstVal < secondVal ? 1 : 0;
                    });
                    break;
            }
        } else {
            //enrolments sort
            for (var i = 0; i < wrappers.length; i++) {

                if (!wrappers[i].enrollments.length) continue;

                switch (sortBy) {
                    case "last-modified":
                        wrappers[i].enrollments.sort($A.getCallback(function (dateA, dateB) {
                            var firstVal = new Date(dateA.enrollment.LastModifiedDate);
                            var secondVal = new Date(dateB.enrollment.LastModifiedDate);
                            return firstVal > secondVal ? -1 : firstVal < secondVal ? 1 : 0;
                        }));
                        break;
                    case "last-added":
                    default:
                        wrappers[i].enrollments.sort($A.getCallback(function (dateA, dateB) {
                            var firstVal = new Date(dateA.enrollment.CreatedDate);
                            var secondVal = new Date(dateB.enrollment.CreatedDate);
                            return firstVal > secondVal ? -1 : firstVal < secondVal ? 1 : 0;
                        }));
                }
            }
        }
        component.set("v.allObjects", []);
        component.set("v.allObjects", wrappers);
    }
})