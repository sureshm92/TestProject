/**
 * Created by RAMukhamadeev on 2019-03-27.
 */

({
    searchForRecords: function (cmp) {
        console.log('in doUpdateRecords');
        if (cmp.get('v.skipUpdate') === true || cmp.get('v.isInitialized') === false) {
            return;
        }

        let spinner = cmp.find('recordsSpinner');
        spinner.show();
        let filter = cmp.get('v.filterData');
        let searchText = filter.searchText;
        let filterJSON = JSON.stringify(filter);
        let paginationJSON = JSON.stringify(cmp.get('v.paginationData'));
        let sortJSON = JSON.stringify(cmp.get('v.sortData'));
        let isSearch = cmp.get('v.isSearchResume');

        communityService.executeAction(cmp, 'searchStudies', {
            filterData: filterJSON,
            sortData: sortJSON,
            paginationData: paginationJSON,
            isSearchResume: isSearch
        }, function (returnValue) {
            if (cmp.get('v.filterData').searchText !== searchText) return;
            console.log('in searchStudies callback');

            let result = JSON.parse(returnValue);
            console.log('result pagination data: ' + JSON.stringify(result.paginationData));

            cmp.set('v.skipUpdate', true);
            cmp.set('v.currentPageList', result.records);

            let pagination = cmp.get('v.paginationData');
            pagination.allRecordsCount = result.paginationData.allRecordsCount;
            pagination.currentPage = result.paginationData.currentPage;
            cmp.set('v.paginationData', pagination);

            cmp.set('v.skipUpdate', false);
            spinner.hide();
        })
    }
});