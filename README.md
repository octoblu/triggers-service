# Octoblu Trigger Service
Service to list and activate Octoblu triggers within running flows

[![Build Status](https://travis-ci.org/octoblu/triggers-service.svg?branch=master)](https://travis-ci.org/octoblu/triggers-service)
[![Code Climate](https://codeclimate.com/github/octoblu/triggers-service/badges/gpa.svg)](https://codeclimate.com/github/octoblu/triggers-service)
[![Test Coverage](https://codeclimate.com/github/octoblu/triggers-service/badges/coverage.svg)](https://codeclimate.com/github/octoblu/triggers-service)
[![npm version](https://badge.fury.io/js/triggers-service.svg)](http://badge.fury.io/js/triggers-service)
[![Gitter](https://badges.gitter.im/octoblu/help.svg)](https://gitter.im/octoblu/help)

# Table of Contents

* [Authentication](#authentication)
* [REST API](#rest-api)
  * [Activate a Trigger](#activate-a-trigger)
  * [Get All Triggers](#get-all-triggers)
  * [Get Triggers](#)

# Authentication

The triggers API supports all the [Meshblu Auth](https://github.com/octoblu/express-meshblu-auth) methods. It will check for the following values:

* Using Cookies with the following names:
  * `meshblu_auth_uuid` The UUID of the device to auth as
  * `meshblu_auth_token` The Token of the device to auth as
* Using Headers with the following keys:
  * `meshblu_auth_uuid` The UUID of the device to auth as
  * `meshblu_auth_token` The Token of the device to auth as
* Basic Auth using the base64 encoded `uuid:token` string
  * `Authorization: Basic c3VwZXItcGluazpwaW5raXNoLXB1cnBsZWlzaAo=`
* Bearer using the base64 encoded `uuid:token` string:
  * `Authorization: Bearer c3VwZXItcGluazpwaW5raXNoLXB1cnBsZWlzaAo=`

# REST API

### Activate a Trigger

```http
POST /flows/:flowId/triggers/:triggerId
```

Activate a trigger in a flow. This causes the trigger service to send a Meshblu message to the flow to tell it to trigger. If no authentication information is passed, it will send the message as the identity of the Trigger Service.

In order to activate the trigger, the trigger service's UUID must be in the flow's `message.from` whitelist. Generally, the [Octoblu](https://octoblu.com) Designer will manage the Whitelist for the user. See the [Meshblu whitelist documentation](https://meshblu.readme.io/docs/whitelists-2-0) for more information.

Additionally, any POST data sent will be made available to the flow

#### Response

```json
{
  "triggered":true
}
```

#### Curl Example

```shell
# With no data
curl -X POST \
  https://triggers.octoblu.com/flows/d8140878-7a88-461c-9036-257a5b336caa/triggers/3a12d4e0-21c7-11e6-87d2-799e938b6bc1

# With form-urlencoded data
curl -X POST \
  -d foo=bar \
  https://triggers.octoblu.com/flows/d8140878-7a88-461c-9036-257a5b336caa/triggers/3a12d4e0-21c7-11e6-87d2-799e938b6bc1

# With JSON data
curl -X POST \
  -H 'content-type: application/json' \
  -d '{"foo": "bar"}' \
  https://triggers.octoblu.com/flows/d8140878-7a88-461c-9036-257a5b336caa/triggers/3a12d4e0-21c7-11e6-87d2-799e938b6bc1

# With custom authentication
UUID=fd205f32-7846-4057-911b-3d580747b6c9
TOKEN=9f63aaa056618ee5c79197660c4de874718e41da

curl -X POST \
  https://${UUID}:${TOKEN}@triggers.octoblu.com/flows/d8140878-7a88-461c-9036-257a5b336caa/triggers/3a12d4e0-21c7-11e6-87d2-799e938b6bc1
```

#### PowerShell Example

```PowerShell
# With no data
Invoke-RestMethod  `
  -URI "https://triggers.octoblu.com/flows/d8140878-7a88-461c-9036-257a5b336caa/triggers/3a12d4e0-21c7-11e6-87d2-799e938b6bc1" `
  -Method Post

# With form-urlencoded data
Invoke-RestMethod  `
  -URI "https://triggers.octoblu.com/flows/d8140878-7a88-461c-9036-257a5b336caa/triggers/3a12d4e0-21c7-11e6-87d2-799e938b6bc1" `
  -Method Post `
  -Body @{'foo'='bar'}

# With JSON data
Invoke-RestMethod  `
  -URI "https://triggers.octoblu.com/flows/d8140878-7a88-461c-9036-257a5b336caa/triggers/3a12d4e0-21c7-11e6-87d2-799e938b6bc1" `
  -ContentType "application/json" `
  -Method Post `
  -Body '{"foo":"bar"}'

# With custom authentication
$meAuth = @{meshblu_auth_uuid='fd205f32-7846-4057-911b-3d580747b6c9'; meshblu_auth_token='9f63aaa056618ee5c79197660c4de874718e41da'}

Invoke-RestMethod  `
  -URI "https://triggers.octoblu.com/flows/d8140878-7a88-461c-9036-257a5b336caa/triggers/3a12d4e0-21c7-11e6-87d2-799e938b6bc1" `
  -Headers $meAuth `
  -Method Post
```

### Get All Triggers

```http
GET /all-triggers
```

Retrieve all Triggers available. This causes the trigger to perform a Meshblu Search for flows as the device whose authentication was passed in. There is no default identity for this endpoint, so unauthenticated requests will return an HTTP 401.

In order to discover a trigger, the authenticated device must be present in the Flow's `discover.view` whitelist. See the [Meshblu whitelist documentation](https://meshblu.readme.io/docs/whitelists-2-0) for more information.

Optionally, flowContains values may be provided as query parameters to filter the triggers before they are returned. Multiple flowContains values are combined using AND. For example, providing a flowContains=device:drone&flowContains=device:camera will only retrieve triggers from flows containing BOTH a `device:drone` and `device:camera` node.

#### Response

```json
[{
  "id" : "396f2cf4-b352-4e38-b2f4-3f64ef854de8",
  "name" : "trigger",
  "flowId" : "5b76ec5d-fea2-4160-97c2-cf10fe847158",
  "flowName" : "sample",
  "online": true,
  "uri": "https://triggers.octoblu.com/flows/5b76ec5d-fea2-4160-97c2-cf10fe847158/triggers/396f2cf4-b352-4e38-b2f4-3f64ef854de8"
}]
```

#### Curl Example

```shell
# Return all triggers
curl https://triggers.octoblu.com/all-triggers

# With a filter
curl https://triggers.octoblu.com/all-triggers?flowContains=device:drone

# With custom authentication
UUID=fd205f32-7846-4057-911b-3d580747b6c9
TOKEN=9f63aaa056618ee5c79197660c4de874718e41da

curl -X POST \
  https://${UUID}:${TOKEN}@triggers.octoblu.com/flows/d8140878-7a88-461c-9036-257a5b336caa/triggers/3a12d4e0-21c7-11e6-87d2-799e938b6bc1
```

#### PowerShell Example

```PowerShell
# With no data
Invoke-RestMethod  `
  -URI "https://triggers.octoblu.com/flows/d8140878-7a88-461c-9036-257a5b336caa/triggers/3a12d4e0-21c7-11e6-87d2-799e938b6bc1" `
  -Method Post

# With form-urlencoded data
Invoke-RestMethod  `
  -URI "https://triggers.octoblu.com/flows/d8140878-7a88-461c-9036-257a5b336caa/triggers/3a12d4e0-21c7-11e6-87d2-799e938b6bc1" `
  -Method Post `
  -Body @{'foo'='bar'}

# With JSON data
Invoke-RestMethod  `
  -URI "https://triggers.octoblu.com/flows/d8140878-7a88-461c-9036-257a5b336caa/triggers/3a12d4e0-21c7-11e6-87d2-799e938b6bc1" `
  -ContentType "application/json" `
  -Method Post `
  -Body '{"foo":"bar"}'

# With custom authentication
$meAuth = @{meshblu_auth_uuid='fd205f32-7846-4057-911b-3d580747b6c9'; meshblu_auth_token='9f63aaa056618ee5c79197660c4de874718e41da'}

Invoke-RestMethod  `
  -URI "https://triggers.octoblu.com/flows/d8140878-7a88-461c-9036-257a5b336caa/triggers/3a12d4e0-21c7-11e6-87d2-799e938b6bc1" `
  -Headers $meAuth `
  -Method Post
```










####################

### Get Triggers

# Examples

## Curl

### Get Triggers
```shell
curl https://username:password@triggers.octoblu.com/triggers
# aliases
curl https://username:password@triggers.octoblu.com/mytriggers
curl https://username:password@triggers.octoblu.com/my-triggers
```

##### Response
```json
[{
  "id" : "396f2cf4-b352-4e38-b2f4-3f64ef854de8",
  "name" : "trigger",
  "flowId" : "5b76ec5d-fea2-4160-97c2-cf10fe847158",
  "flowName" : "sample",
  "online": true,
  "uri": "https://triggers.octoblu.com/flows/5b76ec5d-fea2-4160-97c2-cf10fe847158/triggers/396f2cf4-b352-4e38-b2f4-3f64ef854de8"
}]
```

### Filter Triggers
```shell
curl https://username:password@triggers.octoblu.com/all-triggers?flowContains=device:generic&flowContains=device:twitter
```

##### Response
```json
[{
  "id" : "396f2cf4-b352-4e38-b2f4-3f64ef854de8",
  "name" : "trigger",
  "flowId" : "5b76ec5d-fea2-4160-97c2-cf10fe847158",
  "flowName" : "sample",
  "online": true,
  "uri": "https://triggers.octoblu.com/flows/5b76ec5d-fea2-4160-97c2-cf10fe847158/triggers/396f2cf4-b352-4e38-b2f4-3f64ef854de8"
}]
```

### Get All Triggers:
```shell
curl https://username:password@triggers.octoblu.com/all-triggers
```

##### Response
```json
[{
  "id" : "396f2cf4-b352-4e38-b2f4-3f64ef854de8",
  "name" : "trigger",
  "flowId" : "5b76ec5d-fea2-4160-97c2-cf10fe847158",
  "flowName" : "sample",
  "online": true,
  "uri": "https://triggers.octoblu.com/flows/5b76ec5d-fea2-4160-97c2-cf10fe847158/triggers/396f2cf4-b352-4e38-b2f4-3f64ef854de8"
}]
```

### Activate Trigger:
```shell
curl -X POST https://username:password@triggers.octoblu.com/flows/:flowId/triggers/:id
```

### Activate Trigger By Name:
```shell
curl -X POST https://username:password@triggers.octoblu.com/flows/triggers/:triggerName
```

## PowerShell

Commands assume:
```PowerShell
$meAuth = @{ meshblu_auth_uuid = 'user uuid'; meshblu_auth_token = 'user token' }
```

### Get my triggers
```PowerShell
$myTriggers = Invoke-RestMethod -URI http://triggers.octoblu.com/mytriggers -ContentType "application/json" -Headers $meAuth -Method Get
```

### Filter Triggers
```PowerShell
Invoke-RestMethod -URI http://triggers.octoblu.com/all-triggers?flowContains=device:hue -ContentType "application/json" -Headers $meAuth -Method Get
```

### Activate Trigger
```PowerShell
Invoke-RestMethod -URI ( "http://triggers.octoblu.com/flows/" + $myTriggers[0].flowId + "/triggers/" + $myTriggers[0].id ) -ContentType "application/json" -Headers $meAuth -Method Post
```
