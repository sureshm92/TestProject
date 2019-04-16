/**
 * Created by RAMukhamadeev on 2019-03-27.
 */

({
    searchForRecords: function (cmp, helper, fromFirstPage) {
        console.log('in doUpdateRecords');
        if (cmp.get('v.skipUpdate') === true || cmp.get('v.isInitialized') === false) {
            return;
        }

        let spinner = cmp.find('recordsSpinner');
        spinner.show();
        let filter = cmp.get('v.filterData');
        if (cmp.get("v.searchResumeChanged") === true) {
            filter.searchText = '';
            filter.therapeuticArea = 'ALL';
        }
        let searchText = filter.searchText;

        let paginationData = cmp.get('v.paginationData');
        if (fromFirstPage === true) {
            paginationData.currentPage = 1;
        }

        let filterJSON = JSON.stringify(filter);
        let paginationJSON = JSON.stringify(paginationData);
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

            cmp.set('v.skipUpdate', true);
            helper.prepareIcons(result.records);
            cmp.set('v.currentPageList', result.records);
            let pagination = cmp.get('v.paginationData');
            pagination.allRecordsCount = result.paginationData.allRecordsCount;
            pagination.currentPageCount = result.paginationData.currentPageCount;
            pagination.currentPage = result.paginationData.currentPage;
            cmp.set('v.paginationData', pagination);

            if (cmp.get("v.searchResumeChanged") === true) {
                let newFilterData = filter;
                newFilterData.therapeuticAreas = result.therapeuticAreas;
                cmp.set('v.filterData', newFilterData);
                cmp.set("v.searchResumeChanged", false);
            }

            setTimeout($A.getCallback(function () {
                helper.doUpdateStudyTitle(cmp);
            }), 10);
            cmp.set('v.skipUpdate', false);
            spinner.hide();
        })
    },
    prepareIcons: function (currentPageList) {
        debugger;
        var iconMap = {
            'Actively Enrolling': 'success',
            'On Hold': 'icon-pause-circle',
            'Enrollment Closed': 'icon-close-circle',
            'No Longer Enrolling': 'icon-close-circle'
        };
        var styleMap = {
            'Actively Enrolling': 'green-icon',
            'On Hold': 'orange-icon',
            'Enrollment Closed': 'orange-icon',
            'No Longer Enrolling': 'red-icon'
        };
        for (var i = 0; i < currentPageList.length; i++) {
            currentPageList[i].trial.statusIcon = iconMap[currentPageList[i].trial.Override_Recruitment_Status__c];
            currentPageList[i].trial.iconStyle = styleMap[currentPageList[i].trial.Override_Recruitment_Status__c];
        }
    },
    doUpdateStudyTitle: function (component) {
        if (component.isValid()) {
            var studyTitles = document.getElementsByClassName("study-title");
            for (var i = 0; i < studyTitles.length; i++) {
                var studyTitle = studyTitles.item(i);
                if (studyTitle != null) {
                    if (window.innerWidth < 768) {
                        $clamp(studyTitle, {clamp: 3});
                    } else {
                        $clamp(studyTitle, {clamp: 1});
                    }
                }
            }

        }
    },
    doUpdateStudyDescription: function (component) {
        if (component.isValid()) {
            var studyDescriptions = document.getElementsByClassName("slvi-objective-section");
            for (var i = 0; i < studyDescriptions.length; i++) {
                var studyDescription = studyDescriptions.item(i);
                if (studyDescription != null) {
                    if (window.innerWidth < 768) {
                        $clamp(studyDescription.firstChild, {
                            clamp: 3,
                            truncationHTML: studyDescription.lastElementChild.innerHTML
                        });
                    } else {
                        $clamp(studyDescription.firstChild, {
                            clamp: 1,
                            truncationHTML: studyDescription.lastElementChild.innerHTML
                        });
                    }
                }
            }

        }
    },
});