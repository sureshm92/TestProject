// rr_community_js
// Author: Leonid Bartenev

//Community Service Module:
window.communityService = (function () {

    var isInitializedFlag = false;
    var isTCAcceptedFlag;
    var communityMode;
    var communityTypes;
    var communityURLPathPrefix;
    var stickyBarEnabled = true;
    var stickyBarTop;
    var debugMode = false; //turn on/off output server stack traces in toast messages
    var showOnLoginMap;
    var alreadyShowedMap = {};
    var isNewSession;
    var language;

    //community service functions:
    var service = {

        initialize: function(component){
            service.executeAction(component, 'getCommunityData', null, function (returnValue) {
                console.log('Mode data: ' + returnValue);
                var communityData = JSON.parse(returnValue);
                communityTypes = communityData.communityTypes;
                communityMode = communityData.communityMode;
                communityURLPathPrefix = communityData.pathPrefix;
                isTCAcceptedFlag = communityData.isTCAccepted;
                language = communityData.language;
                isInitializedFlag = true;
                service.setCookie('RRLanguage', communityData.language, 365);
                console.log('CommunityService initialized:');
                console.log('user mode: ' + communityMode);
                console.log('community types: ' + JSON.stringify(communityTypes));
                console.log('is TC accepted: ' + isTCAcceptedFlag);
                console.log('URL path prefix: ' + communityURLPathPrefix);
                if(!service.isTCAccepted()) {
                    service.navigateToPage('terms-and-conditions?ret=' + service.createRetString());
                }else{
                    $A.get("e.c:EventCommunityInitialized").fire();
                }
            })
        },

        executeAction: function(component, actionName, params, successCallback, errorCallback, finalCallback){
            service.logError(function () {
                var action = component.get('c.' + actionName);
                if(params) action.setParams(params);
                action.setCallback(this, function (response) {
                    try{
                        if (response.getState() === "SUCCESS") {
                            if(successCallback) successCallback(response.getReturnValue());
                        } else {
                            if(errorCallback) errorCallback(response);
                            var errMessage = service.getErrorMessage(response);
                            if(debugMode) errMessage = 'Action: ' + actionName + ', Error: ' + errMessage;
                            throw new Error(errMessage);
                        }
                    }catch (e) {
                        console.error(e);
                        var message = e.message;
                        if(!debugMode) message = e.message.split('\n')[0];
                        service.showErrorToast('ERROR', message);
                        //throw e;
                    }finally {
                        if(finalCallback) finalCallback();
                    }
                });
                $A.enqueueAction(action);
            })
        },

        logError: function(loggedLogic){
            try{
                loggedLogic();
            }catch (e) {
                console.error(e);
                if(debugMode) service.showErrorToast('Error', e.message);
            }
        },

        //Getters/setters:
        getLanguage: function(){
            return language;
        },
        isTCAccepted: function () {
            return isTCAcceptedFlag;
        },
        setTCAccepted: function(){
            isTCAcceptedFlag = true;
        },
        getUserMode: function () {
            return communityMode
        },
        setUserMode: function (userMode) {
            communityMode = userMode;
        },
        getCommunityURLPathPrefix: function () {
            return communityURLPathPrefix
        },
        getCommunityTypes: function () {
            return communityTypes
        },

        isInitialized: function () {
            if(isInitializedFlag){
                if(communityMode !== null){
                    return true;
                }else{
                    service.navigateToPage('no-data-to-display');
                }
            }
            return false;
        },

        getFullPageName: function () {
            if(document.location.href.slice(-1) === '/') return '';
            var urlParts = document.location.href.split('/');
            if(urlParts.length > 0) return urlParts[urlParts.length - 1];
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
                }else{
                    params.push(sURLVariables[i])
                }
            }
            return resURL + params.join('&');
        },

        getPageName: function() {
            var fullPageName = service.getFullPageName();
            var nameParts = fullPageName.split('?');
            return nameParts[0];
        },

        navigateToPage: function(pageName){
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                url: '/' + pageName
            });
            console.log('Navigate to page: ' + pageName);
            urlEvent.fire();
        },

        navigateToHome: function(){
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

        getErrorMessage: function(response) {
            var errorMsg = 'Unknown error';
            var errors = response.getError();
            if (errors && errors[0] && errors[0].message) errorMsg = errors[0].message;
            return errorMsg;
        },

        logErrorFromResponse: function(response){
            if(response.getState() === 'ERROR'){
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

        showSuccessToast: function(title, message, duration){
            service.showToast(title, 'success', message, duration);
        },

        showWarningToast: function(title, message, duration){
            service.showToast(title, 'warning', message, duration);
        },

        showInfoToast: function(title, message, duration){
            service.showToast(title, 'info', message, duration);
        },

        showErrorToastFromResponse: function (response) {
            service.showErrorToast('Error', service.getErrorMessage(response));
        },

        showTour: function(tourName){
            var event = $A.get('e.c:OnboargingSlideTourShow');
            event.setParams({
                tourName: tourName
            });
            event.fire();
            alreadyShowedMap[communityMode] = true;
        },

        isTourAlreadyShowed: function(){
            return alreadyShowedMap[communityMode];
        },

        setShowOnLoginMap: function(showMap){
            showOnLoginMap = showMap;
        },

        setShowOnLogin: function(showOnLigin){
            showOnLoginMap[communityMode] = showOnLigin;
        },

        showTourOnLogin: function(){
            if(!showOnLoginMap) return null;
            return showOnLoginMap[communityMode];
        },

        getShowOnLoginMap: function() {
            return showOnLoginMap;
        },

        setIsNewSession: function(isNew){
            isNewSession = isNew;
        },

        isNewSession: function(){
            return isNewSession;
        },

        setStickyBarPosition: function(){
            setTimeout(
                function () {
                    var mainBarHeight = 50;
                    if(communityTypes.length > 1 && window.innerWidth <= 550) mainBarHeight = 80;
                    document.getElementById('stickyBar').classList.remove('sticky');
                    var stickyBar = document.getElementById('stickyPositionTarget');
                    stickyBarTop = stickyBar.offsetTop - mainBarHeight;
                }, 100
            )
        },

        getCookie: function(cname) {
            var name = cname + "=";
            var decodedCookie = decodeURIComponent(document.cookie);
            var ca = decodedCookie.split(';');
            for(var i = 0; i <ca.length; i++) {
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

        setCookie: function(cname, cvalue, exdays) {
            var d = new Date();
            d.setTime(d.getTime() + (exdays*24*60*60*1000));
            var expires = "expires="+ d.toUTCString();
            document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
        },

        isValidEmail: function(email){
            var re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
            return re.test(String(email).toLowerCase());
        },

        scrollToStickyBar: function(){
            window.scroll({
                top: stickyBarTop,
                behavior: "smooth"
            });
        },

        scrollToTop: function(noSmooth){
            var params = {
                top: 0
            };
            if(!noSmooth) params.behavior = 'smooth';
            window.scroll(params);
        },

        scrollInto: function(tag){
            document.getElementById(tag).scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        },

        stickyBarOnScrollHandler: function () {
            var stickyBar = document.getElementById('stickyBar');
            if(stickyBarTop){
                if (window.pageYOffset >= stickyBarTop) {
                    stickyBar.classList.add('sticky');
                } else {
                    stickyBar.classList.remove('sticky');
                }
            }
        }

    };

    window.onscroll = function() {
        if(stickyBarEnabled) service.stickyBarOnScrollHandler();
    };

    return service;

}());

console.log('RR Community JS loaded');