/**
 * Script to be placed in IDM script directory to allow the IGA API to be called an authenticated in a simple and readable fashion 
 * within IDM workflows and scripts.
 * 
 * Example:  var result = openidm.action('iga/governance/certification/:id', 'GET')
 * Example:  var result = openidm.action('iga/governance/applications/<id>/activate', 'POST', {})
 */

run();

function run() {
    var path = request.resourcePath;
    var body = request.content;
    var method = request.action;
    var params = request.additionalParameters;

    if (!path) {
        logger.warn("No path provided to call IGA API.")
        return;
    }

    if (!method) {
        logger.warn("Must provide a request method as the 'action' when calling an IGA API.");
        return;
    }
    else {
        method = method.toUpperCase();
    }

    return makeExternalCall(path, method, body, params)
}

function generateUrl(path, queryParams) {
    var url = 'http://iga-api:3005/iga/' + path;
    if (queryParams != null && Object.keys(queryParams).length > 0) {
        var params = '';
        if (typeof queryParams === 'object') {
            var paramsList = [];
            Object.keys(queryParams).forEach(function(key) {
                paramsList.push(key + '=' + queryParams[key])
            })
            params = paramsList.join('&');
        }
        else {
            params = queryParams;
        }
        url = url + '?' + params;
    }
    return url;
}

function makeExternalCall(path, method, body, queryParams) {
    // Get authorization header to allow call to be made from IDM
    var url = generateUrl(path, queryParams);
    var date = new Date().toUTCString();
    var header = getAuthorizationHeaderForIGA(date);
    if (!header) {
        logger.warn("Could not generate authorization header.");
        return;
    }
    var params = {
        url: url,
        method: method,
        headers : {
        Date : date,
        Authorization : header
        },
        contentType: 'application/json',
        body: JSON.stringify(body),
      }
      var result = openidm.action("external/rest", "call", params);
      return result;
}

function getAuthorizationHeaderForIGA(date) {
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