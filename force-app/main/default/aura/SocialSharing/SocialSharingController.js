/**
 * Created by AlexKetch on 4/2/2019.
 */
({
    onEmailClick: function (component, event, helper) {
        component.find('emailModal').show('test');
    },

    onFacebookClick: function (component, event, helper) {
        debugger;
        let r = component.get('v.linkToShare');
        let ss = component.get('v.facebookIconClass');
        window.open('https://www.facebook.com/sharer/sharer.php?u='+component.get('v.linkToShare')
            , 'popup',
            'width=600,height=600');
    },

    onTwitterClick: function (component, event, helper) {
        window.open('https://twitter.com/home?status=some_text:%20'+component.get('v.linkToShare')
            , 'popup',
            'width=600,height=600');
    },

    onLinkedInClick: function (component, event, helper) {
        window.open('https://www.linkedin.com/shareArticle?mini=true&url='+component.get('v.linkToShare')
            , 'popup',
            'width=600,height=600');
    }
})