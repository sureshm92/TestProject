// rr_community_js
// Author: Leonid Bartenev

//Community Service Module:
window.communityService = (function () {

    var isInitializedFlag = false;
    var isTCAcceptedFlag;
    var communityMode;
    var communityDelegateId;
    var communityURLPathPrefix;
    var isDelegate;
    var stickyBarEnabled = true;
    var stickyBarTop;
    var debugMode = false; //turn on/off output server stack traces in toast messages
    var showOnLoginMap;
    var showCurrentTourOnLogin;
    var alreadyShowedMap = {};
    var isNewSession;
    var language;
    var preventedCookies = [];
    var participantState;
    var baseUrl;
    var currentUserMode;
    var allUserModes;
    var showPastStudies;

    //community service functions:
    var service = {

        initialize: function (component) {
            service.executeAction(component, 'getCommunityData', null, function (returnValue) {
                console.log('Mode data: ' + returnValue);
                var communityData = JSON.parse(returnValue);
                preventedCookies = communityData.preventedCookies;
                service.deleteCookies(preventedCookies);
                console.log('preventedCookies: ' + JSON.stringify(preventedCookies));
                communityMode = communityData.communityMode;
                communityDelegateId = communityData.communityDelegateId;
                isDelegate = communityData.isDelegate;
                communityURLPathPrefix = communityData.pathPrefix;
                isTCAcceptedFlag = communityData.isTCAccepted;
                language = communityData.language;
                participantState = communityData.state;
                baseUrl = communityData.baseUrl;
                isInitializedFlag = true;
                allUserModes = communityData.allUserModes;
                showPastStudies = communityData.showPastStudies;
                service.setCurrentCommunityMode(communityData.currentUserMode);
                service.setCookie('RRLanguage', communityData.language, 365);
                console.log('CommunityService initialized:');
                console.log('is TC accepted: ' + isTCAcceptedFlag);
                console.log('URL path prefix: ' + communityURLPathPrefix);
                component.init();
                if (!service.isTCAccepted()) {
                    service.navigateToPage('terms-and-conditions?ret=' + service.createRetString());
                } else {
                    $A.get('e.c:EventCommunityInitialized').fire();
                }
            })
        },

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

        //Getters/setters:
        isShowPastStudies: function(){
            return showPastStudies;
        },

        getTemplateProperty(propertyName){
            if(this.getCurrentCommunityMode().template.properties) return this.getCurrentCommunityMode().template.properties[propertyName];
            return null;
        },

        getCurrentCommunityMode: function(){
            return currentUserMode;
        },

        setCurrentCommunityMode: function(mode){
            currentUserMode = mode;
            service.setThemeCSS();
            if(mode.template.needRedirect){
                document.location.href = template.communityURL + '/' + service.getFullPageName();
            }
        },

        setThemeCSS(){
            let cssLink = document.querySelector('link[href*="Community_CSS_Stub"]');
            try{
                if(cssLink) cssLink.setAttribute('href', service.getTemplateProperty('ThemeCSS'));
            }catch (e) {
                console.log(e);
            }

        },

        getAllUserModes: function(){
            return allUserModes
        },

        getParticipantState: function(){
            return participantState;
        },

        getLanguage: function(){
            return language;
        },
        isTCAccepted: function () {
            return isTCAcceptedFlag;
        },
        setTCAccepted: function () {
            isTCAcceptedFlag = true;
        },
        getUserMode: function () {
            return currentUserMode.userMode
        },
        getDelegateId: function () {
            return currentUserMode.currentHCPDelegate
        },
        isDelegate: function(){
            return isDelegate;
        },
        getCommunityURLPathPrefix: function () {
            return communityURLPathPrefix
        },

        isInitialized: function () {
            if (isInitializedFlag) {
                if (communityMode !== null) {
                    return true;
                } else {
                    service.navigateToPage('no-data-to-display');
                }
            }
            return false;
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
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                url: '/' + pageName
            });
            console.log('Navigate to page: ' + pageName);
            urlEvent.fire();
        },

        navigateToHome: function () {
            service.navigateToPage('');
        },

        redirectToPage: function (pageName) {
            console.log('Redirect to page: ' + pageName);
            document.location.href = communityURLPathPrefix + '/' + pageName;
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

        showTour: function (tourName) {
            var event = $A.get('e.c:OnboargingSlideTourShow');
            event.fire();
            alreadyShowedMap[communityMode] = true;
        },

        isTourAlreadyShowed: function () {
            return alreadyShowedMap[communityMode];
        },

        setShowOnLoginMap: function (showMap) {
            //todo remove
        },

        setShowOnLogin: function (showOnLigin) {
            showCurrentTourOnLogin = showOnLigin;
        },

        showTourOnLogin: function () {
            return showCurrentTourOnLogin;
        },

        getShowOnLoginMap: function () {
            return showOnLoginMap;
        },

        setIsNewSession: function (isNew) {
            isNewSession = isNew;
        },

        isNewSession: function () {
            return isNewSession;
        },

        setStickyBarPosition: function () {
            setTimeout(
                function () {
                    var mainBarHeight = 50;
                    if (allUserModes.length > 1 && window.innerWidth <= 550) mainBarHeight = 80;
                    document.getElementById('stickyBar').classList.remove('sticky');
                    var stickyBar = document.getElementById('stickyPositionTarget');
                    stickyBarTop = stickyBar.offsetTop - mainBarHeight;
                }, 100
            )
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

        scrollToStickyBar: function () {
            window.scroll({
                top: stickyBarTop,
                behavior: "smooth"
            });
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

        stickyBarOnScrollHandler: function () {
            var stickyBar = document.getElementById('stickyBar');
            if (stickyBarTop) {
                if (window.pageYOffset >= stickyBarTop) {
                    stickyBar.classList.add('sticky');
                } else {
                    stickyBar.classList.remove('sticky');
                }
            }
        },

        logOut: function () {
            window.location.replace(baseUrl + '/secur/logout.jsp');
        }
    };

    window.onscroll = function () {
        if (stickyBarEnabled) service.stickyBarOnScrollHandler();
    };

    return service;

}());

console.log('RR Community JS loaded');
