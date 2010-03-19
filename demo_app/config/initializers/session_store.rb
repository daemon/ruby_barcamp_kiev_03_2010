# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_mechanize-presentation_session',
  :secret      => '192e6146ab34dcb6e40b39d07c1ea3844a5aa96c4f7a3bf9b25bd02c0ab84575eba58e13eff1f50dcd08067a3407966ace5072d21efb983f4a25b7b6bd148fea'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
