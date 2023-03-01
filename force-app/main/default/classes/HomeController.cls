public with sharing class HomeController {
    @AuraEnabled(cacheable=true)
    public static List<Lead> getLeads(String branch){
        List<Lead> leads = new List<Lead>();

        if(branch == ''){
            leads = [SELECT Id, FirstName, LastName, Email, Company, City, State, LeadSource, OwnerId, Owner.Name, Status, Branch__c, Branch__r.Name
                        FROM Lead
                        ORDER BY Owner.Name];
        }

        else{
            leads = [SELECT Id, FirstName, LastName, Email, Company, City, State, LeadSource, OwnerId, Owner.Name, Status, Branch__c, Branch__r.Name
                        FROM Lead
                        WHERE Branch__c =:branch
                        ORDER BY Owner.Name];
        }

        system.debug(leads);
        return leads;
    }

    @AuraEnabled(cacheable=true)
    public static List<Branch__c> getBranches(){
        List<Branch__c> branches = [SELECT Id, Name
                                      FROM Branch__c];
        return branches;
    }

    @AuraEnabled(cacheable=true)
    public static Integer getLeadsCount(String ownName){
        Integer ownLeadCount = [SELECT COUNT() FROM Lead WHERE Owner.Name LIKE :ownName];
        system.debug('the count is '+ ownLeadCount);
        return ownLeadCount;
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