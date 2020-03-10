/**
 * Created by AlexKetch on 4/2/2019.
 */
({
    doInit: function(component, event, helper) {

    },

    onEmailClick: function (component, event, helper) {
        component.find('emailModal').show(component.get('v.whatId'), null);
    },

    onFacebookClick: function (component, event, helper) {
        let r = component.get('v.linkToShare');
        let ss = component.get('v.facebookIconClass');
        window.open('https://www.facebook.com/sharer/sharer.php?u='+encodeURIComponent(component.get('v.linkToShare'))
            , 'popup',
            'width=600,height=600');
    },

    onTwitterClick: function (component, event, helper) {
        window.open('https://twitter.com/intent/tweet/?url='+encodeURIComponent(component.get('v.linkToShare'))
            , 'popup',
            'width=600,height=600');
    },

    onLinkedInClick: function (component, event, helper) {
        window.open('https://www.linkedin.com/shareArticle?mini=true&url='+encodeURIComponent(component.get('v.linkToShare'))
            , 'popup',
            'width=600,height=600');

    }
})