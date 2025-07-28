// My Test Class

@isTest
private class LeadTriggerHandlerTest {

    @isTest // Passed
    static void testTitleNormalization() {
        Lead lead1 = new Lead(LastName='Smith', Company='Acme', Title='v.p.');
        Lead lead2 = new Lead(LastName='Doe', Company='Beta', Title='Head of department');
        Lead lead3 = new Lead(LastName='Lee', Company='Gamma', Title='Assistant to CEO');
        Lead lead4 = new Lead(LastName='Chan', Company='Delta', Title='Chief Engineer');

        insert new List<Lead>{lead1, lead2, lead3, lead4};

        Test.startTest();
        update [
            SELECT Id, Title 
            FROM Lead 
            WHERE Id IN :new List<Id>{lead1.Id, lead2.Id, lead3.Id, lead4.Id}
            ];
        Test.stopTest();

        List<Lead> updatedLeads = [SELECT Title FROM Lead WHERE Id IN :new List<Id>{lead1.Id, lead2.Id, lead3.Id, lead4.Id}];
        System.assertEquals('Vice President', updatedLeads[0].Title);
        System.assertEquals('Manager', updatedLeads[1].Title);
        System.assertEquals('Assistant', updatedLeads[2].Title);
        System.assertEquals('Executive', updatedLeads[3].Title);
    }

    @isTest // Passed
    static void testAutoLeadScoring() {
        Lead l = new Lead(
			LastName = 'ScoreTest',
			Company = 'TestCorp',
			Email = 'score@example.com',
			LeadSource = 'Website',
			Phone = '1234567890',
			Industry = 'Technology'
		);

		insert l;

		Lead result = [
            SELECT Lead_Score__c 
            FROM Lead 
            WHERE Id = :l.Id
            ];
		System.assertEquals(18, result.Lead_Score__c); // 3 + 5 + 10
	}

    @isTest // Passed
    static void testLeadAutoConvert_SingleMatch() {
        Account acc = new Account(Name='TestAccount');
		insert acc;

		Contact c = new Contact(LastName='Match', Email='convertme@example.com', AccountId=acc.Id);
		insert c;

		Lead lead = new Lead(LastName='ToConvert', Company='LeadCo', Email='convertme@example.com');
		insert lead;

		// Make sure it was converted
		lead = [
            SELECT IsConverted 
            FROM Lead 
            WHERE Id = :lead.Id
            ];
		System.assert(lead.IsConverted, 'Lead should have been converted.');
    }

    @isTest // Passed
    static void testLeadAutoConvert_MultipleMatches() {
        Account acc = new Account(Name='DupAccount');
		insert acc;

		insert new List<Contact>{
			new Contact(LastName='Dup1', Email='duplicate@example.com', AccountId=acc.Id),
			new Contact(LastName='Dup2', Email='duplicate@example.com', AccountId=acc.Id)
		};

		Lead lead = new Lead(LastName='NoConvert', Company='LeadCo', Email='duplicate@example.com');
		insert lead;

		lead = [
            SELECT IsConverted 
            FROM Lead 
            WHERE Id = :lead.Id
            ];
		System.assert(!lead.IsConverted, 'Lead should NOT have been converted due to multiple matching contacts.');
    }

    @isTest // Passed
    static void tetsLeadAutoConvert_NoMatch() {
        Lead lead = new Lead(LastName='Unmatched', Company='NoMatchCo', Email='nomatch@example.com');
		insert lead;

		lead = [
            SELECT IsConverted 
            FROM Lead 
            WHERE Id = :lead.Id
            ];
		System.assert(!lead.IsConverted, 'Lead should NOT have been converted since there’s no match.');
    }
}