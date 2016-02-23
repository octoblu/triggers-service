# Octoblu Trigger Service
Service to list and activate Octoblu triggers

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
