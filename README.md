# Octoblu Trigger Service
Service to list and activate Octoblu triggers within running flows

[![Build Status](https://travis-ci.org/octoblu/triggers-service.svg?branch=master)](https://travis-ci.org/octoblu/triggers-service)
[![Code Climate](https://codeclimate.com/github/octoblu/triggers-service/badges/gpa.svg)](https://codeclimate.com/github/octoblu/triggers-service)
[![Test Coverage](https://codeclimate.com/github/octoblu/triggers-service/badges/coverage.svg)](https://codeclimate.com/github/octoblu/triggers-service)
[![npm version](https://badge.fury.io/js/triggers-service.svg)](http://badge.fury.io/js/triggers-service)
[![Gitter](https://badges.gitter.im/octoblu/help.svg)](https://gitter.im/octoblu/help)

## Supported Auth Methods

* cookies: `request.cookies.meshblu_auth_uuid` and `request.cookies.meshblu_auth_token`
* headers: `request.cookies.meshblu_auth_uuid` and `request.cookies.meshblu_auth_token`
* basic: `Authorization: Basic c3VwZXItcGluazpwaW5raXNoLXB1cnBsZWlzaAo=`
* bearer: `Authorization: Bearer c3VwZXItcGluazpwaW5raXNoLXB1cnBsZWlzaAo=`

## Get Triggers Example:
    curl https://username:password@triggers.octoblu.com/triggers

### Aliases
    curl https://username:password@triggers.octoblu.com/mytriggers
    curl https://username:password@triggers.octoblu.com/my-triggers

### Response
    =>
    [{
      "id" : "396f2cf4-b352-4e38-b2f4-3f64ef854de8",
      "name" : "trigger",
      "flowId" : "5b76ec5d-fea2-4160-97c2-cf10fe847158",
      "flowName" : "sample",
      "online": true,
      "uri": "https://triggers.octoblu.com/flows/5b76ec5d-fea2-4160-97c2-cf10fe847158/triggers/396f2cf4-b352-4e38-b2f4-3f64ef854de8"
    }]

##  Filter Triggers Example:
    curl https://username:password@triggers.octoblu.com/all-triggers?flowContains=device:generic&flowContains=device:twitter

### Response
    =>
    [{
      "id" : "396f2cf4-b352-4e38-b2f4-3f64ef854de8",
      "name" : "trigger",
      "flowId" : "5b76ec5d-fea2-4160-97c2-cf10fe847158",
      "flowName" : "sample",
      "online": true,
      "uri": "https://triggers.octoblu.com/flows/5b76ec5d-fea2-4160-97c2-cf10fe847158/triggers/396f2cf4-b352-4e38-b2f4-3f64ef854de8"
    }]

## Get All Triggers Example:
    curl https://username:password@triggers.octoblu.com/all-triggers

### Response
    =>
    [{
      "id" : "396f2cf4-b352-4e38-b2f4-3f64ef854de8",
      "name" : "trigger",
      "flowId" : "5b76ec5d-fea2-4160-97c2-cf10fe847158",
      "flowName" : "sample",
      "online": true,
      "uri": "https://triggers.octoblu.com/flows/5b76ec5d-fea2-4160-97c2-cf10fe847158/triggers/396f2cf4-b352-4e38-b2f4-3f64ef854de8"
    }]

## Activate Trigger Example:
    curl -X POST https://username:password@triggers.octoblu.com/flows/:flowId/triggers/:id

## Activate Trigger By Name Example:
    curl -X POST https://username:password@triggers.octoblu.com/flows/triggers/:triggerName

## PowerShell examples of the above commands
    $meAuth = @{ meshblu_auth_uuid = 'user uuid'; meshblu_auth_token = 'user token' }

### return all of my triggers
    $myTriggers = Invoke-RestMethod -URI http://triggers.octoblu.com/mytriggers -ContentType "application/json" -Headers $meAuth -Method Get

### Return my Triggers where there is a Hue device in the flow
    $myTriggersCtxwin = Invoke-RestMethod -URI http://triggers.octoblu.com/all-triggers?flowContains=device:hue -ContentType "application/json" -Headers $meAuth -Method Get

### then an individual flow behind a trigger 
    $myFlow = Invoke-RestMethod -URI ("http://meshblu.octoblu.com/devices/" + $myTriggers[0].flowId ) -ContentType "application/json" -Headers $meAuth -Method Get

### activate a trigger
    Invoke-RestMethod -URI ( "http://triggers.octoblu.com/flows/" + $myTriggers[0].flowId + "/triggers/" + $myTriggers[0].id ) -ContentType "application/json" -Headers $meAuth -Method Post
