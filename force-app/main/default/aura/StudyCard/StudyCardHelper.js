/**
 * Created by Nikita Abrazhevitch on 21-Aug-19.
 */

({
    onEmailClick: function (component) {
        let currentStudy = component.get('v.currentStudy');
        var parent = component.get('v.parent');
        parent.find('emailModal').show(currentStudy.trial.Id);
    },

    onFacebookClick: function (component, url, text) {
        window.open('https://www.facebook.com/sharer/sharer.php?u=' + encodeURIComponent(url) + '&quote=' + text);
    },

    onTwitterClick: function (component, url, text) {
        window.open('https://twitter.com/intent/tweet?text=' + text + '&url=' + encodeURIComponent(url));
    },

    onLinkedInClick: function (component, url) {
        window.open('https://www.linkedin.com/shareArticle?mini=true&url=' + encodeURIComponent(url));
    },
});