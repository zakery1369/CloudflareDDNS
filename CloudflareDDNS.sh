auth_header="Authorization: Bearer"
auth_email="Cloudflare login email"
global_api_key="x.x.x.x.x.x.x.x.x.x.x.x.x.x.x.x"
bearer_key="x.x.x.x.x.x.x.x.x.x.x.x.x.x.x.x"
zone_id="x.x.x.x.x.x.x.x.x.x.x.x.x.x.x.x"
record_name="Domain.com OR Sub.Domain.com"
ttl="3600"
proxy="false"

old_ip=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records?name=$record_name" -H "Authorization: Bearer $bearer_key" \
                    -H "Content-Type: application/json" | sed -E 's/.*"content":"(([0-9]{1,3}\.){3}[0-9]{1,3})".*/\1/') 

new_ip=$(curl -s icanhazip.com)

if [[ "$old_ip" == "$new_ip" ]]; then
  echo
  echo The $old_ip has not been changed
  echo

else

  record_id=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records?name=$record_name" -H "Authorization: Bearer $bearer_key" \
                    -H "Content-Type: application/json" | sed -E 's/.*"id":"(\w+)".*/\1/')
                    

  change_ip=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records/$record_id" \
                     -H "X-Auth-Email: $auth_email" \
                     -H "X-Auth-Key: $global_api_key" \
                     -H "Content-Type: application/json" \
                     --data "{\"type\":\"A\",\"name\":\"$record_name\",\"content\":\"$new_ip\",\"ttl\":\"$ttl\",\"proxied\":$proxy}")


  echo 
  echo The $new_ip was set on the $record_name in Cloudflare
  echo 

fi
