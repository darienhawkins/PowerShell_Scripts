# Important information obfuscated (hostname, IP address, username, password, etc)

cd $env:java_home\bin

$svrName="installtest02"
$fqdn="$svrName.higheredinstitutiondomain.edu"
$keyLoc="C:\higeredwebsvr\ssl\$svrName"
$javaCert="lib\security\cacerts"


.\keytool.exe -genkey -alias $svrName -keyalg RSA -keysize 2048 -keystore "$keyLoc.jks" -validity 3650 -ext SAN=dns:$svrName,dns:$fqdn,dns:localhost,ip:127.0.0.1

read-host "Press any key to continue"
.\keytool.exe -importkeystore -srckeystore "$keyLoc.jks" -destkeystore "$keyLoc.jks" -deststoretype pkcs12

read-host "Press any key to continue"
.\keytool.exe -exportcert -keystore "$keyLoc.jks" -alias $svrName -file "$keyLoc.cer"

read-host "Press any key to continue"
#.\keytool.exe -import -file "$keyLoc.cer" -alias aliasname -keystore "$keyLoc.ts"
.\keytool.exe -import -file "$keyLoc.cer" -alias $svrName -keystore "$keyLoc.ts"

read-host "Press any key to continue. The password for the next command is 'changeit'"
.\keytool.exe -import -trustcacerts -file "$keyLoc.cer" -alias $svrName -keystore "$env:java_home\$javaCert"