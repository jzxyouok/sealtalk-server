request = require 'supertest'
app     = require '../../src'

beforeAll ->

  this.phoneNumber1 = '13' + Math.floor(Math.random() * 99999999 + 900000000)
  this.phoneNumber2 = '13' + Math.floor(Math.random() * 99999999 + 900000000)
  this.phoneNumber3 = '13' + Math.floor(Math.random() * 99999999 + 900000000)

  #this.username1 = 'arielyang'
  #this.username2 = 'novasman'
  #this.username3 = 'luckyjiang'

  this.nickname1 = 'Ariel Yang'
  this.nickname2 = 'Novas Man'
  this.nickname3 = 'Lucky Jiang'

  this.userId1 = null
  this.userId2 = null
  this.userId3 = null

  this.password = 'P@ssw0rd'
  this.passwordNew = 'P@ssw0rdNew'

  this.groupName1 = 'Business'
  this.groupName2 = 'Product'

  this.groupId1 = null
  this.groupId2 = null

  this.cookie = null

  this.testPOSTAPI = (path, params, statusCode, testBody, callback) ->
    _this = this

    setTimeout ->
      request app
        .post path
        .type 'json'
        .send params
        .end (err, res) ->
          _this.testHTTPResult err, res, statusCode, testBody
          callback res.body, res.header['set-cookie'] if callback
    , 10

  this.testGETAPI = (path, statusCode, testBody, callback) ->
    console.log '---------------------------------------', path
    _this = this

    setTimeout ->
      request app
        .get path
        .end (err, res) ->
          _this.testHTTPResult err, res, statusCode, testBody
          callback res.body if callback
    , 10

  this.testHTTPResult = (err, res, statusCode, testBody) ->
    if statusCode
      expect(res.status).toEqual(statusCode)

      if res.status is 500
        console.log 'Server error: ', res.text
        console.log 'Respone status: ', res.status
        console.log 'Respone error: ', err

        return
      else if res.status isnt statusCode
        console.log 'Respone message: ', res.text
        console.log 'Respone status: ', res.status
        console.log 'Respone error: ', err

        return

    testProperty = (obj, testBody) ->
      for p of testBody
        if typeof testBody[p] is 'object'
          testProperty obj[p], testBody[p]
        else
          switch testBody[p]
            when 'INTEGER'
              expect(Number.isInteger obj[p]).toBeTruthy()
            when 'UUID'
              expect(obj[p]).toMatch(/[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}/)
            when 'STRING'
              expect(typeof obj[p] is 'string').toBeTruthy()
            when 'NULL'
              expect(obj[p]).toBeNull()
            else
              expect(testBody[p]).toEqual(obj[p])

    testProperty res.body, testBody

  this.createUser = (user, callback) ->
    request app
      .post '/helper/user/create'
      .type 'json'
      .send
        # username: user.username
        region: user.region
        phone: user.phone
        nickname: user.nickname
        password: user.password
      .end (err, res) ->
        if not err and res.status is 200
          callback res.body.result.id
        else
          console.log 'Create user failed: ', err

  this.loginUser = (phoneNumber, callback) ->
    request app
      .post '/user/login'
      .type 'json'
      .send
        region: '86'
        phone: phoneNumber
        password: this.password
      .end (err, res) ->
        if not err and res.status is 200
          callback res.body.result.id
        else
          console.log 'Login user failed: ', err

  this.createGroup = (group, callback) ->
    request app
      .post "/group/create?userId=#{group.creatorId}"
      .type 'json'
      .send
        name: group.name
        memberIds: group.memberIds
      .end (err, res) ->
        if not err and res.status is 200
          callback res.body.result.id
        else
          console.log 'Create group failed: ', err
