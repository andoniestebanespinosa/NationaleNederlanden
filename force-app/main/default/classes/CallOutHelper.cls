public Without Sharing class CallOutHelper {

    /**
    * @description Http Status
   */
    public static final Map<Integer, String> MAP_HTTP_STATUS = new Map<Integer, String> {
        100 => 'Continue',
        101 => 'Switching Protocol',
        102 => 'Processing',
        103 => 'Checkpoint',
        //200 - Peticiones correctas
        200 => 'OK',
        201 => 'Created',
        202 => 'Accepted',
        203 => 'Non-Authoritative Information',
        204 => 'No Content',
        205 => 'Reset Content',
        206 => 'Partial Content',
        207 => 'Multi-Status',
        208 => 'Already Reported',
        //300 - Redirecciones
        300 => 'Multiple Choices',
        //400 - Errores del cliente
        400 => 'Bad Request',
        401 => 'Unauthorized',
        402 => 'Payment Required',
        403 => 'Forbidden',
        404 => 'Not Found',
        405 => 'Method Not Allowed',
        406 => 'Not Acceptable',
        407 => 'Proxy Authentication Required',
        408 => 'Request Timeout',
        409 => 'Conflict',
        410 => 'Gone',
        411 => 'Length Required',
        412 => 'Precondition Failed',
        413 => 'Request Entity Too Large',
        414 => 'Request-URI Too Long',
        415 => 'Unsupported Media Type',
        416 => 'Requested Range Not Satisfiable',
        417 => 'Expectation Failed',
        418 => 'Im a teapot',
        421 => 'Misdirected Request',
        422 => 'Unprocessable Entity',
        423 => 'Locked',
        424 => 'Failed Dependency',
        425 => 'Unassigned',
        426 => 'Upgrade Required',
        428 => 'Precondition Required',
        429 => 'Too Many Requests',
        431 => 'Request Header Fields Too Large',
        444 => 'Connection Closed Without Response',
        451 => 'Unavailable For Legal Reasons',
        //500 - Errores de servidor
        500 => 'Internal Server Error',
        501 => 'Not Implemented',
        502 => 'Bad Gateway',
        503 => 'Service Unavailable',
        504 => 'Gateway Timeout',
        505 => 'HTTP Version Not Supported',
        506 => 'Variant Also Negotiates',
        507 => 'Insufficient Storage',
        508 => 'Loop Detected',
        509 => 'Bandwidth Limit Exceeded',
        510 => 'Not Extended',
        511 => 'Network Authentication Required',
        512 => 'Not updated',
        521 => 'Version Mismatch'
    };
    /**
    * @description Http methods
   */
    public enum HTTP_METHOD {
        GET,
        POST,
        PUT,
        PATCH
    }

    /**
     * @description Http response Codes
    */
    public static final Integer HTTP_CODE_OK=200;
    public static final Integer HTTP_CODE_CREATED=201;
    public static final Integer HTTP_CODE_ACCEPTED=202;
    public static final Integer HTTP_CODE_BADREQUEST=400;
    public static final Integer HTTP_CODE_FORBIDDEN=403;
    public static final Integer HTTP_CODE_NOTFOUND=404;
    public static final Integer HTTP_CODE_CONFLICT=409;
    public static final Integer HTTP_CODE_INTERNAL_ERROR=500;
    public static final Integer HTTP_CODE_UNAVAILABLE=503;
    public static final Integer HTTP_CODE_TIMEOUT=504;
    /**
    * @description Error messages
    */
    public static final String ERROR_TIMEOUT='Read timed out';
    public static final String ERROR_INTERNAL='Internal error';
     /**
    * @description Authorization types
    */
    public static final String AUTH_HMAC='HMAC';
    public static final String AUTH_OAUTH2='OAUTH2';
    public static final String AUTH_BASIC='BASIC';
    public static final String AUTH_CERTIF='CERTIFICATION';
    public static final String AUTH_NONE='NONE';
    public static final String AUTH_AMX='AMX';
    public static final String AUTH_BEARER='BEARER';
    public static final String AUTH_APPKEYS='APPKEYS';

    public static final String CONTENT_JSON='application/json';
    public static final String CONTENT_PDF='application/pdf';
    public static final String CONTENT_PLAIN='text/plain';
    public static final String CONTENT_FORM='multipart/form-data';

    public static HttpRequest generateRestRequest(genericHeader header, String body) {
        return generateRestRequest(header, body, null);
    }

    public static HttpRequest generateRestRequest(genericHeader header, Blob body) {
        return generateRestRequest(header, null, body);
    }

    private static HttpRequest generateRestRequest(genericHeader header, String body, Blob bodyBlob) {
        System.debug(logginglevel.DEBUG, 'CallOutHelper::generateRestRequest CALLED');
        HttpRequest request = new HttpRequest(); 
        try 
        {
            
            //Content type
            request.setHeader('Content-Type', header.contentType);
            //Accept type
            request.setHeader('Accept', header.acceptType);
            //EndPoint
            request.setEndpoint(header.endPoint);
            //Http method
            request.setMethod(header.httpMethod);
            //Body
            if(bodyBlob!=null) {
                request.setBodyAsBlob(bodyBlob);
                request.setHeader('Content-Length', String.valueOf(bodyBlob.size()));
            }
            else if(String.isNotBlank(body)) {
                request.setBody(body);
            }
            //Authorization
                //Set Certificate
            if(String.isNotBlank(header.certAuth.certificateName)) {
                request.setClientCertificateName(header.certAuth.certificateName);
            }
                //Basic
            if(header.authorizationType == AUTH_BASIC) {
                request.setHeader('Authorization', generateBasicAuth(header));
            }
                //Bearer
            else if(header.authorizationType == AUTH_BEARER) {
                request.setHeader('Authorization', 'Bearer ' + header.bearerAuth.bearer);
            }
            else if(header.authorizationType == AUTH_APPKEYS){
                request.setHeader('Authorization', 'AppKeys ' + header.appKeysAuth.publicKey + ':' + header.appKeysAuth.secretKey);
            }
        } catch (Exception e) {
            System.debug(logginglevel.ERROR, 'CallOutHelper::generateRestRequest ERROR: ' + e);
        }
        System.debug(logginglevel.DEBUG, 'CallOutHelper::generateRestRequest, END, RETURN request: '+ request);
        return request;
    }

    public static HttpResponse sendRestRequest(HttpRequest request, Integer timeOut) {
        System.debug(logginglevel.DEBUG, 'CallOutHelper::sendRestRequest CALLED, timeOut:' +timeOut);
        HttpResponse response = new HttpResponse();
        try {
            //1-Set timeOut
            request.setTimeout(timeOut);
            //2-Instance http
            Http http = new Http();
            //3-Send Request
            response = http.send(request);
            //4-Set status if is empty
            if (String.isBlank(response.getStatus()) && MAP_HTTP_STATUS.containsKey(response.getStatusCode())) {
                response.setStatus(MAP_HTTP_STATUS.get(response.getStatusCode()));
            }
        } catch (Exception e) {
            System.debug(logginglevel.DEBUG, 'CallOutHelper::sendRestRequest ERROR: '+ e);
            if(e.getMessage() == ERROR_TIMEOUT) {
                response.setStatusCode(HTTP_CODE_TIMEOUT);
            }
            else {
                response.setStatusCode(HTTP_CODE_INTERNAL_ERROR);
            }
            if (MAP_HTTP_STATUS.containsKey(response.getStatusCode())) {
                response.setStatus(MAP_HTTP_STATUS.get(response.getStatusCode()));
            }
        }
        System.debug(logginglevel.DEBUG, 'CallOutHelper::sendRestRequest END, RETURN, response: '+ response);
        return response;
    }

    public static String generateBasicAuth(genericHeader header) {
        System.debug(logginglevel.DEBUG, 'CallOutHelper::generateBasicAuth CALLED');
        String authenticationToken = '';
        String authenticationTokenB64 = '';

        Blob stringToCode = Blob.valueOf(header.basicAuth.user + ':' + header.basicAuth.password);
        authenticationTokenB64 = 'Basic '+ EncodingUtil.base64Encode(stringToCode);

        System.debug(logginglevel.DEBUG, 'CallOutHelper::generateBasicAuth END RETURN, authenticationTokenB64: '+ authenticationTokenB64);
        return authenticationTokenB64;
    }

    public class genericHeader {
     
        //Http method
        public String httpMethod;
        //Authorization type
        public String authorizationType;
        //EndPoint
        public String endPoint;
        //Content type
        public String contentType;
        //Content-Length
        public String contentLength;
        //Accept type
        public String acceptType;
        //Authorization
            //HMAC params
        public hmacAuthParams hmacAuth;
            //Basic params
        public basicAuthParams basicAuth;
            //Certificate params
        public certAuthParams certAuth;
            //AMX params
        public amxAuthParams amxAuth;
            //Bearer params
        public bearerAuthParams bearerAuth;
            //AppKeys params
        public appKeysAuthParams appKeysAuth;
        //Constructor
        public genericHeader() {
            //Default content type
            contentType = CONTENT_JSON;
            acceptType = CONTENT_JSON;
            hmacAuth = new hmacAuthParams();
            basicAuth = new basicAuthParams();
            certAuth = new certAuthParams();
            amxAuth = new amxAuthParams();
            bearerAuth = new bearerAuthParams();
            appKeysAuth = new appKeysAuthParams();
        }
    }

   
    public class hmacAuthParams {
        public String secret;
        public String appID;
        //Constructors
        public hmacAuthParams(){}
        public hmacAuthParams(String secret, String appId) {
            this.secret = secret;
            this.appId = appId;
        }
    }

    public class basicAuthParams {
        public String user;
        public String password;
        //Constructors
        public basicAuthParams(){}
        public basicAuthParams(String user, String password) {
            this.user= user;
            this.password = password;
        }
    }

    public class certAuthParams {
        public String certificateName;
        //Constructors
        public certAuthParams(){}
        public certAuthParams(String certificateName) {
            this.certificateName = certificateName;
        }
    }

    public class amxAuthParams {
        public String apiKey;
        public String appID;
         //Constructors
        public amxAuthParams(){}
        public amxAuthParams(String apiKey, String appId) {
            this.apiKey = apiKey;
            this.appId = appId;
        }
    }

    public class bearerAuthParams {
        public String bearer;
        //Constructors
        public bearerAuthParams(){}
        public bearerAuthParams(String bearer) {
            this.bearer = bearer;
        }
    }
    public class appKeysAuthParams{
        public String publicKey;
        public String secretKey;
        public appKeysAuthParams(){}
        public appKeysAuthParams(String publicKey, String secretKey){
            this.publicKey = publicKey;
            this.secretKey = secretKey;
        }
    }
}
