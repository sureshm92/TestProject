/**
 * Created by user on 11.04.2019.
 */
({
    onEmailClick: function (component) {
        let hcpe = component.get('v.currentStudy').hcpe;
        component.find('emailModal').show(hcpe);
    },

    onFacebookClick: function (component, url, text) {
        window.open('https://www.facebook.com/sharer/sharer.php?u=' + url + '&quote=' + text);
    },

    onTwitterClick: function (component, url, text) {
        window.open('https://twitter.com/home?status=' + text + ':%20' + url);
    },

    onLinkedInClick: function (component, url) {
        window.open('https://www.linkedin.com/shareArticle?mini=true&url=' + url);
    }
})