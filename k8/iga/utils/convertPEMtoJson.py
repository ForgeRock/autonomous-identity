from jwcrypto import jwk
import json
import sys

workspace = './'
publicKeyPEMPath = workspace + 'jwtpublic.pem'
print(publicKeyPEMPath)
verifyKeyJSONPath = workspace + 'verify-key.json'
print(verifyKeyJSONPath)

with open(publicKeyPEMPath, "rb") as pemfile:
    key = jwk.JWK.from_pem(pemfile.read())
    keyJson = key.export()
    print(keyJson)
    with open(verifyKeyJSONPath, 'w') as outfile:
        y = json.loads(keyJson)
        y["kid"] = "auto"
        y["alg"] = "RS512"
        jsonKeySet= {}
        jsonKeySet['keys']= []
        jsonKeySet['keys'].append(y)
        
        json.dump(jsonKeySet, outfile,indent=4)
