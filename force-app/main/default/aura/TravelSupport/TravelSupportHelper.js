/**
 * Created by dmytro.fedchyshyn on 28.08.2019.
 */

({
    checkOnShowMore: function (component, event) {
        let isShowMore = component.get("v.isShowMore");
        if (isShowMore) {
            component.set("v.isShowMore", false);
        }
    },

    redirectToUrl: function (component, event) {
        let eUrl= $A.get("e.force:navigateToURL");
        eUrl.setParams({
            "url": 'https://uberwork.com.ua'
        });
        component.find('popup').cancel();
        eUrl.fire();
    }
});