# 
# Copyright 2025 Alastair Wyse (https://github.com/alastairwyse/ApplicationAccessDeployment/)
#  
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#  
#     http://www.apache.org/licenses/LICENSE-2.0
#  
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#
# NAME
#     Tar-Copy
#
# SYNOPSIS
#     Copies any *.tar files in (or as a child of) the specified input folder 
#     to an output folder.
#
# SYNTAX
#     Tar-Copy [-InputFolder] <String>  [-OutputFolder] <String> 
#
# EXAMPLES
#     .\Tar-Copy.ps1 "C:\Temp\DockerBuild\" "C:\Temp\TarOutput\"
#
# NOTES / TODO
#

# Read and validate input parameters
Param (
[Parameter(Position=0, Mandatory=$True, HelpMessage="Enter the input folder")]
[ValidateNotNullorEmpty()]
[string]$InputFolder,
[Parameter(Position=1, Mandatory=$True, HelpMessage="Enter the output folder")]
[ValidateNotNullorEmpty()]
[string]$OutputFolder
)

# Create the output folder
try {
    New-Item -Path $OutputFolder -ItemType Directory -Force
    Remove-Item (Join-Path -Path $OutputFolder -ChildPath '*') -Recurse
}
catch {
    throw "Failed to create and clean output folder '$($OutputFolder)'"
}

# Copy the *.tar files
$tarFiles = Get-ChildItem -Path $InputFolder -Filter '*.tar' -Recurse
foreach ($currentTarFiles in $tarFiles) {
    Copy-Item $currentTarFiles.FullName -Destination $OutputFolder

}

Write-host "SUCCESS: Completed copying *.tar files."