public class Foobar {
    @AuraEnabled(cacheable=true)
    public static String getLeads() {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Foobar/leads');
        request.setMethod('GET');
        Http http = new Http();
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            return response.getBody();
        } else {
            return 'Error: ' + response.getStatusCode() + ' ' + response.getStatus();
        }
    }

    @AuraEnabled(cacheable=true)
    public static String sendPostRequest(String relatedJobId, String selectedIds, String salesRepName) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Foobar/leads');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        
        String jsonBody = relatedJobId != null ? 
            '{"selectedIds": "' + selectedIds + '","salesRepName": "' + salesRepName + '","linkWithId": "' + relatedJobId + '"}' : 
            '{"selectedIds": "' + selectedIds + '","salesRepName": "' + salesRepName + '","linkWithId": null}';

        request.setBody(jsonBody);

        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            return response.getBody();
        } else {
            return 'Error: ' + response.getStatusCode() + ' ' + response.getStatus();
        }
    }
}
