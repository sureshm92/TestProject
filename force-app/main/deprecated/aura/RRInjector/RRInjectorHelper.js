(
    {
        createInjectedComponent: function(component, name, attributes) {

            $A.createComponent(
                name,
                attributes,
                function(injectedComponent, status, errorMessage){
                    if (status === "SUCCESS" && component.isValid()) {
                        let body = component.get("v.body");
                        body.push(injectedComponent);
                        component.set("v.body", body);
                    }
                    else if (status === "INCOMPLETE") {
                        console.log("No response from server or client is offline.")
                    }
                    else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                    }
                }
            );
        },
    }
)