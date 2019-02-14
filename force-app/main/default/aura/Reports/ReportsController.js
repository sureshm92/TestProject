/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, hepler) {
        if (!communityService.isInitialized()) return;
        component.set('v.userMode', communityService.getUserMode());
        var spinner = component.find('mainSpinner');
        spinner.show();

        communityService.executeAction(component, 'getInitData', {
            trialId: component.get('v.trialId'),
            userMode: communityService.getUserMode()
        }, function (returnValue) {
            var initData = JSON.parse(returnValue);
            component.set('v.reportsFilterData', initData.filterData);
            component.set('v.mrrPassedFailed', initData.analitics.mrrPassedFailed);
            component.set('v.preScreeningPassedFailed',  initData.analitics.preScreeningPassedFailed);
            component.set('v.studyOrientationAttVsNotAtt',  initData.analitics.studyOrientationAttVsNotAtt);
            component.set('v.isInitialized', true);
            spinner.hide();
        });
    },

    doUpdateAnalytics: function (component) {
        var spinner = component.find('mainSpinner');
        spinner.show();
        var studyId = component.get('v.trialId');
        if(!studyId) studyId = component.get('v.study');

        communityService.executeAction(component, 'getAnaliticsJSON', {
            studyId: studyId,
            studySiteId: component.get('v.studySite'),
            referringClinicId: component.get('v.referringClinic'),
            dateRange: component.get('v.dateRange'),
            userMode: communityService.getUserMode()
        }, function (retrunValue) {
            var analitics = JSON.parse(retrunValue);
            component.set('v.mrrPassedFailed', analitics.mrrPassedFailed);
            component.set('v.preScreeningPassedFailed', analitics.preScreeningPassedFailed);
            component.set('v.studyOrientationAttVsNotAtt', analitics.studyOrientationAttVsNotAtt);
            spinner.hide();
        });
    },

    doExport: function (component) {
        var exportURL = communityService.getCommunityURLPathPrefix().replace('/s','/apex') + '/exportexcelpage';
        var trialId = component.get('v.trialId');
        var studyId = component.get('v.study');
        var studySiteId = component.get('v.studySite');
        var referringClinicId = component.get('v.referringClinic');
        var dateRange = component.get('v.dateRange');

        var params = [];
        params.push('userMode=' + component.get('v.userMode'));
        if(trialId) {
            params.push('study=' + trialId);
        }else if(studyId){
            params.push('study=' + studyId);
        }

        if(communityService.getUserMode() === 'PI'){
            if(referringClinicId) params.push('referringClinic=' + referringClinicId);
        }else{
            if(studySiteId) params.push('studySite=' + studySiteId);
        }

        if(dateRange) params.push('dateRange=' + encodeURIComponent(dateRange));
        if(params.length > 0) exportURL += '?' + params.join('&');
        console.log('Export URL: ' + exportURL);
        window.open(exportURL, '_blank');
    },

    doExportHCPE: function (component) {
        var exportURL = communityService.getCommunityURLPathPrefix().replace('/s','/apex') + '/ExportHCPEListToExcel';
        var trialId = component.get('v.trialId');
        var studyId = component.get('v.study');
        var studySiteId = component.get('v.studySite');
        var referringClinicId = component.get('v.referringClinic');
        var dateRange = component.get('v.dateRange');

        var params = [];
        params.push('userMode=' + component.get('v.userMode'));
        if(trialId) {
            params.push('study=' + trialId);
        }else if(studyId){
            params.push('study=' + studyId);
        }

        if(communityService.getUserMode() === 'PI'){
            if(referringClinicId) params.push('referringClinic=' + referringClinicId);
        }else{
            if(studySiteId) params.push('studySite=' + studySiteId);
        }

        if(dateRange) params.push('dateRange=' + encodeURIComponent(dateRange));
        if(params.length > 0) exportURL += '?' + params.join('&');
        console.log('Export URL: ' + exportURL);
        window.open(exportURL, '_blank');
    }

})