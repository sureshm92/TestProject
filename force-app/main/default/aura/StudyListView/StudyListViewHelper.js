/**
 * Created by RAMukhamadeev on 2019-03-27.
 */

({
    searchForRecords: function (cmp, helper) {
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
            helper.prepareIcons(result.records);
            cmp.set('v.currentPageList', result.records);

            let pagination = cmp.get('v.paginationData');
            pagination.allRecordsCount = result.paginationData.allRecordsCount;
            pagination.currentPage = result.paginationData.currentPage;
            cmp.set('v.paginationData', pagination);

            cmp.set('v.skipUpdate', false);
            spinner.hide();
        })
    },
    prepareIcons: function (currentPageList) {
        debugger;
        var iconMap = {
            'Actively Enrolling': 'success',
            'On hold': 'icon-pause-circle',
            'Enrollment closed': 'icon-close-circle',
            'No longer enrolling': 'icon-close-circle'
        };
        var styleMap = {
            'Actively Enrolling': 'green-icon',
            'On hold': 'orange-icon',
            'Enrollment closed': 'orange-icon',
            'No longer enrolling': 'red-icon'
        };
        for(var i = 0; i < currentPageList.length; i++){
            currentPageList[i].trial.statusIcon = iconMap[currentPageList[i].trial.Override_Recruitment_Status__c];
            currentPageList[i].trial.iconStyle = styleMap[currentPageList[i].trial.Override_Recruitment_Status__c];
        }
    },
    doUpdateStudyTitle: function (component) {
        debugger;
        if(component.isValid()) {
            var studyTitles = document.getElementsByClassName("study-title");
            for(var i =0; i< studyTitles.length; i++){
                var studyTitle = studyTitles.item(i);
                if(studyTitle != null ){
                    if(window.innerWidth < 768){
                        $clamp(studyTitle,{clamp: 3});
                    }
                    else{
                        $clamp(studyTitle,{clamp: 1});
                    }
                }
            }

        }
    },
    doUpdateStudyDescription: function (component) {
        debugger;
        if(component.isValid()) {
            var studyDescriptions = document.getElementsByClassName("slvi-objective-section");
            for(var i =0; i< studyDescriptions.length; i++){
                var studyDescription = studyDescriptions.item(i);
                if(studyDescription != null ){
                    if(window.innerWidth < 768){
                        $clamp(studyDescription.firstChild,{clamp: 3, truncationHTML : studyDescription.lastElementChild.innerHTML});
                    }
                    else{
                        $clamp(studyDescription.firstChild,{clamp: 1, truncationHTML : studyDescription.lastElementChild.innerHTML});
                    }
                }
            }

        }
    },
});