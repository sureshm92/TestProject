/**
 * Created by Andrii Kryvolap.
 */

({
    doUpdateRecords: function (component, event, helper, changedItem) {
        if (component.get('v.skipUpdate')) return;
        var spinner = component.find('recordsSpinner');
        spinner.show();
        var filter = component.get('v.peFilter');
        var searchText = filter.searchText;
        for (var key in filter) {
            if (key != 'searchText' && filter[key] == '') {
                filter[key] = null;
            }
        }
        var filterJSON = JSON.stringify(filter);
        var paginationJSON = JSON.stringify(component.get('v.paginationData'));

        communityService.executeAction(component, 'getRecords', {
            filterJSON: filterJSON,
            paginationJSON: paginationJSON,
            userMode: communityService.getUserMode(),
            changedItem: changedItem,
            delegateId: communityService.getDelegateId(),
            emancipatedPE: component.get('v.showEmancipatedOnly')
        }, function (returnValue) {
            if (component.get('v.peFilter').searchText !== searchText) return;
            var result = JSON.parse(returnValue);
            component.set('v.skipUpdate', true);
            component.set('v.pageList', result.peList);
            component.set('v.peFilter', result.peFilter);
            component.set('v.peFilterData', result.peFilterData);
            component.set('v.paginationData.allRecordsCount', result.paginationData.allRecordsCount);
            component.set('v.paginationData.currentPage', result.paginationData.currentPage);
            component.set('v.paginationData.currentPageCount', result.paginationData.currentPageCount);
            component.set('v.skipUpdate', false);
            /*if (communityService.getUserMode() != 'Participant' && result.peList) {
                for (let pItem in result.peList) {
                    var hasEmancipatedParticipants = false;
                    if (result.peList[pItem].hasEmancipatedParticipants) {
                        hasEmancipatedParticipants = true;
                        break;
                    }
                }
                component.set('v.hasEmancipatedParticipants', hasEmancipatedParticipants);
                component.getEvent('onInit').fire();
            }*/
            spinner.hide();
        })
    },
});