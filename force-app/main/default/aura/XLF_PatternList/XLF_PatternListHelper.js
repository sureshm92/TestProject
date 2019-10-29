/**
 * Created by Slav on 29.10.2019.
 */

({

    sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.data");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse))
        component.set("v.data", data);
    },

    sortBy: function (field, reverse, primer) {
        var key = primer ? function(x) {
                return primer(x[field])
            } : function(x) {
                return x[field]
            };
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    }

});