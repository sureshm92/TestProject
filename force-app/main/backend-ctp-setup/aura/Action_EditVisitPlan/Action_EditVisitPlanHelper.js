/**
 * Created by Igor Malyuta on 25.09.2019.
 */

({
    createVPMode: function (component) {
        component.set('v.plan', {
            sobjectType: 'Visit_Plan__c'
        });
        component.set('v.visits', []);
        let iconDetails = [];
        let icons = component.get('v.icons');
        for (let i = 0; i < icons.length; i++) {
            iconDetails.push({
                sobjectType: 'Icon_Details__c',
                Name: icons[i].id
            });
        }
        component.set('v.iconDetails', iconDetails);
    },

    callRemote: function (component, vpId, needClone) {
        component.find('spinner').show();
        communityService.executeAction(component, 'getVisitPlanWrapper', {
            planId: vpId
        }, function (response) {
            let wrapper = JSON.parse(response);
            let plan = wrapper.plan;
            let visits = wrapper.visits;
            let iconDetails = wrapper.iconDetails;
            if(needClone) {
                plan.Id = null;
                plan.Name += ' Clone';
                for(let i = 0; i < visits.length; i++) visits[i].Id = null;
                for(let j = 0; j < iconDetails.length; j++) iconDetails[j].Id = null;
            }
            component.set('v.plan', plan);
            component.set('v.visits', visits);
            component.set('v.iconDetails', iconDetails);
            component.find('spinner').hide();
        });
    }
});