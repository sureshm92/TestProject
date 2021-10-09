/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) return;
        if (!communityService.isDummy()) {
            let spinner = component.find('mainSpinner');
            spinner.show();
            component.set('v.userMode', communityService.getUserMode());
            var commName = communityService.getCurrentCommunityName();
            if (commName.includes('Janssen')) component.set('v.isJanssen', true);
            let trialId = communityService.getUrlParameter('id');
            component.set('v.trialId', trialId);
            let siteId = communityService.getUrlParameter('siteId');
            component.set('v.siteId', siteId); 
            component.set('v.currentDelegateId', communityService.getDelegateId());
            var actionGetAcceslevel = component.get("c.getDelAcceslevel");
            actionGetAcceslevel.setParams({ 
                delegateId : communityService.getDelegateId(),
                userMode :  communityService.getUserMode()
            });
            actionGetAcceslevel.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set('v.accessLevel',response.getReturnValue());
                    if(component.get('v.accessLevel') == 'Level 3' || component.get('v.accessLevel') == 'Level 2'){
                        component.set('v.isaccesslevelthree',true);
                    }
                }                
            });
            $A.enqueueAction(actionGetAcceslevel);
            component.set('v.isInitialized', true);
            spinner.hide();
        } else {
            component.find('builderStub').setPageName(component.getName());
        }
        
    },
    doExport: function (component) {
        let exportURL =
            communityService.getCommunityURLPathPrefix().replace('/s', '/apex') +
            '/exportexcelpage';

        let params = [];
        params.push('userMode=' + component.get('v.userMode'));
        if (params.length > 0) exportURL += '?' + params.join('&');
        console.log('Export URL: ' + exportURL);
        window.open(exportURL, '_blank');
    },

    doExportFull: function (component) {
        if (communityService.isInitialized() && communityService.isMobileSDK()) {
            communityService.showInfoToast('Info!', $A.get('$Label.c.Pdf_Not_Available'), 100);
            return;
        }
        var childComponent = component.find('childCmp');
        childComponent.childMethod();
    },
    
    onClickListView: function (component, event, helper) {
        communityService.navigateToPage('my-referrals-list');
    },

    doNeedsGuardian: function (component, event) {
        let childCmp = event.getSource();
        let hasEmancipatedParticipants = childCmp.get('v.hasEmancipatedParticipants');
        if (hasEmancipatedParticipants) {
            component.set('v.hasEmancipatedParticipants', true);
            component.set('v.parent', childCmp);
        } else {
            component.set('v.hasEmancipatedParticipants', false);
            component.set('v.parent', childCmp);
        }
    },

    filterEmancipations: function (component, event, helper) {
        let rootCmp = component.get('v.parent');
        rootCmp.filterEmancipationsOnly();
    },

    handleActive: function (component, event, helper) {
        var tab = event.getSource();
        switch (tab.get('v.id')) {
            case 'tab1' :
                component.set("v.layout1", 4);
                component.set("v.layout2", 8);
                component.set("v.show", true);
                break;
            case 'tab2':
                component.set("v.layout1", 12);
                component.set("v.show", false);
                break;
            case 'tab3':
                component.set("v.layout1", 12);
                component.set("v.show", false);
                break;
        }
    },

    doGoHome: function () {
        communityService.navigateToPage('');
    },

   getValueFromProfileSectionPage : function(component, event) {
        component.set("v.isProfilePage",false);
        component.set("v.isBulkProfilePage",false);            
        if(event.getParam('isProfilePage') == true) {
            component.set("v.isProfilePage",event.getParam('isProfilePage'));
            component.set("v.peId",event.getParam('peId'));
            component.set("v.ctpId",event.getParam('ctpId'));
        }
        if(event.getParam('isBulkProfilePage') == true) {
            component.set("v.isBulkProfilePage",event.getParam('isBulkProfilePage'));
            component.set("v.peIds",event.getParam('peIds'));
            component.set("v.ctpIds",event.getParam('ctpIds')); 
            component.set("v.verifyFilterValue",event.getParam('verifyFilterValue')); 
        }
    },

    refreshFromTablecomponent : function(component, event) {
        $A.get('e.force:refreshView').fire();
    },

    doReferPatient: function (component) {
        communityService.navigateToPage(
            'referring?id=' +
                component.get('v.trialId') +
                '&peid=' +
                component.get('v.peIds')
        );
    },

    refreshTable : function(component, event) {
        component.set("v.peRecordList",event.getParam('peRecordList'));
        component.find('table123').getPatientRecords();
    },

    onExcludeIncluderefreshTable : function(component, event) {
        component.set("v.peRecordList",event.getParam('peRecordList'));
        component.find('table123').getOnExcludeIncluderefresh();
    },

    onBulkExcludeIncluderefreshTable : function(component, event) {
        component.set("v.bulkPeIds",event.getParam('bulkPeIds'));
        component.find('table123').getOnbBulkExcludeIncluderefresh();
    },

});