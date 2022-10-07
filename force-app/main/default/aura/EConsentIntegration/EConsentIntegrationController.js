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
                
                if(!initData.userProfilePermission){
                     component.set('v.userPermission', 'Disabled');
                }
                if(component.get('v.userPermission') == 'View'){
                     component.set('v.isreadonly', true);
                }else{
                     component.set('v.isreadonly', false);
                }
                component.find('spinner').hide();
            }
        );
    }
})