Add-Type -assembly System.Windows.Forms

function config{

    if(Test-Path -Path "config.json"){

    }else{
      [string]$logpath = Resolve-Path ..\Logs;
      [string]$folderpath = Resolve-Path ..\TopSrc;
      [string]$backuppath = Resolve-Path ..\TopBck;
      New-Item -ItemType File -Force -Path "config.json";
    
      $logpath = $logpath.replace("\", "\\")
      $folderpath = $folderpath.replace("\", "\\")
      $backuppath = $backuppath.replace("\", "\\")

      $json = '{"computer":[{"logloc":"' + $logpath +'"},{"folderloc":"' + $folderpath +'"},{"backuploc":"' + $backuppath +'"}]}';
      $jsonForFile =  $json
      Add-Content -Path "config.json" -Value $jsonForFile;
        
    }
}

function startscript{

    config;
    createForm;
}


function changePath{
        param(
        [string] $Location
        )

        $jsonOut = Get-Content 'config.json' | ConvertFrom-Json
        [String]$logSource = $jsonOut.computer[0].logloc;
        [String]$folderSource = $jsonOut.computer[1].folderloc;
        [String]$folderTarget = $jsonOut.computer[2].backuploc;
        New-Item -ItemType File -Force -Path "config.json";

        
        switch($location){
            "log"{
                $OpenFileDialog = New-Object System.Windows.Forms.FolderBrowserDialog
                If ($OpenFileDialog.ShowDialog() -eq "Cancel") 
                {
                [System.Windows.Forms.MessageBox]::Show("No Folder Selected. Please select a Folder !", "Error", 0, 
                [System.Windows.Forms.MessageBoxIcon]::Exclamation)
                }
                $Global:SelectedFile = $OpenFileDialog.SelectedPath
                $logSource = $SelectedFile;        
            }
            "folder" {
                $OpenFileDialog = New-Object System.Windows.Forms.FolderBrowserDialog
                If ($OpenFileDialog.ShowDialog() -eq "Cancel") 
                {
                [System.Windows.Forms.MessageBox]::Show("No Folder Selected. Please select a Folder !", "Error", 0, 
                [System.Windows.Forms.MessageBoxIcon]::Exclamation)
                }
                $Global:SelectedFile = $OpenFileDialog.SelectedPath
                $folderSource = $SelectedFile; 
            }
            "backup" {
                $OpenFileDialog = New-Object System.Windows.Forms.FolderBrowserDialog
                If ($OpenFileDialog.ShowDialog() -eq "Cancel") 
                {
                [System.Windows.Forms.MessageBox]::Show("No Folder Selected. Please select a Folder !", "Error", 0, 
                [System.Windows.Forms.MessageBoxIcon]::Exclamation)
                }
                $Global:SelectedFile = $OpenFileDialog.SelectedPath
                $folderTarget = $SelectedFile;    
            }
        }

        $logpath = $logSource.replace("\", "\\")
        $folderpath = $folderSource.replace("\", "\\")
        $backuppath = $folderTarget.replace("\", "\\")

        $json = '{"computer":[{"logloc":"' + $logpath +'"},{"folderloc":"' + $folderpath +'"},{"backuploc":"' + $backuppath +'"}]}';
        $jsonForFile =  $json
        Add-Content -Path "config.json" -Value $jsonForFile;   
}

function createbackup{

    $jsonOut = Get-Content 'config.json' | ConvertFrom-Json
    [String]$logSource = $jsonOut.computer[0].logloc;
	[String]$folderSource = $jsonOut.computer[1].folderloc;
	[String]$folderTarget = $jsonOut.computer[2].backuploc;
	[String]$compression = 'Optimal'
    [String]$timestamp = Get-Date;
    $logSource = $LogSource + "\log.txt";

    Copy-Item -Path $folderSource -Destination $folderTarget -Force

    if(Test-Path -Path $logSource){

    }else{
     New-Item -ItemType File -Path $logSource;    
    }
    $log = 'Backup Created at ' + $timestamp + ' from the folder: ' + $folderSource + ' to the folder: ' + $folderTarget + '';
    Add-Content -Path $logSource -Value $log;

}


function createForm{
    $main_form = New-Object System.Windows.Forms.Form
    $main_form.Text ='Backuper'
    $main_form.Width = 1000
    $main_form.Height = 600
    $main_form.AutoSize = $true;

    $TitelLabel = New-Object System.Windows.Forms.Label

    $TitelLabel.Location = New-Object System.Drawing.Point(400,20)
    $TitelLabel.Size = New-Object System.Drawing.Size(280,30)
    $TitelLabel.Font =  New-Object System.Drawing.Font("Calibri Light",15)
    $TitelLabel.Text = 'Backuper'

    $main_form.Controls.Add($TitelLabel)

    $TitelButton = New-Object system.windows.Forms.Button
    $TitelButton.Text = "Create Backup"
    $TitelButton.Location = New-Object System.Drawing.Point(350,75)
    $TitelButton.Size = New-Object System.Drawing.Size(200,20)

    $TitelButton.Add_Click({
    createbackup
    [System.Windows.Forms.MessageBox]::Show("Backup created", 
    [System.Windows.Forms.MessageBoxIcon]::Exclamation)
    })
    $main_form.Controls.Add($TitelButton)


    $ConfigTitelLabel = New-Object System.Windows.Forms.Label

    $ConfigTitelLabel.Location = New-Object System.Drawing.Point(800,20)
    $ConfigTitelLabel.Size = New-Object System.Drawing.Size(280,30)
    $ConfigTitelLabel.Font =  New-Object System.Drawing.Font("Calibri Light",15)
    $ConfigTitelLabel.Text = 'Config'

    $main_form.Controls.Add($ConfigTitelLabel)

    $lOGConfigTitelLabel = New-Object System.Windows.Forms.Label

    $lOGConfigTitelLabel.Location = New-Object System.Drawing.Point(800,100)
    $lOGConfigTitelLabel.Size = New-Object System.Drawing.Size(280,30)
    $lOGConfigTitelLabel.Font =  New-Object System.Drawing.Font("Calibri Light",15)
    $lOGConfigTitelLabel.Text = 'Log File location'

    $main_form.Controls.Add($lOGConfigTitelLabel)

    $lOGConfigTitelTextButton = New-Object System.Windows.Forms.Button
    $lOGConfigTitelTextButton.Text = "Change PATH"
    $lOGConfigTitelTextButton.Location = New-Object System.Drawing.Point(800,150)
    $lOGConfigTitelTextButton.Size = New-Object System.Drawing.Size(200,20)

    $lOGConfigTitelTextButton.Add_Click({changePath "log"})
    $main_form.Controls.Add($lOGConfigTitelTextButton)


    $FolderLocationTitelLabel = New-Object System.Windows.Forms.Label

    $FolderLocationTitelLabel.Location = New-Object System.Drawing.Point(800,200)
    $FolderLocationTitelLabel.Size = New-Object System.Drawing.Size(280,30)
    $FolderLocationTitelLabel.Font =  New-Object System.Drawing.Font("Calibri Light",15)
    $FolderLocationTitelLabel.Text = 'Folder to backup'

    $main_form.Controls.Add($FolderLocationTitelLabel)

    $FolderConfigTitelTextButton = New-Object system.windows.Forms.Button
    $FolderConfigTitelTextButton.Text = "Change PATH"
    $FolderConfigTitelTextButton.Location = New-Object System.Drawing.Point(800,250)
    $FolderConfigTitelTextButton.Size = New-Object System.Drawing.Size(200,20)

    $FolderConfigTitelTextButton.Add_Click({changePath "folder"})
    $main_form.Controls.Add($FolderConfigTitelTextButton)

    $BackupLocationTitelLabel = New-Object System.Windows.Forms.Label

    $BackupLocationTitelLabel.Location = New-Object System.Drawing.Point(800,300)
    $BackupLocationTitelLabel.Size = New-Object System.Drawing.Size(280,30)
    $BackupLocationTitelLabel.Font =  New-Object System.Drawing.Font("Calibri Light",15)
    $BackupLocationTitelLabel.Text = 'Location For backup'

    $main_form.Controls.Add($BackupLocationTitelLabel)

    $BackupConfigTitelTextButton = New-Object system.windows.Forms.Button
    $BackupConfigTitelTextButton.Text = "Change PATH"
    $BackupConfigTitelTextButton.Location = New-Object System.Drawing.Point(800,350)
    $BackupConfigTitelTextButton.Size = New-Object System.Drawing.Size(200,20)

    $BackupConfigTitelTextButton.Add_Click({changePath "backup"})
    $main_form.Controls.Add($BackupConfigTitelTextButton)

    $main_form.ShowDialog()
}




#Run Script:
startscript
