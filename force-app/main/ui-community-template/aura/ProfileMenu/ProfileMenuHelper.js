/**
 * Created by Leonid Bartenev
 */
({
    logout: function (component) {
        communityService.executeAction(component, 'getLogoutURL', null, function (url) {
            window.location.replace(response.getReturnValue() + "/secur/logout.jsp");
        })
    }
})