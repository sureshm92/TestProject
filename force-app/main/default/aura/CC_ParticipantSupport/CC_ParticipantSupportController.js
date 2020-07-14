({
    doInit: function(component, event, helper) {
        var elements = document.getElementsByClassName("db-qal-main");
        elements[0].style.display = 'block';
    },
    
    doSearch: function(component, event, helper) {
        var searchField= document.getElementById('searchTxt').value;
        //searchField = searchField.replace(/[^0-9\s]/g, "").replace(/\s\s/g, " ").replace(/\s/g,""); 
        if (searchField.length >= 1) {
            communityService.executeAction(component, 'fetchParticipantEnrollment', {
                searchKeyWord: searchField
            }, function(returnValue) {
                var initData = JSON.parse(returnValue);
                component.set("v.searchResult", initData.enrollments);
                component.set("v.count",component.get("v.searchResult").length);
                component.set("v.peobj", initData.enrollments);
                component.set("v.searchKey",searchField);
                var elements = document.getElementsByClassName("db-qal-main");
                elements[0].style.display = 'block';
            });
        } else {
            component.set("v.searchResult", []);
            component.set("v.pe", null);
            component.set("v.count",0);
            var elements = document.getElementsByClassName("db-qal-main");
            elements[0].style.display = 'block';
        }  
    },
    
    showEditParticipantInformation: function(component, event, helper) {
        var PeIndex = event.getSource().get("v.name");
        var rootComponent = $A.get("e.c:CC_ParticipantSupport");
        var pe = component.get('v.peobj')[PeIndex];
        var actions = component.get('v.actions');
        var isInvited = component.get('v.isInvited');
        var anchor = event.currentTarget.value;
        var contactId;
        
        if(component.get('v.peobj')[PeIndex].Participant_Contact__c != null)
        {
           contactId=component.get('v.peobj')[PeIndex].Participant_Contact__c;
        }else if(component.get('v.peobj')[PeIndex].HCP_Contact_HCPEnroll__c != null)
        {
           contactId=component.get('v.peobj')[PeIndex].HCP_Contact_HCPEnroll__c;
        }else
        {
           contactId=null;
        }
        
        if(contactId != null)
        {
           communityService.executeAction(component, 'getInvitedDetails', {
                contactid: contactId
            }, function(returnValue) {
                 component.set('v.InviteStatus', JSON.parse(returnValue));
            });
        }
        component.find("OpenPatientInfoAction").execute(pe, actions, rootComponent, isInvited, function(enrollment) {
            component.set('v.pe', enrollment);
            component.set('v.isInvited', component.get('v.InviteStatus'));
            
        });
    },
    removeComponent: function(cmp, event) {
        var comp = event.getParam("comp");
        comp.destroy();
    },

    doNavigate: function(component, event, helper) {
        var PeIndex = event.getSource().get("v.name");
        var ctpid = component.get('v.peobj')[PeIndex].Clinical_Trial_Profile__c;
        var urlLink = '/s/study-workspace?id='+ctpid;
        window.open(urlLink);
    },
    doRefreshtable: function(component, event, helper) {
        var searchkeys = event.getParam("searchKey"); 
        communityService.executeAction(component, 'fetchParticipantEnrollment', {
                searchKeyWord: searchkeys
            }, function(returnValue) {
                var initData = JSON.parse(returnValue);
                component.set("v.searchResult", initData.enrollments);
                component.set("v.count",component.get("v.searchResult").length);
                component.set("v.peobj", initData.enrollments);
                component.set("v.searchKey",searchkeys);
                var elements = document.getElementsByClassName("db-qal-main");
                elements[0].style.display = 'block';
            });
    }
})