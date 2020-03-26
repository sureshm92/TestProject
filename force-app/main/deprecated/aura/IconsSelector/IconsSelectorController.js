/**
 * Created by AlexKetch on 6/19/2019.
 */
({
    select: function (component, event, helper) {
     const divSelector  =  component.find('selector');
        $A.util.toggleClass(divSelector, 'selected');
        let sel = component.get('v.selected');
        component.set('v.selected',!sel);
    },
})