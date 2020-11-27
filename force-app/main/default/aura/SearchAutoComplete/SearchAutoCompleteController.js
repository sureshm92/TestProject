({
    searchHandler: function (component, event, helper) {
        const searchString = event.getSource().get('v.value'); //event.target.value;
        if (searchString.length >= 3) {
            //Ensure that not many function execution happens if user keeps typing
            if (component.get('v.inputSearchFunction')) {
                clearTimeout(component.get('v.inputSearchFunction'));
            }
            component.set('v.issearching', true);
            var inputTimer = setTimeout(
                $A.getCallback(function () {
                    helper.searchRecords(component, searchString);
                }),
                1000
            );
            component.set('v.inputSearchFunction', inputTimer);
        } else {
            component.set('v.results', []);
            component.set('v.openDropDown', false);
        }
    },

    optionClickHandler: function (component, event, helper) {
        const selectedId = event.target.closest('li').dataset.id;
        const selectedValue = event.target.closest('li').dataset.value;
        component.set('v.inputValue', selectedValue);
        component.set('v.openDropDown', false);
        component.set('v.issearching', false);
        component.set('v.selectedOption', selectedId);
    },

    oncommit: function (component, event) {
        component.set('v.issearching', false);
        // component.set("v.results", []);
        // component.set("v.inputValue", "");
        // component.set("v.selectedOption", "");
    },

    clearOption: function (component, event, helper) {
        component.set('v.results', []);
        component.set('v.openDropDown', false);
        component.set('v.inputValue', '');
        component.set('v.selectedOption', '');
    }
});
