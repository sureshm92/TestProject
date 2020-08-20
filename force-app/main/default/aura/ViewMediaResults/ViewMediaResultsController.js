({
    doInit: function (component, event, hepler) {
        if (!communityService.isInitialized()) return;
        component.set('v.userMode', communityService.getUserMode());
        var trialId = component.get('v.trialId');
        var siteId = component.get('v.siteId');
        var spinner = component.find('mainSpinner');
        spinner.show();
        var paramFilter = communityService.getUrlParameter("filter"); 
         
        communityService.executeAction(component, 'getInitData', {
            trialId: trialId,
            siteId: siteId,
            mode: communityService.getUserMode(),
            btnFilter: paramFilter,
            userMode: component.get('v.userMode'),
            delegateId: communityService.getDelegateId()
        }, function (returnValue) {
            var initData = JSON.parse(returnValue);
            var studyData = initData.clinicalList;
            var accessRecord;
            var noAccessRecord; 
            if(initData.clinicalList != '' || initData.clinicalList != undefined){
               accessRecord = true;
               }else{
               accessRecord = false;
               }
               if(initData.clinicalList == '' || initData.clinicalList == undefined){
               noAccessRecord = true;
            }else{
                noAccessRecord = false;
            }
            if(studyData == '' || studyData == undefined &&!noAccessRecord &&accessRecord){
                component.set('v.HaveAccessrecCMP', false);
                component.set('v.NoOutreachAccess', true);
         }
            if(studyData != '' || studyData != undefined &&noAccessRecord &&!accessRecord){
             component.set('v.HaveAccessrecCMP', true);
             component.set('v.NoOutreachAccess', false);
         }
            component.set('v.piBtnFilter', paramFilter);
            component.set('v.skipUpdate', true);
            component.set('v.pageList', initData.currentPageList);
            component.set('v.peFilterData', initData.moFilterData);
            component.set('v.paginationData', initData.paginationData);
            component.set('v.peFilter', initData.moFilter);
            component.set('v.trialIds', initData.trialIds);
            component.set('v.statistics', initData.statistics);
            component.set('v.isInitialized', true);
            component.set('v.skipUpdate', false);
            spinner.hide();

        });
        
    },
    
     doUpdateRecords: function (component, event) {
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
        var piBtnFilter = component.get('v.piBtnFilter');
        var action = component.get('c.getRecords');
        var trialId = component.get('v.trialId');
        var studyWasChanged = "false";
        if (trialId && trialId !== filter.study) {
            studyWasChanged = "true"
        }
        communityService.executeAction(component, 'getRecords', {
            trialId: trialId,
            filterJSON: filterJSON,
            paginationJSON: paginationJSON,
            piBtnFilter: piBtnFilter,
            userMode: communityService.getUserMode(),
            studyChanged: studyWasChanged,
            delegateId: communityService.getDelegateId()
        }, function (returnValue) {
            if (component.get('v.peFilter').searchText !== searchText) return;
            var result = JSON.parse(returnValue);
            component.set('v.skipUpdate', true);
            component.set('v.pageList', result.peList);
            component.set('v.peFilter', result.moFilter);
            component.set('v.peFilterData', result.moFilterData);
            if (trialId != filter.study) {
                component.set('v.trialId', filter.study)
            }
            component.set('v.skipUpdate', false);
            
            spinner.hide();
        })
    },
    
    
    doShowInviteRP: function (component, event, helper) {
        component.set("v.NewOutreaachcmp",true);
        component.find('inviteRPAction').execute();
    },
    
})