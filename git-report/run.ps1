# script variables
$currDirectory = pwd
$repositoryDir = "..\"
$reportsDir = "$currDirectory\Reports"

Remove-Item $reportsDir -Force -Recurse -ErrorAction Ignore
mkdir $reportsDir
cd $repositoryDir

Get-ChildItem $currDirectory -Filter *.txt | Foreach-Object {
    $taskListFile = $_.FullName
    $taskListShortName = [System.IO.Path]::GetFileNameWithoutExtension($_);
    Write-Host "`n---------------------------------------"
    Write-Host "Process tasks list: $taskListShortName"
    Write-Host "---------------------------------------`n"

    $tasks = Get-Content $taskListFile
    $tasks = $tasks | select -uniq | Sort-Object
    $reportFile = "$reportsDir\$taskListShortName-report.txt"

    foreach($line in $tasks) {
        if($line -match $regex -and -not $line.StartsWith("#") -and -not [string]::IsNullOrWhiteSpace($line)){
            $taskName = $line
            # /script variables
            Write-Host "$taskName processing..."
            # get all relevant commits and convert it to PowerShell object
            $gitHist = (git log --all --grep="$taskName" --format="%ai`t%H`t%an`t%ae`t%s" --all) | ConvertFrom-Csv -Delimiter "`t" -Header ("Date","CommitId","Author","Email","Subject")
            $commitsCounts = 0;
            foreach ($commit in $gitHist){
                $commitsCounts++
                #Write-Host ("Commit: " + $commit.Subject)
            }
            Write-Host ("Found Commits: " + $commitsCounts)
            # gather all touched files in all commits
            $allChangedFiles = @()
            foreach ($commit in $gitHist){
               $commitFiles = (git diff-tree --no-commit-id --name-only -r $commit.CommitId)
               foreach ($currPath in $commitFiles) {
                   if ($currPath.Contains("force-app/main/default/")) {
                       $resPath = $currPath.Replace("force-app/main/default/", "")
                       $allChangedFiles += $resPath
                   }
               }
            }
            # filter touched files - only unique and sort
            $allChangedFiles = $allChangedFiles | select -uniq | Sort-Object
            Write-Host ("Found Files: " + $allChangedFiles.length + "`n")
            Add-Content $reportFile "---------------------------------------------------------`n"
            Add-Content $reportFile "$taskName task files:`n"
            Add-Content $reportFile "---------------------------------------------------------`n"
            Add-Content $reportFile  $allChangedFiles
            Add-Content $reportFile "`n`n"
        }
    }
}

cd $currDirectory




