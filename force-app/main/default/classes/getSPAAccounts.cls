global class getSPAAccounts implements Process.Plugin { 

   global Process.PluginResult invoke(Process.PluginRequest request) { 
       System.Debug('INPUT PARAMETERS: ' + request.inputParameters);
      String spas = (String) request.inputParameters.get('spas');
      System.Debug(spas);

        List<String> res = spas.split(';');
        List<SPA_Assign__c> spa_assignments = [SELECT External_ID__c,Id,Name,SPA_Number_Name__c,SPA__c FROM SPA_Assign__c
where SPA_Number_Name__c IN :res];

        System.Debug(spa_assignments);
      Map<String,Object> result = new Map<String,Object>();
      result.put('accountId', 'success');
      return new Process.PluginResult(result);

   }

   global Process.PluginDescribeResult describe() { 
      Process.PluginDescribeResult result = new Process.PluginDescribeResult(); 
      result.Name = 'Get Accounts by SPAs';
      result.Tag = 'Account Classes';
      result.inputParameters = new 
         List<Process.PluginDescribeResult.InputParameter>{ 
            new Process.PluginDescribeResult.InputParameter('spas', 
            Process.PluginDescribeResult.ParameterType.STRING, true) 
         }; 
      result.outputParameters = new 
         List<Process.PluginDescribeResult.OutputParameter>{              
            new Process.PluginDescribeResult.OutputParameter('accountId', 
            Process.PluginDescribeResult.ParameterType.STRING)
                }; 
      return result; 
   }
}