/**
 * Created by dmytro.fedchyshyn on 16.07.2019.
 */

({
    getIconsUrl: function(component, event){
        let staticResName = component.get('v.staticResourceName');
        let path = component.get('v.IconsPackageFIlePath');
        let iconsStaticURL = $A.get('$Resource.' + staticResName) + path;
        console.log(iconsStaticURL);
        component.set('v.iconsURL', iconsStaticURL);
    },

    getIconsNameAndDetail: function (component, event) {
        return new Promise($A.getCallback(function (resolve, reject) {
            let x = new XMLHttpRequest();
            x.open("GET", component.get('v.iconsURL'), true);
            x.onreadystatechange = function () {
                if (x.readyState === 4 && x.status === 200) {
                    let doc = x.responseXML;
                    if (doc) {
                        let symbols = doc.getElementsByTagName('symbol');
                        let symbolNames = [];
                        let iconsDetail = [];
                        for (let i = 0; i < symbols.length; i++) {
                            symbolNames.push(symbols[i].id);
                            iconsDetail.push({id : symbols[i].id, name: symbols[i].getAttribute('name')});
                        }

                        component.set('v.iconNames',symbolNames);
                        let customIconDetails = [];
                        if (iconsDetail.length > 0) {
                            iconsDetail.map(function (el) {
                                let iconDetail = {
                                    Description__c: null,
                                    'Id': null,
                                    'Label__c': null,
                                    'Custom_Icon__c': true,
                                    'Name': el.id,
                                    'Icon_Label__c': el.name
                                };
                                customIconDetails.push(iconDetail);
                                component.set("v.iconsDetail", customIconDetails);
                            });
                        }
                        let result = {iconNames : iconsDetail, iconsDetails: customIconDetails};
                        resolve(result)
                    } else {
                        reject($A.get('$Label.c.Icons_package_not_found'));
                    }

                } else {

                }
            };
            x.send(null);
        }));
    },
});