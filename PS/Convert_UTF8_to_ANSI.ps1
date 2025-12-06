# Run from Windows Powershell:
# ./convert_file_encoding.ps1 &lt;source directory&gt; &lt;target directory&gt;
# Where &lt;source directory&gt; and &lt;target directory&gt; are sub-directories from where you run it.
# All files in source directory will be converted to ASCII and created in target directory, with the same name.
# Files in target will be overwritten.
$pathsrc=$args[0]
$pathtgt=$args[1]

Get-ChildItem -Path $pathsrc |
	foreach-object {
	get-content ( Join-Path $pathsrc $_ ) | Set-content -Path ( Join-Path $pathtgt $_.Name ) -Encoding ASCII
}
