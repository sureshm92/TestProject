({
  doInit : function (component, event, helper){
    helper.onclose(event);    
  },

  handleQuestionnaireEvent : function(component, event, helper){
    helper.questionnaireEvent(component, event);
  },
  
  next: function (component, event, helper) {
    helper.next(component, event);
  }, 

  submit: function (component, event, helper) {
    helper.createDummyAccount(component, event);
  },

  update : function (component, event, helper) {
    helper.update(component, event);
  }

})