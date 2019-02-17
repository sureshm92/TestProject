({
    doInit: function (component, event, helper) {
        helper.setFilterOptions(component);
        helper.setLabels(component);
        helper.setFilters(component);
        component.set("v.isInitialized", true);
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
        var userMode = component.get("v.userMode");

        if(!text){
            return;
        }

        var wrappers = component.get("v.allObjects");
        var filteredWrappers = [];
        var searchTxt = text.toLowerCase();

        for (var i = 0; i < wrappers.length; i++) {

            var searchString;
            searchString = wrappers[i][helper.headerObjectName].Name;

            if (searchString.toLowerCase().indexOf(searchTxt) !== -1) {
                filteredWrappers.push(wrappers[i]);
            }
        }

        component.set("v.allObjects", filteredWrappers);
    }
})