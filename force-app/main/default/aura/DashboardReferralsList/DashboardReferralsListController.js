/**
 * Created by Leonid Bartenev
 */
({
    doAccept: function (component, event, helper) {
        var peId =  event.currentTarget.dataset.peId;
        var peList = component.get('v.peList');
        for(var i = 0; i < peList.length; i++){
            var pe = peList[i].data;
            if(pe.Id === peId){
                var rootComponent = component.get('v.parent');
                var changePEStatusAction = rootComponent.find('changePEStatusByPIAction');
                changePEStatusAction.execute(pe, 'Referral Accepted', null, null, rootComponent);
                break
            }
        }
    }
})