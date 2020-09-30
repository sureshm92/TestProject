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
            var compId = component.get("v.compId");
            console.log('compId-->'+compId);
            const queryString = window.location.href;
            if(queryString.includes('changePref')){
            component.set( "v.compId", '4' );    
            }
            else if(queryString.includes('langloc')){
                component.set( "v.compId", '3' );
            }
             else if(queryString.includes('profileInformation')){
                component.set( "v.compId", '1' );
            }
            
            else if(queryString.includes('passwordchange')){
                component.set( "v.compId", '2' ); 
            }
            else if(queryString.includes('cookiesSettings')){
                component.set( "v.compId", '5' ); 
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
    
    removeFocus : function(component, event, helper) {
      var y = document.getElementById("selectOption");
      y.style.boxShadow = "none";
      component.set("v.toglNavg",false);
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
        var compId = component.get("v.compId");
        var queryString = window.location.href;
        if(compId == '1'){
             communityService.navigateToPage('account-settings?profileInformation'); 
        }
        else if(compId == '3'){
            communityService.navigateToPage('account-settings?langloc'); 
        }
        else if(compId == '4'){
            communityService.navigateToPage('account-settings?changePref'); 
        }
         else if(compId == '2'){
            communityService.navigateToPage('account-settings?passwordchange'); 
        }
        else if(compId == '5'){
                communityService.navigateToPage('account-settings?cookiesSettings'); 
             }
        
       if(device=='PHONE' || device=='TABLET'){           
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