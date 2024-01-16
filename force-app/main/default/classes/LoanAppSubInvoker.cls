global with sharing class LoanAppSubInvoker {
    
    @invocableMethod(label = 'Loan Application Submission Invoker' description = 'Submits details of a loan app to the loan app submission business process' category = 'SimpleNexus')
    global static List<String> getStateData(List<LoanAppDetails> loanAppDetails) {

        LoanAppDetails loanAppDetail = loanAppDetails[0];
        String stateData = formActivityData(loanAppDetail);
        String bpoName = 'loanAppSubmissionV3';
        runBPO(bpoName, stateData, loanAppDetail);

        List<String> stateDataList = new List<String>{stateData};
        return stateDataList;
    }

    public static void runBPO(String bpoName, String stateData, LoanAppDetails loanAppDetail) {
        
        String configs = getConfigs(bpoName);
        
        Map<String,Object> queryResultsMap = new Map<String,Object>();
        queryResultsMap.put('queryResults', stateData);
        
        Map<String, Object> stateMap = new Map<String, Object>{
            'activityData' => queryResultsMap,
            'activityConfig' => configs,
            'opportunityId' => loanAppDetail.oppId,
            'contactId' => loanAppDetail.conId
        };

        try {
            nFORCE.ACrossPackageService service = (nFORCE.ACrossPackageService) nFORCE.BeanFactory.getInstance()
                .getBeanByUniqueName('nFORCE.BPOQueueServiceXPkg');
            
            service.setInputParameter( 'stateData', stateMap);
            service.setInputParameter( 'businessProcessKey' , bpoName);
            service.setInputParameter( 'commitWork', true);
            service.executeService();  
            
        } catch (Exception ex){
            
            system.debug(ex.getMessage());
            throw ex;
        }  
  
    }

    @testVisible
    private static String getConfigs(String key){
        List <nSN__BPO_Config__mdt> configList = [SELECT nSN__Configuration__c, nSN__BPO_Key__c
                                                    FROM nSN__BPO_Config__mdt
                                                    WHERE nSN__BPO_Key__c =: key];
        
        String configs = configList[0].nSN__Configuration__c;
        return configs;
    }
    
    public static String formActivityData(LoanAppDetails loanAppDetail) {
        
        Dom.Document document = new Dom.Document();
        document.createRootElement('root', null, null);
        Dom.XmlNode entryNode = document.getRootElement().addChildElement('entry', null, null);
        entryNode.addChildElement('OpportunityId', null, null).addTextNode(loanAppDetail.oppId);
        entryNode.addChildElement('ContactId', null, null).addTextNode(loanAppDetail.conId);
        
        Dom.XmlNode contactNode = entryNode.addChildElement('Contact', null, null);
        Dom.XmlNode attributesNode = contactNode.addChildElement('attributes', null, null);
        attributesNode.addChildElement('Id', null, null).addTextNode(loanAppDetail.conId);
        attributesNode.addChildElement('FirstName', null, null).addTextNode(loanAppDetail.brFirstName);
        attributesNode.addChildElement('LastName', null, null).addTextNode(loanAppDetail.brLastName);
        attributesNode.addChildElement('Email',null, null).addTextNode(loanAppDetail.brEmail);
        if(loanAppDetail.salutatuion!= null) {
            attributesNode.addChildElement('Salutation', null, null).addTextNode(loanAppDetail.salutatuion);
        }
        if(loanAppDetail.brPhone!= null) {
            attributesNode.addChildElement('Phone', null, null).addTextNode(loanAppDetail.brPhone);
        }
        if(loanAppDetail.brHomePhone!= null) {
            attributesNode.addChildElement('HomePhone', null, null).addTextNode(loanAppDetail.brHomePhone);
        }
        if(loanAppDetail.brMobilePhone!= null) {
            attributesNode.addChildElement('MobilePhone', null, null).addTextNode(loanAppDetail.brMobilePhone);
        }
        if(loanAppDetail.brMailingStreet != null) {
            attributesNode.addChildElement('MailingStreet', null, null).addTextNode(loanAppDetail.brMailingStreet);
        }
        if(loanAppDetail.brCity!= null) {
            attributesNode.addChildElement('MailingCity', null, null).addTextNode(loanAppDetail.brCity);
        }
        if(loanAppDetail.brState!= null) {
            attributesNode.addChildElement('MailingState', null, null).addTextNode(loanAppDetail.brState);
        }   
        if(loanAppDetail.brZip!= null) {
            attributesNode.addChildElement('MailingPostalCode', null, null).addTextNode(loanAppDetail.brZip);
        }
        
        Dom.XmlNode opportunityNode = entryNode.addChildElement('Opportunity', null, null);
        Dom.XmlNode oppAttributesNode = opportunityNode.addChildElement('attributes', null, null);
        oppAttributesNode.addChildElement('Id',null, null).addTextNode(loanAppDetail.oppId);
        oppAttributesNode.addChildElement('Name', null, null).addTextNode(loanAppDetail.oppName);
        oppAttributesNode.addChildElement('OwnerId', null, null).addTextNode(loanAppDetail.ownerId);
        if(loanAppDetail.amount!= null) {
            oppAttributesNode.addChildElement('Amount', null, null).addTextNode(String.valueOf(loanAppDetail.amount));
        }

        Dom.XmlNode loNode = opportunityNode.addChildElement('Owner', null, null);
        Dom.XmlNode loAttributesNode = loNode.addChildElement('attributes', null, null);
        loAttributesNode.addChildElement('Id', null, null).addTextNode(loanAppDetail.ownerId);
        loAttributesNode.addChildElement('Email', null, null).addTextNode(loanAppDetail.loEmail);

        String stateData = document.toXmlString();
        System.debug(stateData);
        return stateData;
    }


    global class LoanAppDetails {
        
        @InvocableVariable(label = 'Opportunity id' required = true description = 'Opportunity ID')
        public String oppId;

        @InvocableVariable(label = 'Opportunity amount' required = true description = 'Opportunity Amount')
        public Integer amount;

        @InvocableVariable(label = 'Opportunity name' required = true description = 'Opportunity Name')
        public String oppName;

        @InvocableVariable(label = 'Contact Id' required=true description = 'Contact ID')
        public String conId;

        @InvocableVariable(label = 'Borrower salutation' required = false description = 'Salutation of the borrower')
        public string salutatuion;

        @InvocableVariable(label = 'Borrower first name' required = true description = 'First name of the borrower')
        public string brFirstName;

        @InvocableVariable(label = 'Borrower last name' required = true description = 'Last name of the borrower')
        public string brLastName;

        @InvocableVariable(label = 'Borrower phone' required = false description = 'Phone number of the borrower')
        public string brPhone;

        @InvocableVariable(label = 'Borrower email' required = true description = 'Email of the loan officer')
        public string brEmail;

        @InvocableVariable(label = 'Home phone' required = false description = 'Home phone of the borrower')
        public string brHomePhone;

        @InvocableVariable(label = 'Mobile phone' required = false description = 'Mobile phone of the borrower')
        public string brMobilePhone;

        @InvocableVariable(label = 'Mailing street' required = false description = 'Mailing street of the borrower')
        public string brMailingStreet;

        @InvocableVariable(label = 'City' required = false description = 'City of the borrower')
        public string brCity;

        @InvocableVariable(label ='State' required = false description = 'State of the borrower')
        public string brState;

        @InvocableVariable(label = 'Zip' required = false description = 'Zip of the borrower')
        public string brZip;

        @InvocableVariable(label = 'Loan officer email' required = true description = 'Email of the loan officer')
        public string loEmail;

        @InvocableVariable(label = 'Owner Id' required = true description = 'Owner ID')
        public string ownerId;
        

    }
}