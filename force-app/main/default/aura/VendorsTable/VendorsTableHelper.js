/**
 * Created by dmytro.fedchyshyn on 28.08.2019.
 */

({
    redirectToUrl: function (component, event) {
        let eUrl= $A.get("e.force:navigateToURL");
        let index = event.currentTarget.dataset.ind;
        eUrl.setParams({
            "url": index
        });
        eUrl.fire();
    }
});