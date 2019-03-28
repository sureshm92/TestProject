(
    {
        trimLongText : function (returnValue) {
            let wrappers = returnValue.wrappers;
            for (let i = 0; i < wrappers.length; i++) {
                let title = wrappers[i].title;
                wrappers[i].title = title.length > 40 ? title.substring(0, 37) + '...' : title;
                let description = wrappers[i].description;
                wrappers[i].description = description.length > 120 ? description.substring(0, 117) + '...' : description;
            }
            return returnValue;
        }
    }
)