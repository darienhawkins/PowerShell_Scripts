# Important information obfuscated (hostname, IP address, username, password, etc)

$fldrarray="Desktop","Documents","Downloads","Favorites","Links","Music","Pictures","Videos"

# $uncsrcpath="\\higheredtestserver001\person5_Drive\Users\person5"
# $uncdespath="\\anbu-adsc-001\c$\Users\person5"

$outostpath="$uncsrcpath\AppData\Local\Microsoft\Outlook"
$outostdest="$uncdespath\Documents\Outlook_PST_Files"

foreach($fldr in $fldrarray) {
    $cpsrc="$uncsrcpath\$fldr"
    $cpdes="$uncdespath\$fldr"
    robocopy /e /r:0 /w:0 /zb $cpsrc $cpdes
}

New-Item -ItemType directory -Path "$outostdest"
robocopy /e /r:0 /w:0 /zb $outostpath $outostdest *.pst

