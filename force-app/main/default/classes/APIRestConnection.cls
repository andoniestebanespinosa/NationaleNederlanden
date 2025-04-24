public Without Sharing class APIRestConnection {

    public class SecurityException extends Exception{}
    //private
    private static AuthProviderResponse authProviderInfo;

    public static CallOutHelper.genericHeader getHeaderConnection(Integration_Setting__mdt setting) {
        System.debug(logginglevel.DEBUG, 'APIRestConnection ::getHeaderConnection CALLED');
        CallOutHelper.genericHeader header = new CallOutHelper.genericHeader();
        try {
            // Set Certificate
            header.certAuth.certificateName = String.isNotBlank(setting.Certificate__c)? setting.Certificate__c : null;

            //user Auth 2.0, get access token
            AuthProviderResponse auth;
            if (authProviderInfo!=null && authProviderInfo.requestNamedCredential==setting.Named_Credential_API__c) {
                auth = authProviderInfo;
            }
            else {
                auth = getAuthProvider(setting);
            } 

            if (auth==null) throw new SecurityException('User Auth Provider Error');

            if (auth.token_type.equalsIgnoreCase(CallOutHelper.AUTH_BEARER)) {
                header.authorizationType = CallOutHelper.AUTH_BEARER;
                header.bearerAuth.bearer = auth.access_token;
            }
        } catch (Exception e) {
            System.debug(logginglevel.ERROR, 'APIRestConnection::getHeaderConnection ERROR, e: '+ e);
            System.debug(logginglevel.ERROR, 'APIRestConnection::getHeaderConnection TRACE, e: '+ e.getStackTraceString());
        }
        System.debug(logginglevel.DEBUG, 'APIRestConnection::getHeaderConnection END, RETURN header: '+ header);
        return header;
    }
    
    public static AuthProviderResponse getAuthProvider(Integration_Setting__mdt setting) {
        System.debug(logginglevel.DEBUG, 'APIRestConnection ::getAuthProvider CALLED');
        AuthProviderResponse result;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:'+setting.Named_Credential_API__c);
        request.setMethod(CallOutHelper.HTTP_METHOD.POST.name());
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody('grant_type=client_credentials');
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            System.debug(logginglevel.DEBUG, 'CallOutHelper::getAuthProvider getBody: '+ response.getBody());
            result = (AuthProviderResponse) JSON.deserialize(response.getBody(), AuthProviderResponse.class);
            result.requestNamedCredential = setting.Named_Credential_API__c;
            result.requestDateTime = DateTime.now();
        }
        System.debug(logginglevel.DEBUG, 'APIRestConnection::getAuthProvider END, RETURN result: '+ result);
        return result;
    }

    public class AuthProviderResponse {
        //local vars
        public String requestNamedCredential;
        public DateTime requestDateTime;
        //response vars
        public String access_token;
        public String token_type;
        public String scope;
        public Integer expires_in;
        //constructor
        public AuthProviderResponse() {
            this.requestDateTime = this.requestDateTime==null? DateTime.now() : this.requestDateTime;
        }

        public Boolean isExpired() {
            DateTime currentDateTime = DateTime.now();
            DateTime validUntil = (this.expires_in!=null && this.requestDateTime!=null)? this.requestDateTime.addSeconds(this.expires_in) : null;
            return validUntil!=null && (currentDateTime < validUntil) ? false : true;
        }
    }
}