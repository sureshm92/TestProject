({
    togglePassword: function (component, event, helper) {
        component.set("v.showPasswordInput", false);
        component.set("v.showPassword", !component.get("v.showPassword"));
        if(component.get("v.passwordIconColor") === "#999999") {
            component.set("v.passwordIconColor", "#297dfd");
        } else {
            component.set("v.passwordIconColor", "#999999");
        }
        component.set("v.showPasswordInput", true);
    }
})