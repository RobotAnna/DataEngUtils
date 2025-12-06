# Make multiple string replacements in a file.
#
# Run from Windows Powershell:
# ./replace_date_cast.ps1 &lt;source filename&gt; &lt;target filename&gt;
#
# Use an excel sheet to set old and new strings.
#
# This script should be placed in the same directory as the source and target file.
# Open source file, search and replace strings, and write to target file

$filesrc=$args[0]
$filetgt=$args[1]

(Get-Content $filesrc) | ForEach-Object {
$_.replace("TO_TIMESTAMP(SI.AANMAAKDAT)","SI.AANMAAKDAT||'.000'").replace("TO_TIMESTAMP(SI.VERWERKDAT)","SI.VERWERKDAT||'.000'").replace("TO_TIMESTAMP(SI.WIJZ_DAT)","SI.WIJZ_DAT||'.000'").replace("TO_TIMESTAMP(SI.WIJZDAT)","SI.WIJZDAT||'.000'").replace("TO_TIMESTAMP(SI.WIJZIG_AUDIT_DTT)","SI.WIJZIG_AUDIT_DTT||'.000'").replace("TO_TIMESTAMP(SI.WIJZIG_DTT)","SI.WIJZIG_DTT||'.000'").replace("TO_TIMESTAMP(SI.WIJZIG_SYS_DTT)","SI.WIJZIG_SYS_DTT||'.000'")
} | Set-Content $filetgt
