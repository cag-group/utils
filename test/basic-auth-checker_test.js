const should = require('should')
const BasicAuthChecker = require('../lib/basic-auth-checker')

describe('basic-auth-checker', () => {
  it('getValidUser', async () => {
    const credentials = [
      {name: 'u1', pass: 'p1'},
      {name: 'u2', pass: 'p2'}
    ]
    const req = {headers: {authorization: 'Basic dTE6cDE='}}
    const checker = new BasicAuthChecker(credentials)
    const username = checker.getValidUser(req)
    username.should.be.exactly('u1')
  })
  it('getValidUser undefined', async () => {
    const credentials = [
      {name: 'u1', pass: 'p1'},
      {name: 'u2', pass: 'p2'}
    ]
    const req = {headers: {authorization: 'Basic 0000000'}}
    const checker = new BasicAuthChecker(credentials)
    const username = checker.getValidUser(req)
    should(username).be.exactly(undefined)
  })
})
