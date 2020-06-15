({
    doInit: function (component, event, helper) {
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
            var resultMsg = sessionStorage.getItem( 'pageTransfer' );
            const queryString = window.location.href;
            if(queryString.includes('sampleVar')){
            component.set("v.showEditProfile",false);
            component.set("v.selectedItem","custex");
            component.set('v.custExp', true);
            component.set( "v.coibool", JSON.parse( resultMsg ).sampleVar );
            }else{
                component.set("v.showEditProfile",true);
                component.set( "v.coibool", false );   
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

    
    handleSelect: function(component, event, helper) {
        var selected = event.getParam('name');
			component.set('v.showEditProfile', false);
            component.set('v.changePswd', false);
            component.set('v.notPref', false);
            component.set('v.langReg', false);
            component.set('v.custExp', false);
            component.set('v.cookSet', false);
        if (selected === 'editProfile') {
            component.set('v.showEditProfile', true);
        }else if(selected === 'changepwd'){
            component.set('v.changePswd', true);
        }else if(selected === 'notfpre'){
            component.set('v.notPref', true);
        }else if(selected === 'langreg'){
            component.set('v.langReg', true);
        }else if(selected === 'custex'){
            component.set('v.custExp', true);
        }else if(selected === 'cookset'){
           component.set('v.cookSet', true); 
        }
    },
    onEditPerson: function (component, event, helper) {
        let personWrapper = event.getSource().get('v.personWrapper');        
        component.set('v.personWrapper', personWrapper);
    }
});