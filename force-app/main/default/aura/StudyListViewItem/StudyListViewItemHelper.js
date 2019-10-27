/**
 * Created by user on 11.04.2019.
 */
({
    onEmailClick: function (component) {
        let currentStudy = component.get('v.currentStudy');
        component.find('emailModal').show(currentStudy.trial.Id);
    },

    onFacebookClick: function (component, url, text) {
        window.open('https://www.facebook.com/sharer/sharer.php?u=' + encodeURIComponent(url) + '&quote=' + text);
    },

    onTwitterClick: function (component, url, text) {
        window.open('https://twitter.com/home?status=' + text + ':%20' + encodeURIComponent(url));
    },

    onLinkedInClick: function (component, url) {
        window.open('https://www.linkedin.com/shareArticle?mini=true&url=' + encodeURIComponent(url));
    },

    doUpdateStudyTitle: function (component, helper) {
        var t0 = performance.now();
        if (component.isValid()) {
            var studyTitles = document.getElementsByClassName("study-title");
            for (var i = 0; i < studyTitles.length; i++) {
                var studyTitle = studyTitles.item(i);
                if (studyTitle != null) {
                    if (window.innerWidth < 768) {
                        this.clampLine(studyTitle, 3);
                    } else {
                        this.clampLine(studyTitle, 1);
                    }
                }
            }
            if (component.get('v.userMode') == 'PI') {
                var instructions = document.getElementsByClassName("driving-instructions");
                for (var i = 0; i < instructions.length; i++) {
                    var instruction = instructions.item(i);
                    if (instruction != null) {
                        this.clampLine(instruction, 3);
                    }
                }
            }
        }
        var t1 = performance.now();
        console.log("Call to doSomething took " + (t1 - t0) + " milliseconds.");
    },

    clampLine: function (studyTitle, numberOfRows) {
        var width = studyTitle.offsetWidth;
        if (width === '0' || !width) {
            width = studyTitle.parentNode.offsetWidth;
        }
        var innerText = studyTitle.innerText.replace(/\n/g, ' ');
        studyTitle.innerHTML = '';
        var text = innerText.split(' ');
        var currentWord = 0;
        if (numberOfRows > 1) {
            parentLoop:
                for (let i = 0; i < numberOfRows - 1; i++) {
                    var measure = document.createElement('span');
                    measure.style.whiteSpace = 'nowrap';
                    measure.style.display = 'inline-block';
                    studyTitle.appendChild(measure);
                    for (let j = currentWord; j < text.length; j++) {
                        measure.appendChild(document.createTextNode(text[j] + " "));
                        if (measure.getBoundingClientRect().width > width) {
                            measure.removeChild(measure.lastChild);
                            continue parentLoop;
                        }
                        currentWord++;
                    }
                }
        }
        var lastElement = document.createElement('span');
        for (let i = currentWord; i < text.length; i++) {
            lastElement.appendChild(document.createTextNode(text[i] + " "));
        }
        lastElement.style.display = 'inline-block';
        lastElement.style.overflow = 'hidden';
        lastElement.style.textOverflow = 'ellipsis';
        lastElement.style.whiteSpace = 'nowrap';
        lastElement.style.width = '100%';
        studyTitle.appendChild(lastElement);
    },

    setCoordinates:function(component,cmp){
        component.set('v.mapMarkers',[{location:{
                'Latitude': cmp.BillingLatitude,
                'Longitude': cmp.BillingLongitude
            },
            title: 'Location Address',
            description: cmp.BillingCountry + ' ' + cmp.BillingStreet + ' ' + cmp.BillingCity + ' ' + cmp.BillingStateCode + ' ' + cmp.BillingPostalCode
        }]);
        if(cmp.BillingLatitude && cmp.BillingLongitude) {
            component.set('v.zoomLevel', 17);
        } else{
            component.set('v.zoomLevel', 0);
        }
    },

    waitAccountCheckResult: function(component, tmpAccountId, iteration){
        var helper = this;
        if(iteration === 15) {
            var acc = component.get('v.editedAccount');
            acc.BillingGeocodeAccuracy = null;
            acc.BillingLongitude = null;
            acc.BillingLatitude = null;
            component.set('v.editedAccount', acc);
            component.set('v.showPopUpSpinner', false);
            helper.setCoordinates(component, acc);
            communityService.executeAction(component, 'deleteTmpAccount', {
                tmpAccountId: tmpAccountId
            });
            return;
        }
        communityService.executeAction(component, 'getTmpAccount', {
            tmpAccountId: tmpAccountId
        }, function (tmpAccount) {
            if(!tmpAccount.BillingGeocodeAccuracy){
                window.setTimeout(
                    $A.getCallback(function() {
                        helper.waitAccountCheckResult(component, tmpAccountId, iteration + 1);
                    }), 500
                );
            }else{
                var acc = component.get('v.editedAccount');
                acc.BillingGeocodeAccuracy = tmpAccount.BillingGeocodeAccuracy;
                acc.BillingLongitude = tmpAccount.BillingLongitude;
                acc.BillingLatitude = tmpAccount.BillingLatitude;
                component.set('v.editedAccount', acc);
                component.set('v.showPopUpSpinner', false);
                helper.setCoordinates(component, acc);
            }
        });
    }


})