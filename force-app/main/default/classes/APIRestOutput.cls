public with sharing class APIRestOutput {
    public class RequestException extends Exception {}
    public enum GATEWAY_RESOURCE {
        getCountries
            
    }
            
    public static final Map<String, CallOutHelper.HTTP_METHOD> RESOURCE_HTTP_METHOD = new Map<String, CallOutHelper.HTTP_METHOD> {
        GATEWAY_RESOURCE.getCountries.name()              => CallOutHelper.HTTP_METHOD.GET
    };
    public static final string ERROR_INVALID_CUSTOM_METADATA_TYPE='Custom Metadata (Integration_Setting__mdt) not found or disabled';
    public static final string ERROR_INVALID_RESOURCE='Invalid resource';  
    
    
	public static final string METADATA_COUNTRY_NAME='getCountryData'; 
    
    
    public static output_Wrapper getCountryData() {
        Object Request = null;//This object is used for making a call with input parameters, in this case, as there are not inputs and its just a GET, we stablish as null
        output_Wrapper response = request(request,GATEWAY_RESOURCE.getCountries);
        
        
        if(!system.isBatch() && response.body != null && !response.body.isEmpty()) {
			System.enqueueJob(new InsertCountriesQueueable(response.body));
          
        }
        system.debug('@@response ' + response);
        return response;
        
        
    }
    
    public static output_Wrapper request(Object requestData, GATEWAY_RESOURCE resource) {
        
        return request(requestData, RESOURCE_HTTP_METHOD.get(resource.name()), resource.name());
    }

    public static output_Wrapper request(Object requestData, CallOutHelper.HTTP_METHOD httpMethod, String resource) {
        output_Wrapper responseData = new output_Wrapper();
        try {
			Integration_Setting__mdt intSetting = Integration_Setting__mdt.getInstance(METADATA_COUNTRY_NAME);
            
            //Check Integration setting found and active
            if ((intSetting==null) || (intSetting!=null && !intSetting.Active__c)) throw new RequestException(ERROR_INVALID_CUSTOM_METADATA_TYPE);
            //build header
            CallOutHelper.genericHeader header = new CallOutHelper.genericHeader();
		
            //HTTP Method
            header.httpMethod = httpMethod.name();
            //Endpoint
            header.endPoint = 'callout:'+intSetting.Named_credential_API__c + intSetting.EndPoint__c + '?access_key=' + intSetting.Token__c;

            //build request
            String requestBody = requestData!=null? JSON.serialize(requestData, true) : '';
            
            httpRequest request = CallOutHelper.generateRestRequest(header, requestBody);

            //build Response
            HttpResponse response = CallOutHelper.sendRestRequest(request, Integer.valueOf(intSetting.TimeOut__c));

            responseData.success = (response.getStatusCode()==CallOutHelper.HTTP_CODE_OK || response.getStatusCode() == CallOutHelper.HTTP_CODE_CREATED);
            responseData.message = response.getStatus();
            responseData.response_code = response.getStatusCode();
            responseData.body = (List<APIRestInput.CountryData>) JSON.deserialize(response.getBody(), List<APIRestInput.CountryData>.class);
            
            System.debug(logginglevel.DEBUG, 'APIRestOutput::request responseBody: ' + response.getBody());
            
            //LogUtil.insertLog(response.getStatus(), responseData.message, '', 'APIRestOutput::'+resource, responseBody, requestBody, '', String.valueOf(response.getStatusCode()), intSetting.Label, header.endPoint);
        } catch (Exception e){
            System.debug(logginglevel.ERROR, 'APIRestOutput::request, ERROR: ' +e);
            responseData.success = false;
            responseData.message = e.getMessage();
            responseData.response_code = CallOutHelper.HTTP_CODE_INTERNAL_ERROR;
            //LogUtil.insertLog(CallOutHelper.ERROR_INTERNAL, responseData.message, e.getStackTraceString(), 'APIRestOutput::'+ resource, null, null, null, String.valueOf(CallOutHelper.HTTP_CODE_INTERNAL_ERROR), 'Callout Mulesoft Error', '');
        }
        return responseData;
    }
    
    public class output_Wrapper {
        public boolean success;
        public integer response_code;
        public string message;
        public List<ApiRestInput.CountryData> body;
    }
}