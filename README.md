# Rails OAuth Demo with Auth0

This is a minimal Rails application demonstrating OAuth 2.0 Authorization Code Flow with PKCE using Auth0.

## Features

- OAuth 2.0 Authorization Code Flow
- PKCE (Proof Key for Code Exchange) for enhanced security
- Auth0 integration
- Secure session management
- Protected routes
- User profile display

## Why PKCE is Critical for Security

**PKCE (Proof Key for Code Exchange)** is a security extension to OAuth 2.0 that prevents authorization code interception attacks. It's especially important for public clients like web applications.

### The Security Problem PKCE Solves

**Traditional OAuth 2.0 Vulnerability:**
1. User initiates login → redirected to Auth0
2. Auth0 redirects back with authorization code in URL: `http://localhost:3000/callback?code=ABC123`
3. **Attack Vector**: Malicious app could intercept this code from:
   - Browser history
   - Referer headers
   - Network traffic
   - Malicious browser extensions
4. Attacker exchanges stolen code for access tokens

### How PKCE Prevents This Attack

**PKCE Flow:**
1. **Code Verifier**: App generates random 43-128 character string
2. **Code Challenge**: Creates SHA256 hash of verifier
3. **Authorization Request**: Sends challenge (not verifier) to Auth0
4. **Authorization Code**: Auth0 returns code as usual
5. **Token Exchange**: App sends BOTH code AND original verifier
6. **Verification**: Auth0 verifies verifier matches challenge

**Security Benefit**: Even if authorization code is stolen, attacker cannot exchange it for tokens without the original code verifier, which never leaves the client application.

### Why It's Essential for Web Applications

- **Public Clients**: Web apps can't securely store client secrets
- **Browser Environment**: URLs can be intercepted through various vectors
- **Zero Additional Complexity**: PKCE is handled automatically by Auth0
- **Industry Standard**: Recommended by OAuth 2.1 specification
- **No Performance Impact**: Minimal overhead, maximum security

## Setup Instructions

### 1. Auth0 Configuration

1. Create an Auth0 account at [auth0.com](https://auth0.com)
2. Create a new Application of type "Regular Web Application"
3. Configure the following settings in your Auth0 dashboard:

   **Allowed Callback URLs:**

   ```
   http://localhost:3000/auth/auth0/callback
   ```

   **Allowed Logout URLs:**

   ```
   http://localhost:3000/
   ```

   **Allowed Web Origins:**

   ```
   http://localhost:3000
   ```

### 2. Environment Variables

1. Copy the environment template:

   ```bash
   cp .env.example .env
   ```

2. Update `.env` with your Auth0 credentials:
   ```
   AUTH0_DOMAIN=your-auth0-domain.auth0.com
   AUTH0_CLIENT_ID=your_auth0_client_id
   AUTH0_CLIENT_SECRET=your_auth0_client_secret
   AUTH0_CALLBACK_URL=http://localhost:3000/auth/auth0/callback
   ```

### 3. Installation

1. Install dependencies:

   ```bash
   bundle install
   ```

2. Start the server:

   ```bash
   rails server
   ```

3. Visit http://localhost:3000

## Usage

1. **Home Page** - Shows welcome message and login option
2. **Login** - Redirects to Auth0 for authentication using OAuth 2.0 + PKCE
3. **Protected Page** - Accessible only after authentication, displays user info
4. **Logout** - Clears session and redirects to Auth0 logout

## Technical Implementation

- **Gems Used:**

  - `omniauth` - OAuth strategy framework
  - `omniauth-auth0` - Auth0 OAuth strategy
  - `omniauth-rails_csrf_protection` - CSRF protection for OAuth
  - `dotenv-rails` - Environment variable management

- **Security Features:**

  - **PKCE (Proof Key for Code Exchange)**: Prevents authorization code interception attacks
    - Automatically generates code verifier/challenge pairs
    - Verifies token exchanges with cryptographic proof
    - Protects against malicious apps and network attacks
  - **Session-based authentication**: Secure server-side session management
  - **CSRF protection**: Prevents cross-site request forgery
  - **Secure logout**: Complete session cleanup with Auth0
  - **Session expiration**: Automatic timeout after 24 hours
  - **Token security**: No sensitive tokens stored in browser

- **Architecture:**
  - `AuthController` - Handles OAuth callbacks and authentication flow
  - `ApplicationController` - Provides authentication helpers
  - `ProtectedController` - Demonstrates protected routes
  - Session-based user state management

## Security Best Practices Implemented

1. **PKCE Flow**: All OAuth requests use PKCE for maximum security
2. **No Client Secret Exposure**: Secrets safely stored in environment variables
3. **Session Security**: Server-side sessions with automatic expiration
4. **Secure Redirects**: Validated callback URLs prevent open redirects
5. **HTTPS Ready**: Production configuration supports secure transport
6. **Token Isolation**: Access tokens never exposed to browser JavaScript
## Security Best Practices Implemented

1. **PKCE Flow**: All OAuth requests use PKCE for maximum security
2. **No Client Secret Exposure**: Secrets safely stored in environment variables
3. **Session Security**: Server-side sessions with automatic expiration
4. **Secure Redirects**: Validated callback URLs prevent open redirects
5. **HTTPS Ready**: Production configuration supports secure transport
6. **Token Isolation**: Access tokens never exposed to browser JavaScript

## References

- [RFC 7636 - Proof Key for Code Exchange](https://tools.ietf.org/html/rfc7636)
- [Auth0 PKCE Documentation](https://auth0.com/docs/authorization/flows/authorization-code-flow-with-pkce)
- [OAuth 2.0 Security Best Practices](https://tools.ietf.org/html/draft-ietf-oauth-security-topics)
