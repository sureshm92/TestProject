/**
 * Created by Admin on 9/3/2019.
 */

({

    containsObject : function (array, value) {
        // console.log(JSON.stringify(array));
        // console.log(JSON.stringify(value));
        for (let i = 0; i < array.length; i++) {
            if (array[i]['Id'] == value['Id']) {
                return true;
            }
        }
        // console.log('not contains');
        return false;
    },

    removeFromArray : function (array, idToRemove) {
        for (let i = 0; i < array.length; i++) {
            if (array[i]['Id'] === idToRemove) {
                array.splice(i, 1);
                break;
            }
        }
    },

    fillValueWithIds :function (items, component) {
        let value = [];
        for (let i = 0; i < items.length; i++) {
            value.push(items[i]);
        }
        component.set('v.value', value);
    }
});

