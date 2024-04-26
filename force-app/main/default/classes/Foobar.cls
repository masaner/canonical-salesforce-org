public class Foobar {
    @AuraEnabled(cacheable=true)
    public static String getLeads() {
        // Initialize HTTP objects
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://foobar-vercel.vercel.app/leads');
        request.setMethod('GET');

        // Send the request and handle the response
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            // Success: Return response body
            return response.getBody();
        } else {
            // Error: Return error message
            return 'Error: ' + response.getStatusCode() + ' ' + response.getStatus();
        }
    }

    @AuraEnabled(cacheable=true)
    public static String sendPostRequest(String selectedIds) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://foobar-vercel.vercel.app/leads');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        
        String jsonBody = '{"selectedIds": "' + selectedIds + '"}';
        System.debug(jsonBody);
        request.setBody(jsonBody);

        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            // Success
            System.debug('POST Response Body: ' + response.getBody());
        } else {
            // Error
            System.debug('Error Code: ' + response.getStatusCode());
            System.debug('Error Message: ' + response.getStatus());
        }

        return response.getBody();
    }
}
