({
    Search: function(component, event, helper) {
        var searchField= document.getElementById('searchTxt').value;
        searchField = searchField.replace(/[^0-9\s]/g, "").replace(/\s\s/g, " ").replace(/\s/g,""); 
        if (searchField.length >= 2) {
            communityService.executeAction(component, 'fetchParticipantEnrollment', {
                searchKeyWord: searchField
            }, function(returnValue) {
                var initData = JSON.parse(returnValue);
                component.set("v.searchResult", initData.ParticipantEnrollment);
                component.set("v.pe", initData.ParticipantEnrollment[0]);
                component.set("v.peobj", initData.ParticipantEnrollment);
                var elements = document.getElementsByClassName("db-qal-main");
                elements[0].style.display = 'block';
            });
        } else {
            component.set("v.searchResult", []);
            component.set("v.pe", null);
            var elements = document.getElementsByClassName("db-qal-main");
            elements[0].style.display = 'block';
        }  
    },
    doInit: function(component, event, helper) {
        var elements = document.getElementsByClassName("db-qal-main");
        elements[0].style.display = 'block';
    },

    showEditParticipantInformation: function(component, event, helper) {
        var PeIndex = event.getSource().get("v.name");
        var rootComponent = $A.get("e.c:CC_ParticipantSupport");

        var pe = component.get('v.peobj')[PeIndex];
        var actions = component.get('v.actions');
        var isInvited = component.get('v.isInvited');
        var anchor = event.currentTarget.value;
        component.find("OpenPatientInfoAction").execute(pe, actions, rootComponent, isInvited, function(enrollment) {
            component.set('v.pe', enrollment);
            component.set('v.isInvited', true);

        });
    },
    removeComponent: function(cmp, event) {
        var comp = event.getParam("comp");
        comp.destroy();
    },

})