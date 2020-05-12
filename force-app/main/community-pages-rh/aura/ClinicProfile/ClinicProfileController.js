/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        if(!communityService.isInitialized()) return;

        if(!communityService.isDummy()){
            if(communityService.getUserMode() !== 'PI') communityService.navigateToPage('');
            let clinicId = communityService.getUrlParameter('id');

            component.find('mainSpinner').show();
            communityService.executeAction(component, 'getClinicProfileData', {
                clinicId: clinicId
            }, function (response) {
                let initData = JSON.parse(response);
                component.set('v.clinic', initData.clinic);
                component.set('v.myStudies', initData.myStudies);
                component.set('v.physicians', initData.physicians);
                component.find('mainSpinner').hide();
            });
        } else {
            component.find('builderStub').setPageName(component.getName());
        }
    },

    doChangeGroup: function (component, event) {
        let id = event.currentTarget.id;
        component.set('v.viewMyStudies', id === 'referredToMe');
    },

    doSelectStudy: function (component, event) {
        let id = event.currentTarget.id;
        if(id === 'Overview'){
            component.set('v.currentStudy', undefined);
            component.set('v.currentStudyId', 'Overview');
            return;
        }
        let studies = component.get('v.myStudies');
        for(let i = 0; i < studies.length; i++){
            if(studies[i].studySite.Id === id){
                component.set('v.currentStudy', studies[i]);
                component.set('v.currentStudyId', id);
                return;
            }
        }
    }

})