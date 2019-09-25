/**
 * Created by Yehor Dobrovolskyi
 */
({
    checkClick: function (component) {
        if (!component.get('v.isClicked')) {
            component.set('v.isClicked', !component.get('v.isClicked'));
        } else {
            component.set('v.isSecondClicked', true);
        }
    }
});