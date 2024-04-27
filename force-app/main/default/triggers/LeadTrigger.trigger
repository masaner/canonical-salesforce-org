trigger LeadTrigger on Lead (after insert) {
    Boolean isFoobarLeads = false;
    String salesRepName = '';
    String linkedJobId = '';
    for (Lead lead : Trigger.new) {
        if (lead.LeadSource == 'Foobar') {
            isFoobarLeads = true;
            salesRepName = lead.Sales_Rep_Name__c;
            linkedJobId = lead.Linked_Job_Id__c;
        } 
        else { return; }
    }

    List<Campaign> matchingCampaigns = new List<Campaign>();
    if(linkedJobId != null){
        matchingCampaigns = [SELECT Id FROM Campaign WHERE Linked_Job_Id__c = :linkedJobId AND Linked_Job_Id__c != null LIMIT 1];
    }
    Campaign campaignRecord;

    String campaignName = 'Foobar - ' + salesRepName + ' - ' + Datetime.now().format();

    if (!matchingCampaigns.isEmpty()) {
        campaignRecord = matchingCampaigns[0];
    } else {
        campaignRecord = new Campaign(
            Name = campaignName,
            IsActive = true,
            Type = 'Other',
            Status = 'Planned',
            Linked_Job_Id__c = linkedJobId
        );
    }

    if(campaignRecord.Id == null){
        Database.SaveResult campaignSaveResult = Database.insert(campaignRecord, false);
    }

    List<CampaignMember> campaignMembers = new List<CampaignMember>();

    for (Lead lead : Trigger.new) {
        if (lead.Id != null) {
            CampaignMember newCampaignMember = new CampaignMember(
                CampaignId = campaignRecord.Id,
                LeadId = lead.Id
            );
            campaignMembers.add(newCampaignMember);
        }
    }

    // Insert the campaign members
    if (!campaignMembers.isEmpty()) {
        Database.SaveResult[] memberSaveResults = Database.insert(campaignMembers, false);
    }
    
}