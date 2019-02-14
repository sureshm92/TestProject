({
    doInit: function (component, event, helper) {
        helper.setFilterOptions(component);
        helper.setFilters(component);
    },
    onFilterStatusChange: function (component, event, helper) {
        helper.resetFilters(component);
        helper.setFilters(component);
    },
    onSortByChange: function (component, event, helper) {
        helper.setSortFilter(component);
    },
    doSearch: function (component, event, helper) {

        helper.setFilters(component);
        var text = component.get("v.searchText");

        if(!text){
            return;
        }

        var clinics = component.get("v.allObjects");
        var filteredClinics = [];
        var searchTxt = text.toLowerCase();

        for (var i = 0; i < clinics.length; i++) {

            if (clinics[i].clinic.Name.toLowerCase().indexOf(searchTxt) !== -1) {
                filteredClinics.push(clinics[i]);
            }
        }

        component.set("v.allObjects", filteredClinics);
    }
})