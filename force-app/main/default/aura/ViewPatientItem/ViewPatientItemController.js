/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        if (component.get('v.pe')) {
            helper.preparePathItems(component, event);
        }
    },

    doChangeStatus: function (component, event, helper) {
        var rootComponent = component.get('v.parent');
        rootComponent.find('mainSpinner').show();
        var pe = component.get('v.pe');
        var status = event.currentTarget.dataset.statusName;
        var changePEStatusByPIAction = rootComponent.find('changePEStatusByPIAction');
        changePEStatusByPIAction.execute(pe, status, null, null, function (pe) {
            component.set('v.pe', pe);
            rootComponent.find('mainSpinner').hide();
        }, function () {
            rootComponent.find('mainSpinner').hide();
        });
    },

    showEditParticipantInformation: function (component, event, helper) {
        var rootComponent = component.get('v.parent');
        var pe = component.get('v.pe');
        var actions = component.get('v.actions');
        var isInvited = component.get('v.isInvited');
        var anchor = event.currentTarget.value;
        rootComponent.find('updatePatientInfoAction').execute(pe, actions, rootComponent, isInvited, function (enrollment) {
            component.set('v.pe', enrollment);
            //rootComponent.find('updatePatientInfoAction').set('v.pathItems', component.get('v.pathItems'));
                rootComponent.refresh();

        });
    },
    doPreScreening: function (component, event, helper) {
        var rootComponent = component.get('v.parent');
        var pe = component.get('v.pe');
        var frameHeight = component.get('v.frameHeight');
        var isInvited = component.get('v.isInvited');
        component.set('v.showSpinner', true);
        rootComponent.find('openSearch').execute(pe, rootComponent, frameHeight, isInvited, function (enrollment) {
            component.set('v.pe', enrollment);
            rootComponent.refresh();

        });
    }

})