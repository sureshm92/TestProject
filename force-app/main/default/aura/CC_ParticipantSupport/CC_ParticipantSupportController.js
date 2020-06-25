({
    doInit: function (component, event, helper) {
        let elements = document.getElementsByClassName('db-qal-main');
        elements[0].style.display = 'none';
    },

    doSearch: function (component, event, helper) {
        let dbQalMainStyle = 'none';
        let searchField = component.find('searchField').get('v.value');
        if (searchField.length > 1) {
            communityService.executeAction(component, 'fetchParticipantEnrollment', {
                searchKeyWord: searchField
            }, function (returnValue) {
                let initData = JSON.parse(returnValue);
                component.set('v.searchResult', initData.enrollments);
                component.set('v.pe', initData.enrollments[0]);
                component.set('v.enrollments', initData.enrollments);
                dbQalMainStyle = 'block';
            });
        } else {
            component.set('v.searchResult', []);
            component.set('v.pe', null);
        }
        let elements = document.getElementsByClassName('db-qal-main');
        elements[0].style.display = dbQalMainStyle;
    },

    showEditParticipantInformation: function (component, event, helper) {
        let peIndex = event.getSource().get('v.name');
        let pe = component.get('v.enrollments')[peIndex];
        let actions = component.get('v.actions');
        let rootComponent = $A.get('e.c:CC_ParticipantSupport');
        let isInvited = component.get('v.isInvited');
        component.find('OpenPatientInfoAction').execute(pe, actions, rootComponent, isInvited, function (enrollment) {
            component.set('v.pe', enrollment);
            component.set('v.isInvited', true);
        });
    },

    removeComponent: function (cmp, event) {
        let comp = event.getParam('comp');
        comp.destroy();
    }
})