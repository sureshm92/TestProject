/**
 * Created by Leonid Bartenev
 */
({
    logout: function (component) {
        communityService.executeAction(component, 'getLogoutURL', null, function (url) {
            window.location.replace(url + "/secur/logout.jsp");
        })
    }
})