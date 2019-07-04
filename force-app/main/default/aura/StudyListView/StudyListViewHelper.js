/**
 * Created by RAMukhamadeev on 2019-03-27.
 */

({
    init: function (component, event, helper) {
        if (!communityService.isInitialized()) return;
        component.set("v.showSpinner", true);
        let userMode = communityService.getUserMode();
        component.set('v.userMode', userMode);

        if (userMode === 'HCP') {
            window.addEventListener('resize', $A.getCallback(function () {
                helper.doUpdateStudyTitle(component);
                // helper.doUpdateStudyDescription(component);
            }));
            communityService.executeAction(component, 'getHCPInitData', null, function (returnValue) {
                let initData = JSON.parse(returnValue);
                component.set("v.paginationData", initData.paginationData);
                component.set("v.filterData", initData.filterData);
                component.set("v.sortData", initData.sortData);
                component.set("v.accessUserLevel", initData.delegateAccessLevel);
                helper.prepareIcons(initData.currentPageList);
                component.set("v.currentPageList", initData.currentPageList);
                component.set("v.showSpinner", false);
                component.set('v.isInitialized', true);
                setTimeout($A.getCallback(function () {
                    helper.doUpdateStudyTitle(component);
                    // helper.doUpdateStudyDescription(component);
                }), 10);
            });
        } else {
            window.addEventListener('resize', $A.getCallback(function () {
                helper.doUpdateStudyTitle(component);
                // helper.doUpdateStudyDescription(component);
            }));
            communityService.executeAction(component, 'getStudyTrialList', {
                userMode: userMode
            }, function (returnValue) {
                let initData = JSON.parse(returnValue);
                helper.addCheckAttributes(initData.currentlyRecruitingTrials);
                component.set('v.currentlyRecruitingTrials', initData.currentlyRecruitingTrials);
                helper.addCheckNoLongerAttributes(initData.trialsNoLongerRecruiting);
                component.set('v.trialsNoLongerRecruiting', initData.trialsNoLongerRecruiting);
                component.set('v.delegatesPicklist', initData.delegatePicklist);
                console.log('INIT DATA>>>>>>>>', JSON.parse(JSON.stringify(initData)));
                component.set('v.contactAccountsList', initData.contactAccounts);
                console.log('initData.contactAccounts>>>', initData.contactAccounts);
                helper.prepareIconsForPI(initData);
                component.set('v.countryPicklist', initData.countryPicklist);
                component.set("v.showSpinner", false);
                component.set('v.isInitialized', true);
                component.set('v.peStatusesPathList', initData.peStatusesPathList);
                component.set('v.peStatusStateMap', initData.peStatusStateMap);
                if (communityService.getUserMode() === 'Participant') {
                    component.set('v.currentlyRecruitingTrials', initData.peList);
                    component.set('v.trialsNoLongerRecruiting', initData.peListNoLongerRecr);
                }
            });
        }
    },

    chForRecords: function (cmp, helper, fromFirstPage) {
        if (cmp.get('v.skipUpdate') === true || cmp.get('v.isInitialized') === false) {
            return;
        }

        let spinner = cmp.find('recordsSpinner');
        spinner.show();
        let filter = cmp.get('v.filterData');
        if (cmp.get("v.searchResumeChanged") === true) {
            filter.searchText = '';
            filter.therapeuticArea = null;
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

            let result = JSON.parse(returnValue);

            cmp.set('v.skipUpdate', true);
            helper.prepareIcons(result.records);
            cmp.set('v.currentPageList', result.records);
            let pagination = cmp.get('v.paginationData');
            pagination.allRecordsCount = result.paginationData.allRecordsCount;
            pagination.currentPageCount = result.paginationData.currentPageCount;
            pagination.currentPage = result.paginationData.currentPage;
            cmp.set('v.paginationData', pagination);

            filter.therapeuticAreas = result.therapeuticAreas;
            cmp.set('v.filterData', filter);

            setTimeout($A.getCallback(function () {
                helper.doUpdateStudyTitle(cmp);
            }), 10);
            cmp.set('v.skipUpdate', false);
            cmp.set('v.searchResumeChanged', false);
            spinner.hide();
        })
    },
    prepareIcons: function (currentPageList) {
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
    prepareIconsForPI: function (initData) {
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
        if (initData.currentlyRecruitingTrials) {
            for (var i = 0; i < initData.currentlyRecruitingTrials.length; i++) {
                for (var j = 0; j < initData.currentlyRecruitingTrials[i].studies.length; j++) {
                    initData.currentlyRecruitingTrials[i].studies[j].trial.statusIcon = iconMap[initData.currentlyRecruitingTrials[i].studies[j].trial.Override_Recruitment_Status__c];
                    initData.currentlyRecruitingTrials[i].studies[j].trial.iconStyle = styleMap[initData.currentlyRecruitingTrials[i].studies[j].trial.Override_Recruitment_Status__c];
                }
            }
        }
        if (initData.trialsNoLongerRecruiting) {
            for (var i = 0; i < initData.trialsNoLongerRecruiting.length; i++) {
                initData.trialsNoLongerRecruiting[i].trial.statusIcon = iconMap[initData.trialsNoLongerRecruiting[i].trial.Override_Recruitment_Status__c];
                initData.trialsNoLongerRecruiting[i].trial.iconStyle = styleMap[initData.trialsNoLongerRecruiting[i].trial.Override_Recruitment_Status__c];
            }
        }
    },
    doUpdateStudyTitle: function (component) {
        if (component.isValid()) {
            var studyTitles = document.getElementsByClassName("study-title");
            for (var i = 0; i < studyTitles.length; i++) {
                var studyTitle = studyTitles.item(i);
                if (studyTitle != null) {
                    if (window.innerWidth < 768) {
                        this.clampLine(studyTitle, 3);
                    } else {
                        this.clampLine(studyTitle, 1);
                    }
                }
            }
            if (component.get('v.userMode') == 'PI') {
                var instructions = document.getElementsByClassName("driving-instructions");
                for (var i = 0; i < instructions.length; i++) {
                    var instruction = instructions.item(i);
                    if (instruction != null) {
                        this.clampLine(instruction, 3);
                    }
                }
            }
        }
    },

    clampLine: function (studyTitle, numberOfRows) {
        var width = studyTitle.style.width;
        if (width === '0' || !width) {
            width = studyTitle.parentNode.offsetWidth;
        }
        var innerText = studyTitle.innerText.replace(/\n/g, ' ');
        studyTitle.innerHTML = '';
        var text = innerText.split(' ');
        var currentWord = 0;
        if (numberOfRows > 1) {
            parentLoop:
                for (let i = 0; i < numberOfRows - 1; i++) {
                    var measure = document.createElement('span');
                    measure.style.whiteSpace = 'nowrap';
                    measure.style.display = 'inline-block';
                    studyTitle.appendChild(measure);
                    for (let j = currentWord; j < text.length; j++) {
                        measure.appendChild(document.createTextNode(text[j] + " "));
                        if (measure.getBoundingClientRect().width > width) {
                            measure.removeChild(measure.lastChild);
                            continue parentLoop;
                        }
                        currentWord++;
                    }
                }
        }
        var lastElement = document.createElement('span');
        for (let i = currentWord; i < text.length; i++) {
            lastElement.appendChild(document.createTextNode(text[i] + " "));
        }
        lastElement.style.display = 'inline-block';
        lastElement.style.overflow = 'hidden';
        lastElement.style.textOverflow = 'ellipsis';
        lastElement.style.whiteSpace = 'nowrap';
        lastElement.style.width = '100%';
        studyTitle.appendChild(lastElement);
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

    addCheckAttributes: function (trails) {
        for (var i = 0; i < trails.length; i++) {
            for (var j = 0; j < trails[i].studies.length; j++) {
                for (var s = 0; s < trails[i].studies[j].ssList.length; s++) {
                    trails[i].studies[j].ssList[s].isRecordUpdated = false;
                    trails[i].studies[j].ssList[s].isEmailValid = true;
                }
            }
        }
    },

    addCheckNoLongerAttributes: function (trails) {
        for (var i = 0; i < trails.length; i++) {
            for (var j = 0; j < trails[i].ssList.length; j++) {
                trails[i].ssList[j].isRecordUpdated = false
                trails[i].ssList[j].isEmailValid = true;
            }
        }
    }
});