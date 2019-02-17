/**
 * Created by Leonid Bartenev
 */
({
    doClick: function (component) {
        try{
            var parentComponent = component.get('v.parentComponent');
            var anchor = component.get('v.anchor');
            parentComponent.find(anchor).scrollInto();
        }catch (e) {
            console.error(e);
        }
    }
})