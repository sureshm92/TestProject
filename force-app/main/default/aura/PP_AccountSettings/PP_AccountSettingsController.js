({
    doInit: function (component, event, helper) {
        console.log('inside init pp account');
        component.find('spinner').show();
        if (communityService.getCurrentCommunityMode().currentDelegateId) component.set('v.isDelegate', true);

        communityService.executeAction(component, 'getInitData', {
            userMode: component.get('v.userMode')
        }, function (returnValue) {
            let initData = JSON.parse(returnValue);
            initData.password = {
                old: '',
                new: '',
                reNew: ''
            };
            const queryString = window.location.href;
            if(queryString.includes('changePref')){
            component.set( "v.compId", '4' );    
            }else{
                component.set( "v.compId", '1' ); 
            }
            component.set('v.initData', initData);
            component.set('v.contactChanged', initData.contactChanged);
            component.set('v.personWrapper', initData.contactSectionData.personWrapper);
            component.set('v.contactSectionData', initData.contactSectionData);
            component.set('v.optInEmail', initData.contactSectionData.personWrapper.optInEmail);
            component.set('v.optInSMS', initData.contactSectionData.personWrapper.optInSMS);
			component.set('v.userType', initData.myContact.UserCommunytyType__c);
            var userType = initData.myContact.userCommunytyType__c;
            if(userType)
                 if(userType.includes('HCP') && component.get('v.userMode') == 'PI')
                     component.set('v.userTypeHCP_PI', true);
            
            component.set('v.contact', initData.myContact);
            component.set('v.currentEmail', initData.myContact.Email);

            component.set('v.isInitialized', true);
        }, null, function () {
            component.find('spinner').hide();
        })
    },
	onClick : function(component, event, helper) {
        var y = document.getElementById("selectOption");
        var toglNavg = component.get('v.toglNavg');
        toglNavg = !toglNavg;
        component.set("v.toglNavg",toglNavg);
        
        var isOpen = false;
        var device = $A.get("$Browser.formFactor");
       var id = event.target.dataset.menuItemId;
       component.set("v.compId",id);
       if(device=='PHONE'){
          for (var i = 1; i < 7; i++) {
              var x = document.getElementById(i);
              
            if(id != i && !toglNavg){
                x.style.visibility = "hidden";
                y.style.boxShadow = "none";
                y.style.background = "Transparent";
            } else if(toglNavg){
                x.style.visibility = "visible";
                y.style.boxShadow = "0 4px 24px 0 rgba(0, 0, 0, 0.16)";
        		y.style.background = "#fff";
            }
        }             
       }
  	},
    onEditPerson: function (component, event, helper) {
        let personWrapper = event.getSource().get('v.personWrapper');        
        component.set('v.personWrapper', personWrapper);
    }
});