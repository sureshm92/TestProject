/**
 * Created by user on 28-Jun-19.
 */

({
    onEmailClick: function (component) {
        var mode = component.get('v.userMode');
        var currentStudy = component.get('v.studyDetail');
        var whatId = mode === 'Participant' ? currentStudy.pe.Id : currentStudy.trial.Id;

        component.get('v.parent').find('shareModal').show(whatId);
    },

    onFacebookClick: function (component, url, text) {
        window.open(
            'https://www.facebook.com/sharer/sharer.php?u=' +
                encodeURIComponent(url) +
                '&quote=' +
                text
        );
    },

    onTwitterClick: function (component, url, text) {
        window.open(
            'https://twitter.com/intent/tweet?text=' + text + '&url=' + encodeURIComponent(url)
        );
    },

    onLinkedInClick: function (component, url) {
        window.open(
            'https://www.linkedin.com/shareArticle?mini=true&url=' + encodeURIComponent(url)
        );
    }
});