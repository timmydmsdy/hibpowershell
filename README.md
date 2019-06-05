# hibp
HaveIBeenPwned mass email check using powershell

This script is designed to take a text file of email addresses and query them against the HaveIBeenPwned.com API.  A report will be generated a csv report with the name breach.csv.
The script will append the file if there is already a file named breach.csv.

#### Requirements
* Powershell (duh)
* HaveIBeenPwned Powershell Module<br>
    * `Install-Module -Name HaveIBeenPwned`
    
**Usage:**<br>
`./hibp -i [input file] -o [output file path]`


Credit to Elliot Munro who wrote the check function.  You can find his code here:<br>
https://gcits.com/knowledge-base/check-office-365-accounts-against-have-i-been-pwned-breaches/
