# Define the folder to scan
$folderPath = "G:\My Drive\2024 Helene Flood\Helene"

# Function to populate data and update the UI
function Refresh-UI {
    param (
        [System.Windows.Controls.Grid]$grid,
        [System.Windows.Controls.TextBlock]$summaryBlock
    )

    # Clear existing rows (excluding headers)
    $grid.RowDefinitions.Clear()
    $grid.Children.Clear()

    # Add a row for headers
    $headerRow = New-Object System.Windows.Controls.RowDefinition
    $headerRow.Height = "Auto"
    $grid.RowDefinitions.Add($headerRow)

    # Add headers
    $headers = @("Room", "Total", "Named", "Unnamed", "Listed", "% Labeled", "% Listed", "Naming Progress", "Listing Progress")
    for ($i = 0; $i -lt $headers.Count; $i++) {
        $headerText = New-Object System.Windows.Controls.TextBlock
        $headerText.Text = $headers[$i]
        $headerText.FontWeight = "Bold"
        $headerText.FontSize = 20
        $headerText.Margin = "5"
        $headerText.HorizontalAlignment = "Center"
        $headerText.VerticalAlignment = "Center"
        [System.Windows.Controls.Grid]::SetColumn($headerText, $i)
        [System.Windows.Controls.Grid]::SetRow($headerText, 0)
        $grid.Children.Add($headerText)
    }

    # Variables to track totals
    $files = Get-ChildItem -Path $folderPath -File -Recurse
    $totalUnnamedFiles = 0
    $totalListedFiles = 0
    $totalFiles = 0
    $folderData = @{ }

    foreach ($file in $files) {
        if ($file.DirectoryName -like "*\Replacement Screenshots" -or $file.DirectoryName -like "*\Overview" -or $file.DirectoryName -like "*\Movies") {
            continue
        }

        $isListed = $file.DirectoryName -like "*\Listed"
        $parentFolder = if ($isListed) {
            Split-Path -Path (Split-Path -Path $file.DirectoryName -Parent) -Leaf
        } else {
            Split-Path -Path $file.DirectoryName -Leaf
        }

        if (-not $folderData.ContainsKey($parentFolder)) {
            $folderData[$parentFolder] = @{
                Total = 0
                Unnamed = 0
                Listed = 0
            }
        }

        $folderData[$parentFolder].Total++
        $totalFiles++

        if ($file.Name -match '^(IMG|PXL)') {
            $folderData[$parentFolder].Unnamed++
            $totalUnnamedFiles++
        }

        if ($isListed) {
            $folderData[$parentFolder].Listed++
            $totalListedFiles++
        }
    }

    # Populate rows with data
    $rowIndex = 1
    foreach ($folderName in $folderData.Keys) {
        $data = $folderData[$folderName]

        $percentLabeled = if ($data.Total -gt 0) {
            ((($data.Total - $data.Unnamed) / $data.Total) * 100).ToString("0.00")
        } else {
            "0.00"
        }

        $percentListed = if ($data.Total -gt 0) {
            (($data.Listed / $data.Total) * 100).ToString("0.00")
        } else {
            "0.00"
        }

        $values = @($folderName, $data.Total, ($data.Total - $data.Unnamed), $data.Unnamed, $data.Listed, "$percentLabeled%", "$percentListed%")

        $grid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition))
        for ($i = 0; $i -lt $values.Count; $i++) {
            $cell = New-Object System.Windows.Controls.TextBlock
            $cell.Text = $values[$i]
            $cell.Margin = "5"
            $cell.FontSize = 18
            $cell.HorizontalAlignment = "Center"
            $cell.VerticalAlignment = "Center"
            [System.Windows.Controls.Grid]::SetColumn($cell, $i)
            [System.Windows.Controls.Grid]::SetRow($cell, $rowIndex)
            $grid.Children.Add($cell)
        }

        # Add progress bar for "Naming Progress"
        $namingProgressBar = New-Object System.Windows.Controls.ProgressBar
        $namingProgressBar.Minimum = 0
        $namingProgressBar.Maximum = 100
        $namingProgressBar.Value = $percentLabeled
        $namingProgressBar.Height = 20
        $namingProgressBar.Margin = "5"
        [System.Windows.Controls.Grid]::SetColumn($namingProgressBar, 7)
        [System.Windows.Controls.Grid]::SetRow($namingProgressBar, $rowIndex)
        $grid.Children.Add($namingProgressBar)

        # Add progress bar for "Listing Progress"
        $listingProgressBar = New-Object System.Windows.Controls.ProgressBar
        $listingProgressBar.Minimum = 0
        $listingProgressBar.Maximum = 100
        $listingProgressBar.Value = $percentListed
        $listingProgressBar.Height = 20
        $listingProgressBar.Margin = "5"
        [System.Windows.Controls.Grid]::SetColumn($listingProgressBar, 8)
        [System.Windows.Controls.Grid]::SetRow($listingProgressBar, $rowIndex)
        $grid.Children.Add($listingProgressBar)

        $rowIndex++
    }

    # Update summary statistics
    $totalPercentLabeled = if ($totalFiles -gt 0) {
        ((($totalFiles - $totalUnnamedFiles) / $totalFiles) * 100).ToString("0.00")
    } else {
        "0.00"
    }

    $totalPercentListed = if ($totalFiles -gt 0) {
        (($totalListedFiles / $totalFiles) * 100).ToString("0.00")
    } else {
        "0.00"
    }

    $summaryText = "Summary:`n"
    $summaryText += "Total Files: $totalFiles`n"
    $summaryText += "Total Named Files: $(($totalFiles - $totalUnnamedFiles))`n"
    $summaryText += "Total Unnamed Files: $totalUnnamedFiles`n"
    $summaryText += "Total Listed Files: $totalListedFiles`n"
    $summaryText += "Percent Labeled: $totalPercentLabeled%`n"
    $summaryText += "Percent Listed: $totalPercentListed%"
    $summaryBlock.Text = $summaryText
    $summaryBlock.FontSize = 18
}

