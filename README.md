# Rails OAuth Demo with Auth0

This is a minimal Rails application demonstrating OAuth 2.0 Authorization Code Flow with PKCE using Auth0.

## Features

- OAuth 2.0 Authorization Code Flow
- PKCE (Proof Key for Code Exchange) for enhanced security
- Auth0 integration
- Secure session management
- Protected routes
- User profile display

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
  - PKCE implementation through Auth0
  - Session-based authentication
  - CSRF protection
  - Secure logout with Auth0

- **Architecture:**
  - `AuthController` - Handles OAuth callbacks and authentication flow
  - `ApplicationController` - Provides authentication helpers
  - `ProtectedController` - Demonstrates protected routes
  - Session-based user state management

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
# rails-oauth-demo
