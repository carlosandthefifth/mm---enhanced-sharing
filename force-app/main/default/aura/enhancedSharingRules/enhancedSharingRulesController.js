({
   onInit : function(component, event, helper) {
      helper.onInit(component,event,helper);
   },

   changeObject : function(component, event, helper) {
      helper.changeObject(component, event, helper);
   },

   groupSelect : function(component, event, helper) {
      helper.groupSelect(component, event, helper);
   },

   moveFromGroup : function(component, event, helper) {
      console.log("move from group primary");
      helper.moveFromGroup(component,event,helper);

   },

   moveToGroup : function(component, event, helper) {
      helper.moveToGroup(component,event,helper);
   },

   myAction : function(component, event, helper) {
   },

   createGroup : function(component, event, helper) {
      helper.createGroup(component, event, helper);
   },

   deleteGroup : function(component, event, helper) {
      helper.deleteGroup(component, event, helper);
   },

   isRefreshed : function(component, event, helper) {
   },
   
   addToGroup: function(component, event, helper) {
      helper.addToGroup(component, event, helper);
   },

   removeFromGroup: function(component, event, helper) {
      helper.removeFromGroup(component, event, helper);
   },
  
   selectNewObject : function(component, event, helper) {
      helper.selectNewObject(component, event, helper);
   },

   showToast : function(component, event, helper) {
      helper.showToast(component, event, helper);
   },

   openModalToggle: function(component, event, helper) {
      console.log("openModalToggle");
      helper.openModalToggle(component,event,helper);
   },
    
   closeModel: function(component, event, helper) {
      // Set isModalOpen attribute to false  
   }
})
