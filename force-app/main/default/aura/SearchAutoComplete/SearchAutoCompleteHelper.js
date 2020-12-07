({
    searchRecords: function (component, searchString) {
        const serverResult = component.get('v.searchList');
        const results = [];
        var data = serverResult.filter((item) =>
            Object.keys(item).some(
                (k) =>
                    item[k] != null &&
                    item[k].toString().toLowerCase().includes(searchString.toLowerCase())
            )
        );

        data.forEach(function (element) {
            var result = { id: element.value, value: element.label };
            results.push(result);
        });
        component.set('v.results', results);

        if (serverResult.length > 0) {
            component.set('v.openDropDown', true);
            component.set('v.issearching', false);
        }
    }
});
