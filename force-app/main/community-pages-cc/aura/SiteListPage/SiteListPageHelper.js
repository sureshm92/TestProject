({
    doDatabaseSearchHelper: function (component, event, params) {
        let spinner = component.find('mainSpinner');
        let paginationData = component.get('v.paginationData');
        spinner.show();
        communityService.executeAction(
            component,
            'getSearchResults',
            {
                searchOption: params.selectedSearchOption,
                searchText: params.searchText,
                sortType: params.sortType,
                paginationJSON:
                    paginationData === undefined || paginationData === null
                        ? null
                        : JSON.stringify(paginationData)
            },
            function (paginatedWrapper) {
                component.set('v.resultSet', paginatedWrapper.sites);
                component.set('v.filteredResultSet', []);
                component.set('v.paginationData', paginatedWrapper.paginationData);
                component.set('v.searched', true);
                component.set('v.resetVal', false);
                let filterStudyList = [];
                let filterCountryList = [];
                if (paginatedWrapper.sites.length > 0) {
                    paginatedWrapper.sites.forEach(function (site) {
                        //For study filter
                        if (filterStudyList.some((study) => study.value === site.studyName)) {
                            let index = filterStudyList.findIndex(
                                (study) => study.value === site.studyName
                            );
                            filterStudyList[index].key.push(site.siteId);
                        } else {
                            filterStudyList.push({ key: [site.siteId], value: site.studyName });
                        }
                        //For country filter
                        if (
                            filterCountryList.some((country) => country.value === site.siteCountry)
                        ) {
                            let index = filterCountryList.findIndex(
                                (country) => country.value === site.siteCountry
                            );
                            filterCountryList[index].key.push(site.siteId);
                        } else {
                            filterCountryList.push({ key: [site.siteId], value: site.siteCountry });
                        }
                    });
                    console.log('filterStudyList ' + JSON.stringify(filterStudyList));
                    console.log('filterCountryList ' + JSON.stringify(filterCountryList));
                    component.set('v.filterStudyList', filterStudyList);
                    component.set('v.filterCountryList', filterCountryList);
                    component.set('v.tmpFilterStudyList', filterStudyList);
                    component.set('v.tmpFilterCountryList', filterCountryList);
                }
                component.find('searchResults').resetPageFilter();
                spinner.hide();
            },
            function () {
                spinner.hide();
            }
        );
    },
    doExportAllHelper: function (component, helper, params) {
        let spinner = component.find('mainSpinner');
        let totalItemsToDownload = component.get('v.paginationData.allRecordsCount');
        let siteIds = component.get('v.siteIds');
        let exportList = component.get('v.exportList');
        spinner.show();
        communityService.executeAction(
            component,
            'getAllSearchResults',
            {
                searchOption: params.selectedSearchOption,
                searchText: params.searchText,
                siteIds: component.get('v.siteIds'),
                totalItemsToDownload: totalItemsToDownload
            },
            function (csvWrapper) {
                if (csvWrapper.siteIds) {
                    siteIds = siteIds.concat(csvWrapper.siteIds);
                    component.set('v.siteIds', siteIds);
                }
                exportList = exportList.concat(csvWrapper.sites);
                component.set('v.exportList', exportList);
                if (exportList.length < totalItemsToDownload) {
                    helper.doExportAllHelper(component, helper, params);
                } else {
                    helper.downloadCSV(exportList);
                }
                spinner.hide();
            },
            function () {
                spinner.hide();
            }
        );
    },
    downloadCSV: function (exportList) {
        console.time('csv');
        console.log('CSV File Length: ' + exportList.length);
        let csvStringResult, columnDivider, lineDivider;
        let header = [
            $A.get('$Label.c.CC_TableHeader_CTP'),
            $A.get('$Label.c.CC_TableHeader_SiteNo'),
            $A.get('$Label.c.CC_TableHeader_Site'),
            $A.get('$Label.c.CC_TableHeader_Country'),
            $A.get('$Label.c.CC_TableHeader_PI'),
            $A.get('$Label.c.CC_TableHeader_Phone'),
            $A.get('$Label.c.CC_TableHeader_Contact'),
            $A.get('$Label.c.CC_TableHeader_Status')
        ];
        if (!exportList || !exportList.length) {
            return null;
        }
        columnDivider = ',';
        lineDivider = '\n';
        csvStringResult = '';
        csvStringResult += header.join(columnDivider);
        csvStringResult += lineDivider;

        for (let i = 0; i < exportList.length; i++) {
            //CTP
            if (exportList[i]['Clinical_Trial_Profile__r']['Study_Code_Name__c'] !== undefined) {
                csvStringResult +=
                    '"' +
                    exportList[i]['Clinical_Trial_Profile__r']['Study_Code_Name__c'] +
                    '"' +
                    ',';
            } else {
                csvStringResult += '" "' + ',';
            }
            //Site Number
            if (exportList[i]['Study_Site_Number__c'] !== undefined) {
                csvStringResult += '"' + exportList[i]['Study_Site_Number__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }
            //Site Name
            if (exportList[i]['Name'] !== undefined) {
                csvStringResult += '"' + exportList[i]['Name'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }
            //Site Country
            if (exportList[i]['Site__r']['BillingCountry'] !== undefined) {
                csvStringResult += '"' + exportList[i]['Site__r']['BillingCountry'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }
            //PI Name
            if (exportList[i]['Principal_Investigator__r'] !== undefined) {
                csvStringResult +=
                    '"' + exportList[i]['Principal_Investigator__r']['Name'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }
            //Site Phone
            if (exportList[i]['Study_Site_Phone__c'] !== undefined) {
                csvStringResult += '"' + exportList[i]['Study_Site_Phone__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }
            //Site Contact Person / Site Staff
            if (
                exportList[i]['Site_Staff__r'] !== undefined &&
                exportList[i]['Site_Staff__r']['Site_Contact__r'] !== undefined
            ) {
                csvStringResult +=
                    '"' + exportList[i]['Site_Staff__r']['Site_Contact__r']['Name'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }
            //Status
            if (exportList[i]['Override_PI_Referral_Status__c'] !== undefined) {
                csvStringResult +=
                    '"' + exportList[i]['Override_PI_Referral_Status__c'] + '"' + ',';
            } else {
                csvStringResult += '" "' + ',';
            }
            csvStringResult += lineDivider;
        }
        let hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csvStringResult);
        hiddenElement.target = '_self';
        hiddenElement.download = $A.get('$Label.c.CC_Btn_ExportAll') + '.csv'; // CSV file Name
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file
        console.timeEnd('csv');
    }
});
