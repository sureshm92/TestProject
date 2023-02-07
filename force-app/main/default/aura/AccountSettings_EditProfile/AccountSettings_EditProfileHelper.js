({
    setPersonSnapshot: function (component) {
        let personWrapper = component.get('v.personWrapper');
        if (!personWrapper.firstName) personWrapper.firstName = '';
        if (!personWrapper.middleName) personWrapper.middleName = '';
        if (!personWrapper.lastName) personWrapper.lastName = '';
        if (!personWrapper.dateBirth) personWrapper.dateBirth = '';
        if (!personWrapper.gender) personWrapper.gender = '';
        if (!personWrapper.homePhone) personWrapper.homePhone = '';
        if (!personWrapper.mobilePhone) personWrapper.mobilePhone = '';
        if (!personWrapper.fax) personWrapper.fax = '';
        if (!personWrapper.mailingCC) personWrapper.mailingCC = '';
        if (!personWrapper.mailingSC) personWrapper.mailingSC = '';
        if (!personWrapper.mailingCountry) personWrapper.mailingCountry = '';
        if (!personWrapper.mailingStreet) personWrapper.mailingStreet = '';
        if (!personWrapper.mailingCity) personWrapper.mailingCity = '';
        if (!personWrapper.mailingState) personWrapper.mailingState = '';
        if (!personWrapper.zip) personWrapper.zip = '';
        if (!personWrapper.suffix) personWrapper.suffix = '';
        if (!personWrapper.nickname) personWrapper.nickname = '';
        if (!personWrapper.phoneType) personWrapper.phoneType = '';
        if (!personWrapper.prefix) personWrapper.prefix = '';
        if (!personWrapper.birthDay) personWrapper.birthDay = '';
        if (!personWrapper.birthMonth) personWrapper.birthMonth = '';
        if (!personWrapper.birthYear) personWrapper.birthYear = '';
        if (!personWrapper.age) personWrapper.age = '';

        component.set('v.personSnapshot', JSON.stringify(personWrapper));
        component.set('v.isStateChanged', false);
    },
    //DOB
    setDD: function (component, event, helper, onchange) {
        var opt = [];
        var lastDay = component.get('v.lastDay');
        for (var i = 1; i <= lastDay; i++) {
            var x = i.toString();
            if (i < 10) x = '0' + x;
            opt.push({ label: x, value: x });
        }
        component.set('v.optionsDD', opt);
        if (onchange == 'onchange') {
            component.set('v.showDay', !component.get('v.showDay'));
            component.set('v.showDay', !component.get('v.showDay'));
        }
    },
    setMM: function (component, event, helper) {
        var opt = [];
        opt.push({ label: 'January', value: '01' });
        opt.push({ label: 'February', value: '02' });
        opt.push({ label: 'March', value: '03' });
        opt.push({ label: 'April', value: '04' });
        opt.push({ label: 'May', value: '05' });
        opt.push({ label: 'June', value: '06' });
        opt.push({ label: 'July', value: '07' });
        opt.push({ label: 'August', value: '08' });
        opt.push({ label: 'September', value: '09' });
        opt.push({ label: 'October', value: '10' });
        opt.push({ label: 'November', value: '11' });
        opt.push({ label: 'December', value: '12' });
        component.set('v.optionsMM', opt);
        helper.loadMMLeapYear(component, event, helper);
    },
    setYYYY: function (component, event, helper) {
        var opt = [];
        for (var i = parseInt(new Date().getFullYear()); i >= 1900; i--) {
            opt.push({ label: i.toString(), value: i.toString() });
        }
        component.set('v.optionsYYYY', opt);
        var format = component.get('v.dobConfig');
        if (format != undefined) {
            component.set('v.showDay', format.includes('DD'));
            component.set('v.showMonth', format.includes('MM'));
        }
        helper.setLastDay(component, event, helper);

        if (!component.get('v.showDay')) {
            helper.setMinMaxAge(component, event, helper);
        }
    },
    YYYYChange: function (component, event, helper) {
        var personWrapper = component.get('v.personWrapper');
        component.set('v.valueAge', null);
        //helper.setDD(component, event, helper);
        helper.setLastDay(component, event, helper);
        var studyDobFormat = component.get('v.dobConfig');

        if (studyDobFormat == 'DD-MM-YYYY') {
            helper.participantAge(component, event, helper);
        } else {
            helper.setMinMaxAge(component, event, helper);
        }
        helper.validateDOB(component, event, helper);
        helper.doCheckDOB(component, event, helper);
        //helper.setPlaceHolder(component,event,helper);
    },
    isLeapYear: function (component, event, helper) {
        var personWrapper = component.get('v.personWrapper');
        if (personWrapper != undefined && personWrapper != null && personWrapper != '') {
            var valYYY = personWrapper.birthYear;
            if (parseInt(valYYY) % 400 == 0) {
                return true;
            }
            if (parseInt(valYYY) % 100 == 0) {
                return false;
            }
            if (parseInt(valYYY) % 4 == 0) {
                return true;
            }
            return false;
        }
    },
    MMChange: function (component, event, helper) {
        var personWrapper = component.get('v.personWrapper');
        component.set('v.valueAge', null);

        var maxDayMonths = ['01', '03', '05', '07', '08', '10', '12'];
        var minDayMonths = ['04', '06', '09', '11'];
        component.set('v.lastDay', 31);
        if (maxDayMonths.includes(personWrapper.birthMonth)) {
            component.set('v.lastDay', 31);
        } else if (minDayMonths.includes(personWrapper.birthMonth)) {
            component.set('v.lastDay', 30);
        }
        //helper.setDD(component, event, helper);
        helper.setLastDay(component, event, helper);
        var studyDobFormat = component.get('v.dobConfig');

        if (studyDobFormat == 'DD-MM-YYYY') {
            helper.participantAge(component, event, helper);
        } else {
            helper.setMinMaxAge(component, event, helper);
        }
        helper.validateDOB(component, event, helper);
        helper.doCheckDOB(component, event, helper);
        //helper.setPlaceHolder(component,event,helper);
    },
    DDChange: function (component, event, helper) {
        helper.participantAge(component, event, helper);
        helper.getCountryStateCode(component, event, helper);
        helper.doCheckDOB(component, event, helper);
        helper.validateDOB(component, event, helper);
    },
    setLastDay: function (component, event, helper) {
        var personWrapper = component.get('v.personWrapper');
        if (personWrapper.birthMonth == '02') {
            if (personWrapper.birthMonth == '----' || helper.isLeapYear(component, event, helper)) {
                component.set('v.lastDay', 29);
            } else {
                component.set('v.lastDay', 28);
            }
        }
        if (parseInt(personWrapper.birthDay) > component.get('v.lastDay')) {
            personWrapper.birthDay = component.get('v.lastDay').toString();
            component.set('v.personWrapper', personWrapper);
        }
        var onchange = 'onchange';
        helper.setDD(component, event, helper, onchange);
    },
    setMinMaxAge: function (component, event, helper) {
        var personWrapper = component.get('v.personWrapper');
        var format = component.get('v.dobConfig');
        var partDOB = '';
        if (format != 'DD-MM-YYYY') {
            if (format == 'MM-YYYY') {
                partDOB =
                    personWrapper.birthYear +
                    '-' +
                    personWrapper.birthMonth +
                    '-' +
                    component.get('v.lastDay');
            } else if (format == 'YYYY') {
                partDOB = personWrapper.birthYear + '-12-31';
            }
            if (!partDOB.includes('--')) {
                var dob = new Date(partDOB);
                var month_diff = Date.now() - dob.getTime();
                var age_dt = new Date(month_diff);
                var year = age_dt.getUTCFullYear();
                if (year - 1970 >= 0) {
                    var age = Math.abs(year - 1970);
                    component.set('v.ageStart', age);
                    var endAge = age;
                    if (
                        (dob.getMonth() == new Date().getMonth() &&
                            dob.getDate() != new Date().getDate()) ||
                        format == 'YYYY'
                    ) {
                        endAge++;
                    }
                    component.set('v.ageEnd', endAge);
                    helper.setAge(component, event, helper);
                } else {
                    component.set('v.ageStart', '0');
                    component.set('v.ageEnd', '0');
                    helper.setAge(component, event, helper);
                }
            }
        }
    },
    setAge: function (component, event, helper) {
        var opt = [];
        var ageStart = parseInt(component.get('v.ageStart'));
        var ageEnd = parseInt(component.get('v.ageEnd'));

        for (var i = ageStart; i <= ageEnd; i++) {
            opt.push({ label: i.toString(), value: i.toString() });
        }
        component.set('v.ageOpt', opt);
    },
    ageChange: function (component, event, helper) {
        var age = component.get('v.valueAge');
        component.set('v.valueAge', age);
        helper.getCountryStateCode(component, event, helper);
        //helper.setPlaceHolder(component,event,helper);
        var num = parseFloat(age).toFixed(2);
        var personWrapper = component.get('v.personWrapper');
        personWrapper.age = num;
        component.set('v.personWrapper', personWrapper);
        helper.doCheckDOB(component, event, helper);
    },
    validateDOB: function (component, event, helper) {
        var format = component.get('v.dobConfig');
        component.set('v.futureDate', false);
        var personWrapper = component.get('v.personWrapper');

        if (format == 'DD-MM-YYYY' || format == 'MM-YYYY') {
            let dt;
            if (format == 'DD-MM-YYYY') {
                dt =
                    personWrapper.birthYear +
                    '-' +
                    personWrapper.birthMonth +
                    '-' +
                    personWrapper.birthDay;
            } else {
                dt = personWrapper.birthYear + '-' + personWrapper.birthMonth + '01';
            }
            var today = new Date();
            var dd = 1;
            if (format == 'DD-MM-YYYY') {
                dd = String(today.getDate()).padStart(2, '0');
            }
            var mm = String(today.getMonth() + 1).padStart(2, '0');
            var yyyy = today.getFullYear();
            today = yyyy + '-' + mm + '-' + dd;
            if (dt > today && format == 'DD-MM-YYYY') {
                component.set('v.futureDate', true);
                if (new Date().getMonth() < new Date(dt).getMonth()) {
                    component.set('v.invalidDOB', true);
                    var DateMMErr = $A.get("$Label.c.PP_future_date_error_month");
                    component.set('v.futureDateMMErr', DateMMErr);
                }
                var DateDDErr = $A.get("$Label.c.PP_future_date_error_day");
                component.set('v.futureDateDDErr', DateDDErr);
            } else if (dt > today && format == 'MM-YYYY') {
                component.set('v.futureDate', true);
                component.set('v.invalidDOB', true);
                var DateMMErr = $A.get("$Label.c.PP_future_date_error_month");
                component.set('v.futureDateMMErr', DateMMErr);
            } else {
                component.set('v.invalidDOB', false);
                component.set('v.futureDate', false);
                component.set('v.futureDateDDErr', '');
                component.set('v.futureDateMMErr', '');
            }
        }
    },

    splitAddress: function (component, address) {
        var addLst = address.split('\n');
        var add1 = '';
        var add2 = '';
        if (addLst) {
            var s = addLst.length;
            debugger;
            if (s > 0) {
                for (var i in addLst) {
                    if (parseInt(i) < 1) add1 = add1 + addLst[i];
                    else add2 = add2 + ' ' + addLst[i];
                }
                component.set('v.addressLine1', add1);
                component.set('v.addressLine2', add2);
            } else
                component.set(
                    'v.addressLine1',
                    initData.contactSectionData.personWrapper.mailingStreet
                );
        } else
            component.set(
                'v.addressLine1',
                initData.contactSectionData.personWrapper.mailingStreet
            );
    },
    doCheckDOB: function (component, event, helper) {
        var invalidDOB = component.get('v.invalidDOB');
        if (component.get('v.dobConfig') == 'DD-MM-YYYY') {
            if (
                component.get('v.personWrapper.birthYear') === null ||
                component.get('v.personWrapper.birthYear') == '' ||
                component.get('v.personWrapper.birthMonth') === null ||
                component.get('v.personWrapper.birthMonth') == '' ||
                component.get('v.personWrapper.birthDay') === null ||
                component.get('v.personWrapper.birthDay') == '' ||
                invalidDOB
            ) {
                component.set('v.disableSave', true);
            } else {
                component.set('v.disableSave', false);
            }
        } else if (component.get('v.dobConfig') == 'MM-YYYY') {
            if (
                component.get('v.personWrapper.birthYear') === null ||
                component.get('v.personWrapper.birthYear') == '' ||
                component.get('v.personWrapper.birthMonth') === null ||
                component.get('v.personWrapper.birthMonth') == '' ||
                component.get('v.valueAge') === null ||
                component.get('v.valueAge') === '' ||
                invalidDOB
            ) {
                component.set('v.disableSave', true);
            } else {
                component.set('v.disableSave', false);
            }
        } else if (component.get('v.dobConfig') == 'YYYY') {
            if (!component.get('v.isDelegate') && !component.get('v.personWrapper.showBirthDate')) {
                if (
                    component.get('v.personWrapper.birthYear') === null ||
                    component.get('v.personWrapper.birthYear') === ''
                ) {
                    component.set('v.disableSave', true);
                } else {
                    component.set('v.disableSave', false);
                }
            } else if (
                component.get('v.personWrapper.birthYear') === null ||
                component.get('v.personWrapper.birthYear') === '' ||
                component.get('v.valueAge') === null ||
                component.get('v.valueAge') === ''
            ) {
                component.set('v.disableSave', true);
            } else {
                component.set('v.disableSave', false);
            }
        } else {
            component.set('v.disableSave', false);
        }
    },
    setPlaceHolder: function (component, event, helper) {
        var personWrapper = component.get('v.personWrapper');
        if (
            component.get('v.valueAge') != undefined &&
            component.get('v.valueAge') != null &&
            component.get('v.valueAge') != ''
        ) {
            component.set('v.placeHolder', '');
        } else {
            var label = $A.get('$Label.c.PG_AC_Select');
            component.set('v.placeHolder', label);
        }
        if (
            personWrapper.birthDay != undefined &&
            personWrapper.birthDay != null &&
            personWrapper.birthDay != ''
        ) {
            component.set('v.placeHolder', '');
        } else {
            var label = $A.get('$Label.c.Date_Placeholder'); // Date_Placeholder
            component.set('v.placeHolder', label);
        }
        if (
            personWrapper.birthMonth != undefined &&
            personWrapper.birthMonth != null &&
            personWrapper.birthMonth != ''
        ) {
            component.set('v.placeHolder', '');
        } else {
            var label = $A.get('$Label.c.Month_Placeholder'); //Month_Placeholder
            component.set('v.placeHolder', label);
        }
        if (
            personWrapper.birthYear != undefined &&
            personWrapper.birthYear != null &&
            personWrapper.birthYear != ''
        ) {
            component.set('v.placeHolder', '');
        } else {
            var label = $A.get('$Label.c.Year_Placeholder'); // Year_Placeholder
            component.set('v.placeHolder', label);
        }
    },
    getCountryStateCode: function (component, event, helper) {
        communityService.executeAction(
            component,
            'getCountryCodes',
            {
                userMode: component.get('v.userMode')
            },
            function (returnValue) {
                component.set('v.contObj', returnValue);
                component.set('v.contactCountry', returnValue.countryMap);
                helper.isAdultCal(component, event);
            },
            null,
            function () {
                component.set('v.showSpinner', false);
            }
        );
    },
    isAdultCal: function (component, event) {
        if (component.get('v.contObj') && component.get('v.personWrapper')) {
            var personWrapper = component.get('v.personWrapper');
            var contObj = component.get('v.contObj');
            let cCode = '';
            let csCode = '';
            if (
                personWrapper.mailingCC != undefined &&
                personWrapper.mailingCC != null &&
                personWrapper.mailingCC != ''
            ) {
                cCode = personWrapper.mailingCC;
                if (
                    personWrapper.mailingSC != undefined &&
                    personWrapper.mailingSC != null &&
                    personWrapper.mailingSC != ''
                ) {
                    if (personWrapper != '') {
                        csCode = cCode + '_' + personWrapper.mailingSC;
                    }
                }
            }
            let adultAge = contObj.adultAgeByCountryStateCode['Age_for_All_Countries'];
            if (contObj.adultAgeByCountryStateCode[cCode]) {
                adultAge = contObj.adultAgeByCountryStateCode[cCode];
            }
            if (contObj.adultAgeByCountryStateCode[csCode]) {
                adultAge = contObj.adultAgeByCountryStateCode[csCode];
            }
            var isAdult = parseInt(component.get('v.valueAge')) >= parseInt(adultAge);
            component.set('v.isAdult', isAdult);
            personWrapper.isAdultPar = isAdult;
            component.set('v.personWrapper', personWrapper);
        }
    },

    checkValidEmail: function (email, emailValue) {
        debugger;
        var isValid = false;
        var regexp = $A.get('$Label.c.RH_Email_Validation_Pattern');
        var regexpInvalid = new RegExp($A.get('$Label.c.RH_Email_Invalid_Characters'));
        var invalidCheck = regexpInvalid.test(emailValue);
        if (invalidCheck == false) {
            if (emailValue.match(regexp)) {
                email.setCustomValidity('');
                isValid = true;
            } else {
                email.setCustomValidity($A.get('$Label.c.RH_RP_Delegate_Email_Format_Error'));
                isValid = false;
            }
        } else {
            email.setCustomValidity($A.get('$Label.c.RH_RP_Delegate_Email_Format_Error'));
            isValid = false;
        }
        email.reportValidity();
        return isValid;
    },

    setFieldsValidity: function (component, event) {
        event.preventDefault();
        let fieldsGroup = 'pField';
        let allValid = component.find(fieldsGroup).reduce(function (validSoFar, inputCmp) {
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        console.log('allValid--->' + allValid);
        component.set('v.isAllFieldsValid', allValid);
    },

    loadMMLeapYear: function (component, event, helper) {
        var maxDayMonths = ['01', '03', '05', '07', '08', '10', '12'];
        var minDayMonths = ['04', '06', '09', '11'];
        var personWrapper = component.get('v.personWrapper');

        if (maxDayMonths.includes(personWrapper.birthMonth)) {
            component.set('v.lastDay', 31);
        } else if (minDayMonths.includes(personWrapper.birthMonth)) {
            component.set('v.lastDay', 30);
        }
        helper.setLastDay(component, event, helper);
    },
    //dob changes
    participantAge: function (component, event, helper) {
        var studyDobFormat = component.get('v.dobConfig');
        var personWrapperDob = component.get('v.personWrapper');
        console.log(
            personWrapperDob.birthYear +
                '-' +
                personWrapperDob.birthMonth +
                '-' +
                personWrapperDob.birthDay
        );
        if (
            studyDobFormat == 'DD-MM-YYYY' &&
            personWrapperDob.birthYear != undefined &&
            personWrapperDob.birthYear != null &&
            personWrapperDob.birthYear != '' &&
            personWrapperDob.birthMonth != undefined &&
            personWrapperDob.birthMonth != null &&
            personWrapperDob.birthMonth != '' &&
            personWrapperDob.birthDay != undefined &&
            personWrapperDob.birthDay != null &&
            personWrapperDob.birthDay != ''
        ) {
            var dob = new Date(
                personWrapperDob.birthYear +
                    '-' +
                    personWrapperDob.birthMonth +
                    '-' +
                    personWrapperDob.birthDay
            );
            //calculate month difference from current date in time
            var month_diff = Date.now() - dob.getTime();
            //convert the calculated difference in date format
            var age_dt = new Date(month_diff);
            //extract year from date
            var year = age_dt.getUTCFullYear();
            //now calculate the age of the user
            var age = Math.abs(year - 1970);
            var num = parseFloat(age).toFixed(2);
            personWrapperDob.age = num;
            component.set('v.valueAge', age.toString());
            component.set('v.personWrapper', personWrapperDob);
        } else {
            component.set('v.valueAge', null);
            personWrapperDob.age = null;
            component.set('v.personWrapper', personWrapperDob);
        }
    }
});
