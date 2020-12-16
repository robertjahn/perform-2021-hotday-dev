#!/bin/bash

PUBLIC_IP="$(curl -s http://checkip.amazonaws.com/)"

echo ""
echo "--------------------------------------------------------------------------------------"
echo "Enabled Patterns on $PUBLIC_IP"
echo "--------------------------------------------------------------------------------------"
curl -s "http://$PUBLIC_IP:8091/services/ConfigurationService/getEnabledPluginNames" | \
  sed -e 's|<ns:getEnabledPluginNamesResponse xmlns:ns=\"http://webservice.business.easytravel.dynatrace.com\">||g' | \
  sed -e 's|</ns:getEnabledPluginNamesResponse>||g' | \
  sed -e 's|</ns:return><ns:return>|\n|g' | \
  sed -e 's|<ns:return>|\n|g' | \
  sed -e 's|</ns:return>|\n|g'
echo ""
echo ""
