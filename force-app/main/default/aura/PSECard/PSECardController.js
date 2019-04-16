/**
 * Created by Leonid Bartenev
 */
({
    doInit: function(component, event, hepler){
        var pathItems = [];
        var currentIndex = 100;
        var steps = component.get('v.steps');
        var pse = component.get('v.pse');
        for(var i = 0; i < steps.length; i++){
            if(pse.Status__c === steps[i].value) {
                currentIndex = i;
                break;
            }
        }
        for(i = 0; i < steps.length; i++){
            var item = {
                name: steps[i].label,
                left : 'neutral',
                right : 'neutral',
                state : 'neutral',
                isCurrent : (i === currentIndex)
            };
            if(i <= currentIndex){
                item.left = 'success';
                item.state = 'success';
                if(i !== currentIndex) item.right = 'success';
            }
            pathItems.push(item);
        }
        component.set('v.psePath', pathItems);
    }

})