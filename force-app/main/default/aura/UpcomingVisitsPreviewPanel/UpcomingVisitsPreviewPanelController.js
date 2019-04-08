/**
 * Created by Igor Malyuta on 08.04.2019.
 */
({
    onBookTravel : function (component, event, helper) {
        component.find('popup').show();
    },

    onClickOk : function (component, event, helper) {
        //redirect to url in new window
        window.location.href = 'https://www.iqvia.com/';
    }
})