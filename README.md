# Octoblu Trigger Service
Service to list and activate Octoblu triggers

## Supported Auth Methods

* cookies: `request.cookies.meshblu_auth_uuid` and `request.cookies.meshblu_auth_token`
* headers: `request.cookies.meshblu_auth_uuid` and `request.cookies.meshblu_auth_token`
* basic: `Authorization: Basic c3VwZXItcGluazpwaW5raXNoLXB1cnBsZWlzaAo=`
* bearer: `Authorization: Bearer c3VwZXItcGluazpwaW5raXNoLXB1cnBsZWlzaAo=`

## Get Triggers Example:
    curl https://username:password@triggers.octoblu.com/triggers

    =>
    [{
      "id" : "396f2cf4-b352-4e38-b2f4-3f64ef854de8",
      "name" : "trigger",
      "flowId" : "5b76ec5d-fea2-4160-97c2-cf10fe847158",
      "flowName" : "sample",
      "uri": "https://triggers.octoblu.com/flows/5b76ec5d-fea2-4160-97c2-cf10fe847158/triggers/396f2cf4-b352-4e38-b2f4-3f64ef854de8"
    }]

## Activate Trigger Example:
    curl -X POST https://triggers.octoblu.com/flows/:flowId/triggers/:id -H 'meshblu_auth_uuid: uuid' -H 'meshblu_auth_token: token'
