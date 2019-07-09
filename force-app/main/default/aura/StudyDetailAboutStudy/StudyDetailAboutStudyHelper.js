/**
 * Created by user on 28-Jun-19.
 */

({
    onEmailClick: function (component) {
        let currentStudy = component.get('v.studyDetail');
        component.find('emailModal').show(currentStudy.trial.Id);
    },

    onFacebookClick: function (component, url, text) {
        window.open('https://www.facebook.com/sharer/sharer.php?u=' + encodeURIComponent(url) + '&quote=' + text);
    },

    onTwitterClick: function (component, url, text) {
        window.open('https://twitter.com/home?status=' + text + ':%20' + encodeURIComponent(url));
    },

    onLinkedInClick: function (component, url) {
        window.open('https://www.linkedin.com/shareArticle?mini=true&url=' + encodeURIComponent(url));
    }
});