# Create the window
Add-Type -AssemblyName PresentationFramework
$window = New-Object System.Windows.Window
$window.Title = "Detailed Room Statistics"
$window.Width = 1600
$window.Height = 900
$window.WindowStartupLocation = "CenterScreen"

# Create a grid layout
$mainGrid = New-Object System.Windows.Controls.Grid

# Define rows for the table and summary
$mainGrid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition -Property @{ Height = "*" })) # Table
$mainGrid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition -Property @{ Height = "Auto" })) # Summary
$mainGrid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition -Property @{ Height = "Auto" })) # Button

# Create the data grid
$dataGrid = New-Object System.Windows.Controls.Grid
$dataGrid.Margin = "10"
$columns = @(150, 100, 100, 100, 100, 125, 125, 250, 250)
foreach ($width in $columns) {
    $col = New-Object System.Windows.Controls.ColumnDefinition
    $col.Width = "${width}" # Set width for each column
    $dataGrid.ColumnDefinitions.Add($col)
}

[System.Windows.Controls.Grid]::SetRow($dataGrid, 0)
$mainGrid.Children.Add($dataGrid)

# Create the summary block
$summaryBlock = New-Object System.Windows.Controls.TextBlock
$summaryBlock.Margin = "10"
$summaryBlock.TextWrapping = "Wrap"
$summaryBlock.FontSize = 18
[System.Windows.Controls.Grid]::SetRow($summaryBlock, 1)
$mainGrid.Children.Add($summaryBlock)

# Create the refresh button
$refreshButton = New-Object System.Windows.Controls.Button
$refreshButton.Content = "Refresh"
$refreshButton.Margin = "10"
$refreshButton.FontSize = 16
$refreshButton.HorizontalAlignment = "Center"
$refreshButton.VerticalAlignment = "Center"
$refreshButton.Add_Click({ Refresh-UI -grid $dataGrid -summaryBlock $summaryBlock })
[System.Windows.Controls.Grid]::SetRow($refreshButton, 2)
$mainGrid.Children.Add($refreshButton)

# Set the content and show the window
$window.Content = $mainGrid
Refresh-UI -grid $dataGrid -summaryBlock $summaryBlock
$window.ShowDialog() | Out-Null
