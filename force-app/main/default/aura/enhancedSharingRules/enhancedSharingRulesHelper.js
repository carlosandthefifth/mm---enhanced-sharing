({
    onInit : function(component,event,helper) {
        var action = component.get("c.getObjectNames");

        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === 'SUCCESS') {
                var returnValues = response.getReturnValue();

                component.set("v.objectNames",returnValues);
                

                component.set("v.selectedObjectName", returnValues[0]);
          
                $A.enqueueAction(getGroupNamesAction);
            }
        });
        $A.enqueueAction(action);

        var getGroupNamesAction = component.get("c.getPublicGroupNames");

        getGroupNamesAction.setParams({"objectName" : "Account"});

        getGroupNamesAction.setCallback(this,function(response){
            var state = response.getState();
            if (state === 'SUCCESS') { 
                var groups = response.getReturnValue();
                if (groups != null) {
                    component.set("v.groupNames", groups);
                    console.log("groups: " + groups[0]);
                    component.set("v.groupSelected",groups[0])
                }
                $A.enqueueAction(getUserNamesAction);
            }
        });

        
        var getUserNamesAction = component.get("c.getAvailableUsers");
        
        getUserNamesAction.setParams({"users" : []});
        getUserNamesAction.setCallback(this,function(response){
            var state = response.getState();
            if (state === 'SUCCESS') { 
                console.log("users");
                var results = response.getReturnValue();
                component.set("v.userRecords", results);
                var userRecords = component.get("v.userRecords");
                console.log(">>> user" + JSON.stringify(userRecords));

                var strArry = [];
                console.log("K:fdfd: " + JSON.stringify(results));
                for (var i = 0; i < results.length; i++) {
                    if (results[i].FirstName != null && results[i].LastName != null && results[i].FirstName != 'Automated' && results[i].LastName != 'Process') {
                        var fullname = results[i].LastName + ", " + results[i].FirstName + " - " + results[i].Username;
                        strArry.push({label:fullname, value: results[i].Id})
                    }
                }

                console.log(">>> " + JSON.stringify(strArry));

                component.set("v.availableUserNames", strArry);
//                component.set("v.selectedUserNames", stryArry.value);

                helper.groupSelect(component,event,helper);

            }
        });
    },

    changeObject : function(component, event, helper) {
        var inputObjectName = component.get("v.inputGroupName");
        component.set("v.selectedObjectName", inputObjectName);
    },

    moveToGroup : function(component, event, helper) {
        var myInputs = component.find("checkboxAddInputs").find({instancesOf : "lightning:input"});
        var availableUserNames = component.get("v.availableUserNames");
        var selectedUserNames  = component.get("v.selectedUserNames");
        var IDsRemove = [];
        
        console.log("availableUserNames: " + JSON.stringify(availableUserNames));


        console.log("myInputs[i]: " + JSON.stringify(myInputs));
        console.log("myinputs.length: " + myInputs.length);

        for (var i = 0; i < myInputs.length; i ++) {

            var checked = myInputs[i].get("v.checked");
            var userID  =  myInputs[i].get("v.value");
            var userName = myInputs[i].get("v.label");
           
            console.log("i: " + i);
            console.log("looking for userid: " + userID);

            var inList = false;
            var index  = -1;
            
            console.log("myInputs["+i+"].isChecked: " + myInputs[i].get("v.checked"));
            console.log("myInputs["+i+"].value: " + myInputs[i].get("v.value"));
            console.log("myInputs["+i+"].label: " + myInputs[i].get("v.label"));

            if (checked) {
                for (var j = 0; j < availableUserNames.length; j++) {
                    console.log(">>availableUserNames["+j+"].value: " + availableUserNames[j].value);
                    if (availableUserNames[j].value == userID) {
                        inList = true;
                        index = j;
                        console.log("**found user " + userID + "in list");
                        break;
                    }
                }
            }
        console.log("hello");
            
//            console.log("1 checked1");
  //          console.log("2 availableUserNames " + JSON.stringify(availableUserNames));
                
            if (index>=0)  {
                console.log("index: " + index);
                console.log("userID: " + userID);
                IDsRemove.push(userID);
                console.log("hello2");
                // availableUserNames.splice(index,1);
    //            console.log("checked2");
                console.log("pushing selected users >>>");
                selectedUserNames.push({label: userName, value: userID});
      //          console.log("checked3");
        //        console.log("availableUserNames: " + JSON.stringify(availableUserNames));
          //      console.log("selectedUserNames: " + JSON.stringify(selectedUserNames));
            }
        
        }
           
        console.log("1");
        for (var j = 0; j < IDsRemove.length; j++) {
            console.log("2");
            for (var i = 0; i < availableUserNames.length; i ++ ){
                console.log("3 " + IDsRemove[j] + " == " + availableUserNames[i].value);
                if (IDsRemove[j] == availableUserNames[i].value) {
                    console.log("4");
                    availableUserNames.splice(i,1);
                }
            }
        }


        for (var i = 0; i < selectedUserNames.length; i++) {
            console.log("selectedUserNames[i]: " + JSON.stringify(selectedUserNames[i]));
        }

        for (var i = 0; i < availableUserNames.length; i++) {
            console.log("availableUserNames[i]: " + JSON.stringify(availableUserNames[i]));
        }
        
        component.set("v.availableUserNames", availableUserNames);
        component.set("v.selectedUserNames", selectedUserNames);

        
        helper.addToGroup(component,event,helper);

        // List<ID> UserIDsAdded, List<ID> UserIDsRemoved, String GroupName, String ObjectType
     },
  

    createGroup : function(component, event, helper) {
        var type = "Success";
        var title = "Success";
        var message = "Group successfully created";
        var groupName = component.get("v.inputGroupName")
        var groupNames = component.get("v.groupNames");
        var objectName = component.get("v.selectedObjectName");

        var pattern= new RegExp("^[A-Za-z_-][A-Za-z0-9_-]*$");

        if (!pattern.test(groupName)) {
            type = "Error";
            title = "Error";
            message = "Group names must start with a letter and can only have alphanumeric symbols. (!@#$^) do not count.";

            helper.showToast(component,event,type,title,message);
            return;
        }

        if (groupName.length > 34) {
            type = "Error";
            title = "Error";
            message = "Group names must be 34 or less characters.  This name " + groupName + " has " + groupName.length + " characters. ";

            helper.showToast(component,event,type,title,message);
            return;
        }

        if (groupName == null) {
            type = "Error";
            title = "Error";
            message = "Group names need to have a name";

            helper.showToast(component,event,type,title,message);
            return;
        }

        if (groupName.indexOf(" ") >=0) {
            type = "Error";
            title = "Error";
            message = "Group names cannot have spaces";

            helper.showToast(component,event,type,title,message);
            return;
        }

        for(var i = 0; i < groupNames.length; i++) {
            if (groupName == groupNames[i]) {
                type = "Error";
                title = "Error";
                message = "Duplicate group names are not allowed";

                helper.showToast(component,event,type,title,message);
                return;
            }
        }

        var action = component.get("c.createPublicGroup");

        console.log("objectName: " + objectName);

        console.log("groupName: " + groupName);
        if(objectName == 'Property') objectName='asset';
        action.setParams({"Name" : groupName, "AccessLevel":"Read", "Type" : "Regular", "forObject" : objectName});

        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var groupNames = response.getReturnValue();
                component.set("v.groupNames",groupNames);        
                component.set("v.inputGroupName","");                     
                helper.showToast(component,event,type,title,message);
            } else {
                type = "Error";
                title = "Error";
                message = "There was a problem creating the group";

                helper.showToast(component,event,type,title,message);
                helper.onInit(component,event,helper);
            }
            
        });
        $A.enqueueAction(action);      
    },

    moveFromGroup : function(component, event, helper) {
        console.log("move from group helper");
        var myInputs = component.find("checkboxRemoveInputs").find({instancesOf : "lightning:input"});
        var selectedUserNames  = component.get("v.selectedUserNames");
        var availableUserNames = component.get("v.availableUserNames");
        var userIDstoRemove = [];

        console.log("myInputs[i]: " + JSON.stringify(myInputs));

        for (var i = 0; i <= myInputs.length; i ++) {
            var checked = myInputs[i].get("v.checked");
            var userID  =  myInputs[i].get("v.value");
            var userName = myInputs[i].get("v.label");
            var inList = false;
            var index  = -1;
            
            console.log("myInput[i].isChecked: " + myInputs[i].get("v.checked"));
            console.log("myInput[i].value: " + myInputs[i].get("v.value"));
            console.log("myInput[i].label: " + myInputs[i].get("v.label"));

            if (checked) {
                for (var j = 0; j <= selectedUserNames.length; j++) {
                    console.log(">>selectedUserNames[j].get(v.value): " + selectedUserNames[j].value);
                    if (selectedUserNames[j].value == userID) {
                        inList = true;
                        index = j;
                        console.log("**found user " + userID + "in list");
                        userIDstoRemove.push(userID);
                        break;
                    }
                }
    
                console.log("1 checked1");
                console.log("2 selectedUserNames " + JSON.stringify(selectedUserNames));
                
                if (index>=0)  {
                    selectedUserNames.splice(index,1);
                    console.log("checked2");
                    availableUserNames.push({label: userName, value: userID});
                    console.log("checked3");
                    console.log("availableUserNames: " + JSON.stringify(availableUserNames));
                    console.log("selectedUserNames: " + JSON.stringify(selectedUserNames));
                }
            } 
            console.log("userids: " + JSON.stringify(userIDstoRemove));
            component.set("v.availableUserNames", availableUserNames);
            component.set("v.selectedUserNames", selectedUserNames);
         
            helper.removeFromGroup(component,event,helper,userIDstoRemove);

        }
        // List<ID> UserIDsAdded, List<ID> UserIDsRemoved, String GroupName, String ObjectType
     },
    
    deleteGroup : function(component, event, helper) {
        var type = "Success";
        var title = "Success";
        var message = "Group successfully deleted";
        var groupName=event.getSource().get("v.value");
        var objectName = component.get("v.selectedObjectName");

        var action = component.get("c.deletePublicGroup");
        
        if (objectName == 'Property') objectName = 'Asset';

        action.setParams({"Name" : groupName, "forObject" : objectName});

        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var results = response.getReturnValue();
                component.set("v.groupNames",results);   
                helper.showToast(component,event,type,title,message);
                //helper.onInit(component,event,helper);
            } else {
                type = "Error";
                title = "Error";
                message = "There was a problem deleting the group";

                helper.showToast(component,event,type,title,message);
            }
            
        });
        $A.enqueueAction(action);
    },

    removeFromGroup : function(component, event, helper,userIds) {
        console.log("userIds2 : " + JSON.stringify(userIds));
        var groupName = component.get("v.groupSelected"); 

console.log("1");
        var action = component.get("c.removeFromMembership");
        console.log("1.5");
        action.setParams({"UserIDsRemoved" :userIds, "GroupName" :groupName, "ObjectType" : "Opportunity"});
        console.log("2");
        
        action.setCallback(this, function(response){
            var state = action.getState();
            if (state === 'SUCCESS') {
                var type = "Success";
                var title = "Success";
                var message = "User successfully updated";
                helper.showToast(component,event,type,title,message);
            } else {
                type = "Error";
                title = "Error";
                message = "There was a problem updating the user";

                helper.showToast(component,event,type,title,message);
            }
        });
        console.log("3");
        $A.enqueueAction(action);
     },

    addToGroup : function(component, event, helper) {
        console.log("inside addToGroup");
        var objectName = component.get("v.selectedObjectName");
        var action = component.get("c.addToMembership");
        console.log("inside addToGroup1");
        var selectedUserNames = component.get("v.selectedUserNames");
        var group = component.get("v.groupSelected");
        var userIds = [];
        
        console.log("selectedUserNames: " + JSON.stringify(selectedUserNames));
        for (var i = 0; i < selectedUserNames.length; i++) {
            userIds.push(selectedUserNames[i].value);
        }
        console.log("userIds: " + JSON.stringify(userIds));

        action.setParams({UserIDsAdded:userIds,GroupName:group, ObjectType: objectName});
        
        action.setCallback(this, function(response){
            var state = action.getState();
            if (state === 'SUCCESS') {
                var type = "Success";
                var title = "Success";
                var message = "User successfully updated";
                helper.showToast(component,event,type,title,message);
            } else {
                type = "Error";
                title = "Error";
                message = "There was a problem updating the user";

                helper.showToast(component,event,type,title,message);
            }
        });
        $A.enqueueAction(action);
     },
  
    showToast : function(component,event,type,title,message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":type,
            "title": title,
            "message": message 
        });
        toastEvent.fire();
        //$A.get("e.force:refreshView").fire()
    },
    
    selectNewObject : function(component, event, helper){
        var groupName = component.get("v.selectedObjectName");
        var getGroupNamesAction = component.get("c.getPublicGroupNames");
        if (groupName == 'Property') groupName='Asset';
        getGroupNamesAction.setParams({"objectName" : groupName});

        getGroupNamesAction.setCallback(this,function(response){
            var state = response.getState();
            if (state === 'SUCCESS') { 
                var groups = response.getReturnValue();
                if (groups != null) {
                    component.set("v.groupNames", groups);
                    console.log("groups: " + groups[0]);
                    component.set("v.groupSelected",groups[0])
                    helper.groupSelect(component,event,helper);
                }
            }
        });
        $A.enqueueAction(getGroupNamesAction);
    },


    groupSelect : function(component, event, helper) {
        console.log("groupselect");
        var inputGroupName = component.get("v.groupSelected");
        console.log("<><<><><>inputGroupName: " + inputGroupName);
        var objectName = component.get("v.selectedObjectName");
        var action = component.get("c.getSelectedUsers");
        var action2 = component.get("c.getAvailableUsers");

        var users = [];

        console.log("action: " + action);
        console.log("action2: " + action2);
        if (objectName == 'Property') objectName='Asset';

        action.setParams({"groupName" : inputGroupName, "objectName" : objectName});
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                users = response.getReturnValue();
                var toList = [];

                console.log("users: " + JSON.stringify(users));
                for (var i = 0; i < users.length; i++) {
                    if (users[i].FirstName != null && users[i].LastName != null && users[i].FirstName != 'Automated' && users[i].LastName != 'Process') {
                        var buildName = users[i].LastName + ', ' + users[i].FirstName + ' - ' + users[i].Username;
                        console.log("buildName: " + buildName);
                        toList.push({value : users[i].Id, label : buildName});
                    }
                }
                console.log(")))toList: " + JSON.stringify(toList));
                component.set("v.selectedUserNames", toList);
                action2.setParams({"users" : users});
                $A.enqueueAction(action2);
            }
        });
        $A.enqueueAction(action);

        action2.setCallback(this, function(response){
            var state = response.getState();
            if (state === 'SUCCESS') {
                var results = response.getReturnValue();
                var toList = [];

                for (var i = 0; i < results.length; i++) {
                    if (results[i].FirstName != null && results[i].LastName != null && results[i].FirstName != 'Automated' && results[i].LastName != 'Process') {
                        var buildName = results[i].LastName + ', ' + results[i].FirstName + ' - ' + results[i].Username;
                        toList.push({value : results[i].Id, label : buildName});
                    }
                }

                component.set("v.availableUserNames", toList);
            } else {
                alert("error");
            }

        });
    }


})
