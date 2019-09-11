/**
 * Created by dmytro.fedchyshyn on 28.08.2019.
 */

({
    makeUnique: function (component, event) {
        let values = component.find('checkBoxBtn');
        if (values.length > 1)
        {
            let value = event.getSource().get('v.value');
            let isChecked = event.getSource().get('v.checked');
            values.forEach(function (item) {
                if (item.get('v.value') !== value && item.get("v.checked") === true) {
                    item.set("v.checked", false);
                }
            });
            component.set("v.selectedVendor", isChecked ? value : '');
        } else {
            let value = event.getSource().get('v.value');
            let isChecked = event.getSource().get('v.checked');
            component.set("v.selectedVendor", isChecked ? value : '');
        }
    }
});