/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component) {
        component.set('v.auraId', component.getLocalId());
    },

    doScrollInto: function (component) {
        var anchorId = component.getLocalId();
        document.getElementById(anchorId).scrollIntoView({
            behavior: 'smooth',
            block: 'start'
        });
        /*setTimeout(function () {
            document.location.hash = '#' + anchorId;
        }, 500);*/
        /*if(history.pushState) {
            history.pushState(null, null, '#' + anchorId);
        }
        else {
            document.location.hash = '#' + anchorId;
        }*/
    }


})