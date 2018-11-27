#!/usr/bin/env sh
#Here is a sample custom api script.
#This file name is "myapi.sh"
#So, here must be a method   myapi_deploy()
#Which will be called by acme.sh to deploy the cert
#returns 0 means success, otherwise error.
 ########  Public functions #####################
 #domain keyfile certfile cafile fullchain
consul_deploy() {
  _cdomain="$1"
  _ckey="$2"
  _ccert="$3"
  _cca="$4"
  _cfullchain="$5"
  _H1=""
  _H2=""
  _H3=""
  _H4=""
  _H5=""
   if [ -z "$DEPLOY_CONSUL_URL" ] || [ -z "$DEPLOY_CONSUL_ROOT_KEY" ]; then
    _err "You haven't specified the url or consul root key yet (DEPLOY_CONSUL_URL and DEPLOY_CONSUL_ROOT_KEY)."
    _err "Please set them via export and try again."
    _err "e.g. export DEPLOY_CONSUL_URL=http://localhost:8500/v1/kv"
    _err "e.g. export DEPLOY_CONSUL_ROOT_KEY=acme"
    return 1
  fi
   #Save consul url if it's succesful (First run case)
  _saveaccountconf DEPLOY_CONSUL_URL "$DEPLOY_CONSUL_URL"
  _saveaccountconf DEPLOY_CONSUL_ROOT_KEY "$DEPLOY_CONSUL_ROOT_KEY"
   _info "Deploying certificate to consul Key/Value store"
  _debug2 _cdomain "$_cdomain"
  _debug2 _ckey "$_ckey"
  _debug2 _ccert "$_ccert"
  _debug2 _cca "$_cca"
  _debug2 _cfullchain "$_cfullchain"
  _debug2 DEPLOY_CONSUL_URL "$DEPLOY_CONSUL_URL"
  _debug2 DEPLOY_CONSUL_ROOT_KEY "$DEPLOY_CONSUL_ROOT_KEY"
  
  # set base url for all uploads
  upload_base_url="${DEPLOY_CONSUL_URL}/v1/kv/${DEPLOY_CONSUL_ROOT_KEY}/${_cdomain}"
  echo "$upload_base_url";
  _debug2 upload_base_url "$upload_base_url"
   # private
  _info uploading "$_ckey"
  response=$(_post "@${_ckey}" "${upload_base_url}/${_cdomain}.key" "" "PUT")
  _debug2 response "$response"

  # public
  _info uploading "$_ccert"
  response=$(_post "@${_ccert}" "${upload_base_url}/${_cdomain}.cer" "" "PUT")
  _debug2 response "$response"
   # ca
  _info uploading "$_cca"
  response=$(_post "@${_cca}" "${upload_base_url}/ca.cer" "" "PUT")
  _debug2 response "$response"
   # fullchain
  _info uploading "$_cfullchain"
  response=$(_post "@${_cfullchain}" "${upload_base_url}/fullchain.cer" "" "PUT")
  _debug2 response "$response"
   #date
  _info "Setting Last Update date"
  response=$(_post "`$(which date)`" "${upload_base_url}/updatedate" "" "PUT")
  _debug2 response "$response"
   return 0
 }
 ####################  Private functions below ##################################
