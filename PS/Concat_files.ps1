# Run from Windows Powershell:
# ./concat_files.ps1 &lt;source directory&gt; &lt;target filename&gt;
#
# Where &lt;source directory&gt; is a sub-directory from where you run it.
# All files in source directory will be opened and written to target file.
# Three carriage returns separate the file contents.

$pathsrc=$args[0]
$filetgt=$args[1]

Get-ChildItem -Path $pathsrc |
	foreach-object {
		Add-content $filetgt &quot;`n`n`n&quot;
		get-content ( Join-Path $pathsrc $_ ) | Add-content $filetgt
	}
# get-content ( Join-Path $pathsrc $_ ) | Set-content -Path ( Join-Path $pathtgt $_.Name ) -Encoding ASCII
