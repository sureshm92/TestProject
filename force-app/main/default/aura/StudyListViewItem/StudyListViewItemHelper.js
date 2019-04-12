/**
 * Created by user on 11.04.2019.
 */
({
    onEmailClick : function (component) {
        let hcpe = component.get('v.currentStudy').hcpe;
        component.find('emailModal').show(hcpe);
    },

    onFacebookClick: function (component, url) {
        window.open('https://www.facebook.com/sharer/sharer.php?u=' + url + '&quote=some_text');
    },

    onTwitterClick: function (component, url) {
        window.open('https://twitter.com/home?status=some_text:%20' + url);
    },

    onLinkedInClick: function (component, url) {
        window.open('https://www.linkedin.com/shareArticle?mini=true&url=' + url);
    }
})