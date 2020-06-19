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

            component.set('v.contact', initData.myContact);
            component.set('v.currentEmail', initData.myContact.Email);

            component.set('v.isInitialized', true);
        }, null, function () {
            component.find('spinner').hide();
        })
    },
	onClick : function(component, event, helper) {
       var id = event.target.dataset.menuItemId;
       component.set("v.compId",id)
  	},
    onEditPerson: function (component, event, helper) {
        let personWrapper = event.getSource().get('v.personWrapper');        
        component.set('v.personWrapper', personWrapper);
    }
});