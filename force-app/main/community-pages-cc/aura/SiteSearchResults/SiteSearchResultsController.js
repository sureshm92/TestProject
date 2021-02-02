({
    doNavigate: function (component, event, helper) {
        let index = event.currentTarget.dataset.index;
        let filteredResultSet = component.get('v.filteredResultSet');
        let siteData =
            filteredResultSet.length > 0
                ? filteredResultSet[index]
                : component.get('v.resultSet')[index];
        //communityService.navigateToPage('study-workspace?id=' + siteData.ctpId);
        window.open('study-workspace?id=' + siteData.ctpId, '_blank');
    },
    handleStudyFilterChange: function (component, event, helper) {
        let filteredData = event.getParam('filteredData');
        if (filteredData) {
            helper.studyFilterChangeHelper(component, filteredData);
        }
    },
    handleCountryFilterChange: function (component, event, helper) {
        let filteredData = event.getParam('filteredData');
        if (filteredData) {
            helper.countryFilterChangeHelper(component, filteredData);
        }
    },
    resetFilteredResultSet: function (component, event, helper) {
        if (!component.get('v.countryFilterApplied') && !component.get('v.studyFilterApplied')) {
            let tmpFilterStudyList = component.get('v.tmpFilterStudyList');
            let tmpFilterCountryList = component.get('v.tmpFilterCountryList');
            component.set('v.filteredResultSet', []);
            component.set('v.filterStudyList', tmpFilterStudyList);
            component.set('v.filterCountryList', tmpFilterCountryList);
        }
    },

    openStudyInformation: function (component, event, helper) {
        var ssIndex = event.currentTarget.dataset.index;
        var ss = component.get('v.resultSet')[ssIndex];
        component.set('v.studyInformation', ss);
        component.set('v.onclickName', true);
        component.find('OpenStudySiteInfoAction').execute();
    }
});
