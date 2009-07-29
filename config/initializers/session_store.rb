# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_emo_session',
  :secret      => '676508ef17b7ec3d0e5c2fd0a2bfdc4333df460fd3bdd5dde11fe3e97ad9845052d3e6bd4aa40ce950a619c9756af39e5967f50489019bb4e3f324b204dc3cde'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
