/**
 * Created by Leonid Bartenev
 */
({
    updatePathSteps: function (component) {
        var pathItems = [];
        var currentIndex = 100;
        var steps = component.get('v.steps');
        var pe = component.get('v.pe');
        if(!steps) return;
        for(var i = 0; i < steps.length; i++){
            if(pe.Participant_Status__c === steps[i].value) {
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
        component.set('v.pathItems', pathItems);
    },
})