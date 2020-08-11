/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, hepler) {
        if(component.get('v.useSentenceFont')){
            var wordsSet = new Set(['PI', 'HCP']);
            var options = component.get('v.options');
            if(!options) return;
            for(var i = 0; i < options.length; i++){
                var option = options[i];
                if(option.label){
                    var label = option.label.trim();
                    var labelItems = label.split(' ');
                    for(var j = 0; j < labelItems.length; j++){
                        if(!wordsSet.has(labelItems[j])){
                            labelItems[j] = labelItems[j].toLowerCase();
                        }
                    }
                    label = labelItems.join(' ');
                    label = label.charAt(0).toUpperCase() + label.slice(1);
                    option.label = label;
                }
            }
        }
        setTimeout($A.getCallback(function() {
            component.set('v.validity', component.find('selectList').get('v.validity'));
        }), 100);
    },

    doValueChange: function (component) {
        var selectList = component.find('selectList');
        component.set('v.validity', component.find('selectList').get('v.validity'));
        component.set('v.isValueChanged',false);
        var changeAction = component.get('v.onchange');
        if(changeAction) $A.enqueueAction(changeAction);
    },

    doShowHelpMessageIfInvalid: function (component) {
        //component.find('selectList').showHelpMessageIfInvalid();
    },

})