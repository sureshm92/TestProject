/**
 * Created by Yehor Dobrovolskyi
 */
({
    valueChange: function (component, event, helper) {
        debugger;
        component.set('v.bypass', false);
        let value = event.getSource().get('v.value');
        if (!value) {
            component.set('v.displayFooter', true);
            var evt = component.getEvent('setDefaultPage');
            evt.fire();
            return;
        }
        component.set('v.displayFooter', false);
        value = value.toUpperCase();
        console.log('valueSearch', value);
        let originalItems = component.get('v.originalItems');
        let criterias = component.get('v.searchCriterias');
        let filteredItems = originalItems.filter(checkCriteria);
        //component.set('v.bypass',true);
        component.set('v.displayedItems', filteredItems);
        //component.set('v.bypass',false);
        function checkCriteria(e) {
            debugger;
            let result = false;
            if (!value) {
                result = true;
            }
            for (let i = 0; i < criterias.length; i++) {
                let index = e.csValues.findIndex(x => x.name.toUpperCase() == criterias[i].toUpperCase());
                if (index > -1) {
                    if (e.csValues[index].Value) {
                        result = e.csValues[index].Value.toUpperCase().indexOf(value) > -1;
                        if (result) return result;
                    }
                }

            }
            return result;

        }

    },
})