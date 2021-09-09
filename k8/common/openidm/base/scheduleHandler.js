/**
 * Script to be placed in IDM script directory to handle the generation of an authorization header 
 * for the scheduler and running of IDM calls to the IGA API.
 */

run();

function run() {
    if (!scanType) {
        logger.warn("Global script variable 'scanType' is not defined.");
        return;
    }

    // Get path of IGA API call
    var path = getApiPath(scanType);
    if (!path) {
        logger.warn("No path defined for scanType: " + scanType);
        return;
    }

    // Get authorization header to allow call to be made from IDM
    var date = new Date().toUTCString();
    var header = getAuthorizationHeaderForSchedule(date);
    if (!header) {
        logger.warn("Could not generate authorization header.");
        return;
    }

    // Get request body and make call
    var body = getRequestBody(scanType)
    makeExternalCall(path, body, date, header)
}

function makeExternalCall(path, body, date, authorizationHeader) {
    var params = {
        url: 'http://iga-api:3005/' + path,
        method: 'POST',
        headers : {
        Date : date,
        Authorization : authorizationHeader
        },
        contentType: 'application/json',
        body: JSON.stringify(body),
      }
      
      var result = openidm.action("external/rest", "call", params);
      return result;
}

function getApiPath(type) {
    switch(type) {
    case 'creation':
        return 'iga/governance/certification/scan/creation';
    case 'refresh':
        return 'iga/governance/refreshAllItems';
    case 'decisionExpiration':
        return 'iga/governance/certification/items/scan/expiration';
    case 'decisionRemediation':
        return 'iga/governance/certification/items/scan/remediation';
    case 'escalationNotification':
        return 'iga/governance/certification/scan/escalationNotification';
    case 'expirationNotification':
        return 'iga/governance/certification/scan/expirationNotification';
    case 'reminderNotification':
        return 'iga/governance/certification/scan/reminderNotification';
    case 'scheduledCertification':
        return 'iga/governance/certification';
    case 'scheduledRecon':
        return '';
    default:
        return null;
    }
}

function getRequestBody(type) {
    switch(type) {
    case 'scheduledCertification':
        return {
            templateId: templateId
        }
    case 'scheduledRecon':
        return {
            
        }
    default:
        return {};
    }
}

function getAuthorizationHeaderForSchedule(date) {
    const mac = javax.crypto.Mac.getInstance("HmacSHA256");
    var secret = new java.lang.String("hmacsecret");
    var secretBytes = secret.getBytes(java.nio.charset.StandardCharsets.UTF_8);
    var secretKeySpec = new javax.crypto.spec.SecretKeySpec(secretBytes,
                        "HmacSHA256");
    mac.init(secretKeySpec);
    const currentDateTimeString =  "Date: " + date + "\n"; 
    new java.lang.String(currentDateTimeString).getBytes(java.nio.charset.StandardCharsets.UTF_8);
    var signedHash = mac.doFinal(new java.lang.String(currentDateTimeString).getBytes(java.nio.charset.StandardCharsets.UTF_8));
    var base64Hash = java.util.Base64.getEncoder().encodeToString(signedHash);
    const authorizationHeader = 'Signature keyId="service1-hmac",algorithm="hmac-sha256",headers="date ", signature="' + base64Hash + '"';
    return authorizationHeader;
}