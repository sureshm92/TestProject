/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component) {
        var currentStep = component.get('v.currentStep');
        var steps = component.get('v.steps');
        for(var i = 0; i < steps.length; i++){
            if(steps[i] === currentStep){
                component.set('v.currentIndex', i);
                return;
            }
        }
        component.set('v.currentIndex', -1);
    }
})