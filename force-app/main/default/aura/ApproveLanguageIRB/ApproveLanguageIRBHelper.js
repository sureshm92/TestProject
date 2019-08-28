/**
 * Created by Igor Malyuta on 26.08.2019.
 */
({
    setColumnCheckboxState: function (component) {
        var ssItems = component.get('v.ssItems');
        var langColumns = component.find('columnLang');

        var langBySelected = {};

        for (var i = 0; i < ssItems.length; i++) {
            var appLangs = ssItems[i].approvedLangCodes;
            for (var j = 0; j < appLangs.length; j++) {
                if (!langBySelected[appLangs[j].value]) {
                    langBySelected[appLangs[j].value] = {lang: appLangs[j].value, sum: 0};
                }
                if (appLangs[j].state) {
                    langBySelected[appLangs[j].value] = {
                        lang: langBySelected[appLangs[j].value].lang,
                        sum: langBySelected[appLangs[j].value].sum + 1
                    };
                }
            }
        }

        if(langColumns) {
            for (var k = 0; k < langColumns.length; k++) {
                var column = langColumns[k];
                var langCode = column.get('v.keyId');
                if(langCode === undefined) continue;

                var count = langBySelected[langCode].sum;

                var langColumnState = 'none';
                if (count === ssItems.length) {
                    langColumnState = 'all';
                } else if (count > 0 && count < ssItems.length) {
                    langColumnState = 'indeterminate';
                }
                console.log('Count = ' + count + ' lang = ' + langCode + ' langColumnState = ' + langColumnState);
                switch (langColumnState) {
                    case 'all':
                        column.setState(true, false);
                        break;
                    case 'indeterminate':
                        column.setState(false, true);
                        break;
                    default:
                        column.setState(false, false);
                }
            }
        }
    }
});