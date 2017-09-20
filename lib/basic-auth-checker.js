const basicAuth = require('basic-auth')

/**
 * Checks if user.name and user.pass match valid users.
 */
class BasicAuthChecker {
  constructor (credentials) {
    this.credentials = credentials
  }

  /**
   * Check that credentials is valid and get username.
   * @param req - Request
   * @returns {boolean} username if credentials are valid
   */
  getValidUser (req) {
    const user = basicAuth(req)
    if (user) {
      const c = this.credentials.find(u => u.name === user.name && u.pass === user.pass)
      return c && c.name
    }
  }
}

module.exports = BasicAuthChecker
