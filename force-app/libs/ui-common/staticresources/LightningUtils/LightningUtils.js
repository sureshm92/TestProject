// Author: Leonid Bartenev

//$LU Service Module:
window.$LU = (function () {

    //community service functions:
    let service = {

        executeAction: function (component, actionName, params, successCallback, errorCallback, finalCallback) {
            service.logError(function () {
                var action = component.get('c.' + actionName);
                if (params) action.setParams(params);
                action.setCallback(this, function (response) {
                    try {
                        if (response.getState() === "SUCCESS") {
                            if (successCallback) successCallback(response.getReturnValue());
                        } else {
                            if (errorCallback) errorCallback(response);
                            var errMessage = service.getErrorMessage(response);
                            if (debugMode) errMessage = 'Action: ' + actionName + ', Error: ' + errMessage;
                            throw new Error(errMessage);
                        }
                    } catch (e) {
                        console.error(e);
                        var message = e.message;
                        if (!debugMode) message = e.message.split('\n')[0];
                        service.showErrorToast('ERROR', message);
                        //throw e;
                    } finally {
                        if (finalCallback) finalCallback();
                    }
                });
                $A.enqueueAction(action);
            })
        },

        deleteCookies: function (preventedCookies) {
            for (let i in preventedCookies) {
                let cookieDelete = preventedCookies[i] + "=;expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";
                console.log('cookieDelete: ' + cookieDelete);
                document.cookie = cookieDelete;

                cookieDelete = 'LSKey[c]' + cookieDelete;
                console.log('cookieDelete: ' + cookieDelete);
                document.cookie = cookieDelete;
            }
        },

        logError: function (loggedLogic) {
            try {
                loggedLogic();
            } catch (e) {
                console.error(e);
                if (debugMode) service.showErrorToast('Error', e.message);
            }
        },

        getFullPageName: function () {
            if (document.location.href.slice(-1) === '/') return '';
            var urlParts = document.location.href.split('/');
            if (urlParts.length > 0) return urlParts[urlParts.length - 1];
        },

        getUrlParameter: function (sParam) {
            var sPageURL = document.location.search.substring(1),
                sURLVariables = sPageURL.split('&'),
                sParameterName,
                i;
            for (i = 0; i < sURLVariables.length; i++) {
                sParameterName = sURLVariables[i].split('=');
                if (sParameterName[0] === sParam) {
                    return sParameterName[1] === undefined ? '' : sParameterName[1];
                }
            }
        },

        replaceUrlParameter: function (sParam, value) {
            var urlWithoutParams = document.location.href.split('?')[0];
            var sPageURL = document.location.search.substring(1),
                sURLVariables = sPageURL.split('&'),
                sParameterName,
                i;
            var resURL = urlWithoutParams + '?';
            var params = [];
            for (i = 0; i < sURLVariables.length; i++) {
                sParameterName = sURLVariables[i].split('=');
                if (sParameterName[0] === sParam) {
                    params.push(sParameterName[0] + '=' + value);
                } else {
                    params.push(sURLVariables[i])
                }
            }
            return resURL + params.join('&');
        },

        getPageName: function () {
            var fullPageName = service.getFullPageName();
            var nameParts = fullPageName.split('?');
            return nameParts[0];
        },

        navigateToPage: function (pageName) {
            var urlEvent = $A.get('e.force:navigateToURL');
            urlEvent.setParams({
                url: '/' + pageName
            });
            urlEvent.fire();
        },

        navigateToHome: function () {
            service.navigateToPage('');
        },

        createRetString: function () {
            return encodeURIComponent(service.getFullPageName());
        },

        getRetPage: function (retString) {
            return decodeURIComponent(retString);
        },

        getErrorMessage: function (response) {
            var errorMsg = 'Unknown error';
            var errors = response.getError();
            if (errors && errors[0] && errors[0].message) errorMsg = errors[0].message;
            return errorMsg;
        },

        logErrorFromResponse: function (response) {
            if (response.getState() === 'ERROR') {
                console.log('Aura Response Error: ' + service.getErrorMessage(response));
            }
        },

        showToast: function (title, type, message, duration) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: title,
                message: message,
                type: type,
                duration: duration ? duration : undefined,
                mode: duration ? 'dismissible' : 'sticky'
            });
            toastEvent.fire();
        },

        showErrorToast: function (title, errorMessage, duration) {
            service.showToast(title, "error", errorMessage, duration);
        },

        showSuccessToast: function (title, message, duration) {
            service.showToast(title, 'success', message, duration);
        },

        showWarningToast: function (title, message, duration) {
            service.showToast(title, 'warning', message, duration);
        },

        showInfoToast: function (title, message, duration) {
            service.showToast(title, 'info', message, duration);
        },

        showErrorToastFromResponse: function (response) {
            service.showErrorToast('Error', service.getErrorMessage(response));
        },

        getCookie: function (cname) {
            console.log('in getCookie function');
            console.log('cname: ' + cname);

            if (preventedCookies.indexOf(cname) !== -1) {
                console.log(cname + ' cookie ignored get');
                return "";
            }

            var name = cname + "=";
            var decodedCookie = decodeURIComponent(document.cookie);
            var ca = decodedCookie.split(';');
            for (var i = 0; i < ca.length; i++) {
                var c = ca[i];
                while (c.charAt(0) === ' ') {
                    c = c.substring(1);
                }
                if (c.indexOf(name) === 0) {
                    return c.substring(name.length, c.length);
                }
            }
            return "";
        },

        setCookie: function (cname, cvalue, exdays) {
            console.log('in setCookie function');
            console.log('cname: ' + cname);
            console.log('cvalue: ' + cvalue);

            if (preventedCookies.indexOf(cname) !== -1) {
                console.log(cname + ' cookie ignored set');
                return;
            }

            var d = new Date();
            d.setTime(d.getTime() + (exdays * 24 * 60 * 60 * 1000));
            var expires = "expires=" + d.toUTCString();
            document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
        },

        isValidEmail: function (email) {
            var re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
            return re.test(String(email).toLowerCase());
        },

        scrollToTop: function (noSmooth) {
            var params = {
                top: 0
            };
            if (!noSmooth) params.behavior = 'smooth';
            window.scroll(params);
        },

        scrollInto: function (tag) {
            document.getElementById(tag).scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        },

    };

    return service;

}());

console.log('Lightning Utils loaded!');
