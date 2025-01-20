# Claim Progress Tracker

## Overview
The **Claim Progress Tracker** is a PowerShell script designed to help organize and track progress on my insurance claim files. This script enables monitoring file labeling, listing, and metadata organization by presenting summary and detailed statistics in a tabular format.

## Features
- **Detailed Statistics**:
  - Provides room-by-room breakdowns of files, including counts for total, named, unnamed, and listed files.
  - Displays percentages for labeled, listed, and remaining files.
- **Summary Statistics**:
  - Offers an at-a-glance view of overall progress, including total files, percentage labeled, and percentage listed.
- **Tabular Display**:
  - Presents data in a clean, structured table format for clarity.

## Installation
1. Clone or download the repository.
2. Save the script file (`ClaimProgressTracker.ps1`) to a location of your choice.

## Usage
1. Open PowerShell on your system.
2. Navigate to the directory containing the script:
   ```powershell
   cd path\to\script
   ```
3. Run the script:
   ```powershell
   .\ClaimProgressTracker.ps1
   ```

## Example Output
### Tabular Summary Statistics
```plaintext
Room           Total Named Unnamed Listed % Labeled % Listed % Remaining
----------------------------------------------------------------------
Laundry Room   26    21    5       5      80.77%    19.23%    0.40%
Master Bedroom 74    50    24      44     67.57%    59.46%    2.62%
...
Summary Statistics:
Total Files: 1778
Total Named Files: 541
Total Unnamed Files: 1237
Percent Labeled: 30.43%
Percent Listed: 17.55%
```

## Contributions
This script was designed to address specific challenges faced while organizing claim photos, but it can be adapted for similar use cases. Contributions and suggestions are welcome!
