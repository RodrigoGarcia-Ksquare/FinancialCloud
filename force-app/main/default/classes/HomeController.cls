public with sharing class HomeController {
    @AuraEnabled(cacheable=true)
    public static List<Lead> getLeads(){
        List<Lead> leads = [SELECT Id, FirstName, LastName, Email, Company, City, State, LeadSource, OwnerId, Owner.Name
                                        FROM Lead
                                        ORDER BY Owner.Name];
        return leads;
    }

    @AuraEnabled
    public static void assignUser(Id recordId, Id userId){
        Lead leadToBeAssigned = [SELECT Id, Name, OwnerId
                                 FROM Lead
                                 WHERE Id = :recordId
                                 ];
        leadToBeAssigned.Id = recordId;
        leadToBeAssigned.OwnerId = userId;
        
        update leadToBeAssigned;
    }

    @AuraEnabled
    public static List<User> getAdminUsers(){
       List<User> users =   [SELECT Id, Name, UserRole.Name 
                            FROM User 
                            WHERE UserRole.Name = 'Wave Analytics Integration'
                        ];
        return users;
    }

}