({
    studyFilterChangeHelper: function (component, filteredData) {
        debugger;
        let filteredResultSet = component.get('v.filteredResultSet');
        let filterCountryList = component.get('v.filterCountryList');
        let countryFilterApplied = component.get('v.countryFilterApplied');
        let idsFromStudyFilter = filteredData.key;
        let idsFromCountryFilter = component.get('v.idsFromCountryFilter');
        let resultSet = component.get('v.resultSet');
        console.log('studyFilterChangeHelper' + JSON.stringify(filteredData));

        //1. Create/Modify filteredResultSet based on the filtered data
        //      1.1 if filteredResultSet contains value, it will be updated to
        //          filter1 (intersection) filter2
        if (filteredResultSet.length > 0 && countryFilterApplied) {
            if (filteredData.value) {
                filteredResultSet = filteredResultSet.filter(
                    (site) =>
                        idsFromStudyFilter.includes(site.siteId) && //filter1 (intersection)
                        idsFromCountryFilter.includes(site.siteId) //filter2
                );
            }
            //      1.2 if filteredResultSet is empty populate it based on filteredData.key
            //          from resultSet
        } else {
            if (filteredData.value) {
                filteredResultSet = resultSet.filter((site) =>
                    idsFromStudyFilter.includes(site.siteId)
                );
            }
        }
        //2. Update filterCountryList
        if (filteredData.value) {
            let updatedCountries = filteredResultSet.map((site) => site.siteCountry);
            filterCountryList = filterCountryList.filter((country) =>
                updatedCountries.includes(country.value)
            );
            component.set('v.filterCountryList', filterCountryList);
        }
        component.set('v.idsFromStudyFilter', idsFromStudyFilter);
        component.set('v.filteredResultSet', filteredResultSet);
        //Invokes change handler
        component.set('v.studyFilterApplied', filteredData.value === '' ? false : true);
    },

    countryFilterChangeHelper: function (component, filteredData) {
        debugger;
        let filteredResultSet = component.get('v.filteredResultSet');
        let filterStudyList = component.get('v.filterStudyList');
        let studyFilterApplied = component.get('v.studyFilterApplied');
        let idsFromCountryFilter = filteredData.key;
        let idsFromStudyFilter = component.get('v.idsFromStudyFilter');
        let resultSet = component.get('v.resultSet');
        console.log('countryFilterChangeHelper' + JSON.stringify(filteredData));

        //1. Create/Modify filteredResultSet based on the filtered data
        //      1.1 if filteredResultSet is empty populate it based on filteredData.key
        //          from resultSet
        if (filteredResultSet.length > 0 && studyFilterApplied) {
            if (filteredData.value) {
                filteredResultSet = filteredResultSet.filter(
                    (site) =>
                        idsFromStudyFilter.includes(site.siteId) && //filter1 (intersection)
                        idsFromCountryFilter.includes(site.siteId) //filter2
                );
            }
            //      1.2 if filteredResultSet contains value, it will be updated to
            //          filter1 (intersection) filter2
        } else {
            if (filteredData.value) {
                filteredResultSet = resultSet.filter((site) =>
                    idsFromCountryFilter.includes(site.siteId)
                );
            }
        }
        //2. Update filterStudyList
        if (filteredData.value) {
            let updatedStudies = filteredResultSet.map((site) => site.studyName);
            filterStudyList = filterStudyList.filter((study) =>
                updatedStudies.includes(study.value)
            );
            component.set('v.filterStudyList', filterStudyList);
        }
        component.set('v.idsFromCountryFilter', idsFromCountryFilter);
        component.set('v.filteredResultSet', filteredResultSet);
        //Invokes change handler
        component.set('v.countryFilterApplied', filteredData.value === '' ? false : true);
    }
});
