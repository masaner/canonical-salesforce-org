@isTest
private class Test_Foobar {

    @isTest
    static void getFullLeadsTest() {
        // Mocking the HTTP response for the GET request
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('getFullLeads'));

        // Call the getLeads method
        String leads = Foobar.getLeads();

        // Assert that the response is not null
        Assert.isNotNull(leads);

        List<Object> leadsList = (List<Object>)JSON.deserializeUntyped(leads);
        Assert.areEqual(20, leadsList.size(), 'leadsList size should be 20');
    }

    @isTest
    static void postForInjectionTest() {
        // Mocking the HTTP response for the POST request
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('postForInjection'));

        // Call the sendPostRequest method
        String response = Foobar.sendPostRequest('linkingLeadsKey', '1,2,3,4', 'Canonical - Import Leads from Foobar');

        // Assert that the response is not null
        Assert.isNotNull(response);

        // Deserialize the JSON string into a Map
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);

        // Check if jobId is not null
        String jobId = (String)responseMap.get('jobId');
        Assert.isNotNull(jobId != null, 'jobId should not be null');

        // Check if referenceId is not null
        String referenceId = (String)responseMap.get('referenceId');
        Assert.isNotNull(referenceId != null, 'referenceId should not be null');


        // Check if selectedLeads size is 4
        List<Object> selectedLeads = (List<Object>)responseMap.get('selectedLeads');
        Assert.areEqual(4, selectedLeads.size(), 'selectedLeads size should be 4');
    }

    @isTest
    static void testFoobarLeadCreation() {
        // Create a Foobar lead
        Lead foobarLead = new Lead(
            LastName= 'Doe',
            LeadSource = 'Foobar',
            Company = 'XYZ Corp.',
            Email = 'test@example.com',
            Sales_Rep_Name__c = 'Test Sales Rep',
            Linked_Job_Id__c = 'TestJobId'
        );
        insert foobarLead;

        // Verify that a campaign is created
        List<Campaign> campaigns = [SELECT Id FROM Campaign WHERE Name LIKE 'Foobar - Test Sales Rep%'];
        Assert.areNotEqual(0, campaigns.size(), 'Campaign not created for Foobar lead');
        
        // Verify that campaign members are created
        List<CampaignMember> campaignMembers = [SELECT Id FROM CampaignMember WHERE LeadId = :foobarLead.Id];
        Assert.areNotEqual(0, campaignMembers.size(), 'Campaign members not created for Foobar lead');
    }

    @isTest
    static void testNonFoobarLeadCreation() {
        // Create a non-Foobar lead
        Lead nonFoobarLead = new Lead(
            LastName= 'Smith',
            LeadSource = 'Web',
            Company = 'ABC Corp.',
            Email = 'test@example.com',
            Sales_Rep_Name__c = 'Test Sales Rep',
            Linked_Job_Id__c = 'TestJobId'
        );
        insert nonFoobarLead;

        // Verify that no campaign is created
        List<Campaign> campaigns = [SELECT Id FROM Campaign WHERE Name LIKE 'Foobar - Test Sales Rep%'];
        Assert.areEqual(0, campaigns.size(), 'Campaign created for non-Foobar lead');

        
        // Verify that no campaign members are created
        List<CampaignMember> campaignMembers = [SELECT Id FROM CampaignMember WHERE LeadId = :nonFoobarLead.Id];
        Assert.areEqual(0, campaignMembers.size(), 'Campaign members created for non-Foobar lead');
    }

    @isTest
    static void testLinkedJobId() {
        // Create a Foobar lead with Linked Job Id
        Lead foobarLead = new Lead(
            LastName= 'Smith',
            LeadSource = 'Foobar',
            Company = 'ABC Corp.',
            Email = 'test@example.com',
            Sales_Rep_Name__c = 'Test Sales Rep',
            Linked_Job_Id__c = 'linkingLeadsKey'
        );
        insert foobarLead;

        Assert.isNotNull(foobarLead.Id);

        // Verify that a campaign is created with Linked Job Id
        List<Campaign> campaigns = [SELECT Id FROM Campaign WHERE Linked_Job_Id__c = 'linkingLeadsKey'];
        Assert.areNotEqual(0, campaigns.size(), 'Campaign not created for Foobar lead with Linked Job Id');

        // Verify that campaign members are created with Linked Job Id
        List<CampaignMember> campaignMembers = [SELECT Id,LeadId FROM CampaignMember WHERE CampaignId = :campaigns[0].Id];
        Assert.areNotEqual(0, campaignMembers.size(), 'Campaign members not created for Foobar lead with Linked Job Id');
        Assert.areEqual(1,campaignMembers.size(), 'Campaign members not created for Foobar lead with Linked Job Id, only 1 should exist');

        // Create a Foobar lead with Linked Job Id
        Lead newFoobarLead = new Lead(
            LastName= 'Jordan',
            LeadSource = 'Foobar',
            Company = 'Hills Corp.',
            Email = 'test2@example.com',
            Sales_Rep_Name__c = 'Test Sales Rep',
            Linked_Job_Id__c = 'linkingLeadsKey'
        );
        insert newFoobarLead;

        // Verify that only 1 campaign exists
        List<Campaign> campaignsForNewLead = [SELECT Id FROM Campaign WHERE Linked_Job_Id__c = 'linkingLeadsKey'];
        Assert.areEqual(1, campaignsForNewLead.size(), 'Second Campaign Should Not Have Been Created!');

        // Verify that the new campaign members are created with Linked Job Id
        List<CampaignMember> campaignMembersForNewLead = [SELECT Id,LeadId FROM CampaignMember WHERE CampaignId = :campaignsForNewLead[0].Id];
        Assert.areEqual(2,campaignMembersForNewLead.size(), 'The same campaign should now have a second member!');
    }

    // Helper class to mock HTTP responses
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        private String responseType;

        public MockHttpResponseGenerator(String responseType) {
            this.responseType = responseType;
        }

        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if (responseType == 'getFullLeads') {
                res.setBody('[{"id":1,"firstname":"John","lastname":"Doe","email":"john@example.com","company":"ABC Inc."},{"id":2,"firstname":"Jane","lastname":"Smith","email":"jane@example.com","company":"XYZ Corp"},{"id":3,"firstname":"Alice","lastname":"Johnson","email":"alice@example.com","company":"123 Company"},{"id":4,"firstname":"Bob","lastname":"Brown","email":"bob@example.com","company":"456 Corp"},{"id":5,"firstname":"Emily","lastname":"Davis","email":"emily@example.com","company":"789 Enterprises"},{"id":6,"firstname":"Michael","lastname":"Wilson","email":"michael@example.com","company":"Acme Corp"},{"id":7,"firstname":"Sarah","lastname":"Lee","email":"sarah@example.com","company":"Tech Solutions Ltd"},{"id":8,"firstname":"David","lastname":"Clark","email":"david@example.com","company":"Global Innovations Inc"},{"id":9,"firstname":"Jennifer","lastname":"Taylor","email":"jennifer@example.com","company":"Future Enterprises"},{"id":10,"firstname":"Chris","lastname":"Martinez","email":"chris@example.com","company":"Bright Industries"},{"id":11,"firstname":"William","lastname":"Anderson","email":"william@example.com","company":"Sunrise Corporation"},{"id":12,"firstname":"Olivia","lastname":"Brown","email":"olivia@example.com","company":"Moonlight Ltd"},{"id":13,"firstname":"Daniel","lastname":"Wilson","email":"daniel@example.com","company":"Star Solutions"},{"id":14,"firstname":"Sophia","lastname":"Taylor","email":"sophia@example.com","company":"Galaxy Innovations"},{"id":15,"firstname":"James","lastname":"Johnson","email":"james@example.com","company":"Cosmic Enterprises"},{"id":16,"firstname":"Emma","lastname":"Lee","email":"emma@example.com","company":"Tech Galaxy Inc"},{"id":17,"firstname":"Alexander","lastname":"Clark","email":"alexander@example.com","company":"Future Technologies"},{"id":18,"firstname":"Mia","lastname":"Martinez","email":"mia@example.com","company":"Bright Innovations"},{"id":19,"firstname":"Ethan","lastname":"Harris","email":"ethan@example.com","company":"Sunrise Solutions"},{"id":20,"firstname":"Ava","lastname":"Garcia","email":"ava@example.com","company":"Moonlight Innovations"}]');
            } else if (responseType == 'postForInjection') {
                res.setBody('{"jobId":"750Qy000004hQWPIA2","referenceId":"linkingLeadsKey","selectedLeads":[{"id":1,"firstname":"John","lastname":"Doe","email":"john@example.com","company":"ABC Inc."},{"id":2,"firstname":"Jane","lastname":"Smith","email":"jane@example.com","company":"XYZ Corp"},{"id":3,"firstname":"Alice","lastname":"Johnson","email":"alice@example.com","company":"123 Company"},{"id":4,"firstname":"Bob","lastname":"Brown","email":"bob@example.com","company":"456 Corp"}]}');
            }
            res.setStatusCode(200);
            return res;
        }
    }
}
