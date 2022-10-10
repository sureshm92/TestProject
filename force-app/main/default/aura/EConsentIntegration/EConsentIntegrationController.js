({
	doInit: function (component, event, helper) {
        communityService.executeAction(
            component,
            'getPermission',
            {
                ctpId: component.get('v.recordId')
            },
            function (initData) {
                component.set('v.userPermission', initData.userPermission);
                component.set('v.usrPermission', initData.userPermission);
                component.set('v.usrProfilePermission', initData.userProfilePermission);
                component.set('v.usrStudySiteSize', initData.ssListSize );
                
                if(!initData.econsentpermissioncheck){
                     component.set('v.userPermission', 'Disabled');
                }
                if(!initData.userProfilePermission){
                     component.set('v.userPermission', 'Disabled');
                }
                if(component.get('v.usrPermission') == 'View'){
                     component.set('v.isreadonly', true);
                }else{
                     component.set('v.isreadonly', false);
                }
                component.find('spinner').hide();
            }
        );
    },
    handleEvents : function(cmp, event) { 
        if(cmp.get('v.userPermission') == 'Disabled') {
            if(cmp.get('v.usrProfilePermission')){
                if(cmp.get('v.usrStudySiteSize') != 0){
                     cmp.set('v.userPermission',cmp.get('v.usrPermission'));
                }
            }  
        }else{
            cmp.set('v.userPermission','Disabled');
        }      
    }
})