/**
 * Created by Igor Malyuta on 24.09.2019.
 */

({
    doInit: function (component, event, helper) {
        let service = component.find('iconsService');
        service.getIconsData(component, event, helper)
            .then(function (result) {
                let iconNames = result.iconNames.sort(function (a, b) {
                    if (a.id < b.id) return -1;
                    if (a.id > b.id) return 1;
                    return 0;
                });
                component.set('v.icons', iconNames);
            });

        component.set('v.plan', {
            sobjectType: 'Visit_Plan__c'
        });
    },

    doExecute: function (component, event, helper) {
        let params = event.getParam('arguments');
        component.set('v.callback', params.callback);
        component.set('v.mode', params.mode);
        component.set('v.visits', []);
        component.set('v.plan', {});

        let vpId = params.vpId;
        if (vpId) {
            let plan = component.get('v.plan');
            plan.Id = vpId;
            component.set('v.plan', plan);
        }

        if (params.mode === 'create') {
            helper.createVPMode(component);
        } else if (vpId !== null) {
            if(params.mode === 'edit' || params.mode === 'view') {
                helper.callRemote(component, vpId);
            } else if(params.mode === 'clone') {
                helper.callRemote(component, vpId, true);
            }
        }

        component.find('createVisitPlan').show();
    },

    doEditLegend: function (component, event, helper) {
        component.find('actionLegend').execute(
            component.get('v.plan').Id,
            component.get('v.icons'),
            component.get('v.iconDetails'),
            function (iconDetails) {
                component.set('v.iconDetails', iconDetails);
            }
        );
    },

    doAddVisit: function (component, event, helper) {
        component.find('actionVisit').execute(null, function (visit) {
            let visits = component.get('v.visits');
            visits.push(visit);
            component.set('v.visits', visits);
        });
    },

    saveVP: function (component, event, helper) {
        component.find('spinner').show();

        let updatedVisits = [];
        let deletedVisits = [];
        let visits = component.get('v.visits');
        for (let i = 0; i < visits.length; i++) {
            let visit = visits[i];
            if (visit.deleted) {
                visit.deleted = undefined;
                deletedVisits.push(visit);
            } else {
                updatedVisits.push(visit);
            }
        }
        communityService.executeAction(component, 'upsertVisitPlan', {
            plan: JSON.stringify(component.get('v.plan')),
            visits: JSON.stringify(updatedVisits),
            deletedVisits: JSON.stringify(deletedVisits),
            details: JSON.stringify(component.get('v.iconDetails'))
        }, function (vpId) {
            component.find('spinner').hide();
            component.find('createVisitPlan').hide();

            let callback = component.get('v.callback');
            if (callback) callback(vpId);
        });
    },

    cancelClick: function (component, event, helper) {
        let modalName = event.getSource().get('v.name');
        component.find(modalName).hide();
    },

    doVisitItemEdit: function (component, event, helper) {
        let visitItemCmp = event.getSource();
        let editedVisit = visitItemCmp.get('v.visit');
        component.find('actionVisit').execute(editedVisit, function () {
            component.set('v.visits', component.get('v.visits'));
        });
    },

    doVisitItemDelete: function (component, event, helper) {
        let visitItemCmp = event.getSource();
        visitItemCmp.set('v.visit.deleted', true);
        component.set('v.visits', component.get('v.visits'));
    }
});