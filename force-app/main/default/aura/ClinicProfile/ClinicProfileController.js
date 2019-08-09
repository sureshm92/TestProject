/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, hepler) {
        if(communityService.isInitialized()){
            if(communityService.getUserMode() !== 'PI') communityService.navigateToPage('');
            var clinicId = communityService.getUrlParameter('id');
            var action = component.get('c.getClinicProfileData');
            action.setParams({clinicId: clinicId});
            action.setCallback(this, function(response) {
                debugger;
                var state = response.getState();
                if (state === "SUCCESS") {
                    var initData = JSON.parse(response.getReturnValue());
                    component.set('v.clinic', initData.clinic);
                    component.set('v.myStudies', initData.myStudies);
                    component.set('v.physicians', initData.physicians);
                    component.find('mainSpinner').hide();
                }else{
                    var errorMsg = 'Unknown error';
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) errorMsg = errors[0].message;
                    console.log('Callout error (getClinicProfileData): ' + errorMsg);
                }
            });
            $A.enqueueAction(action);
        }
    },

    doChangeGroup: function (component, event) {
        var id = event.currentTarget.id;
        component.set('v.viewMyStudies', id === 'referredToMe');
    },

    doSelectStudy: function (component, event) {
        var id = event.currentTarget.id;
        if(id === 'Overview'){
            component.set('v.currentStudy', undefined);
            component.set('v.currentStudyId', 'Overview');
            return;
        }
        var studies = component.get('v.myStudies');
        for(var i = 0; i < studies.length; i++){
            if(studies[i].studySite.Id === id){
                component.set('v.currentStudy', studies[i]);
                component.set('v.currentStudyId', id);
                return;
            }
        }
    }

})