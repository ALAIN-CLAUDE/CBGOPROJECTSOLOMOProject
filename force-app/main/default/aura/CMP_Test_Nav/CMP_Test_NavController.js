({
   init : function(component, event, helper) {
      var progressIndicator = component.find('progressIndicator');
      for (let step of component.get('v.stages')) {
         $A.createComponent(
            "lightning:progressStep",
            {
               "aura:id": "step_" + step,
               "label": step,
               "value": step,
                "onstepfocus":component.getReference("c.handleChange")
                
             },
             function(newProgressStep, status, errorMessage){
                // Add the new step to the progress array
                if (status === "SUCCESS") {
                   var body = progressIndicator.get("v.body");
                   body.push(newProgressStep);
                   progressIndicator.set("v.body", body);
                 }
                 else if (status === "INCOMPLETE") {
                    // Show offline error
                    console.log("No response from server, or client is offline.")
                  }
                  else if (status === "ERROR") {
                     // Show error message
                     console.log("Error: " + errorMessage);
                  }
              }
           );
       }
   },
    handleChange : function(component, event, helper) {
      // When an option is selected, navigate to the next screen
      var response = event.getSource().getLocalId();
      component.set("v.value", response);
      var navigate = component.get("v.navigateFlow");
      var eventParams=event.getParams();
       /* console.log('eve'+component.get('v.stages'));
      console.log(JSON.stringify(eventParams));
      var value = event.getParam('value');
        
      component.set("selected_stage",value);
      console.log("value"+ v.value);
	  */
      var stepIndex = event.getParam('index');
        var listStages = component.get('v.stages');
        console.log('index'+ stepIndex);
        console.log('liststages'+ listStages);
        console.log('type'+ typeof listStages);
        console.log('indexOf'+ listStages.indexOf(stepIndex));
        component.set('v.index',stepIndex);
        if (listStages.indexOf(stepIndex)!=-1){
            console.log('index'+ stepIndex);
            console.log('value'+listStages[stepIndex]);
            //component.set('v.currentStage',listStages[stepIndex]);
            component.set('v.selected_stage',listStages[stepIndex]);
            var selectedStage = component.get('v.selected_stage');
            console.log('selectedStage + ' + selectedStage);
            //alert(selectedStage);
        }
      navigate("NEXT");
   }
})