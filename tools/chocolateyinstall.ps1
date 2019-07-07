try {
  #Get current dir
  $tools = split-path $MyInvocation.MyCommand.Path 
  #Get parent dir
  $parentDir = split-path -parent $tools
  #get HelloWorldSite source dir $source = join-path $parentDir "source/*" (3)
  #get location of the installtion file
  $installFile = join-path $parentDir "install.ps1"
  Invoke-Expression "$installFile -Sourcefiles $source"           
} catch {
  Write-Host $_.Exception.Message               
  Write-Host $_.Exception   
}