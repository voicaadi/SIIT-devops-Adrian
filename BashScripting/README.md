===========HELLO============

This is my homework:

------------------------------------------------------------
PART 1: THE BASICS (VARIABLES & ARGUMENTS)
------------------------------------------------------------
1. HELLO SCRIPT: Create a script named 'greet.sh'.
   - Add the appropriate "shebang" line at the top.
   - The script should take one positional argument (a name).
   - When run as './greet.sh Alice', it should print:
     "Hello Alice! Today is [Current Date]"
   - Hint: Use the 'date' command inside the string.

2. PERMISSIONS: By default, your script won't run. 
   - Use 'chmod' to give the owner execute permissions.
   - Run the script to verify it works.

------------------------------------------------------------
PART 2: CONDITIONALS & FILE CHECKS
------------------------------------------------------------
1. FILE FINDER: Create a script named 'check_file.sh'.
   - The script should accept a filename as an argument.
   - Requirement:
     - If the file exists: Print "File [name] found!" and 
       display its file size.
     - If the file does not exist: Print "Error: File not found" 
       and create an empty file with that name.
   - Hint: Use 'if [ -f $1 ]' for the check.

PART 3: LOOPS & AUTOMATION
------------------------------------------------------------
1. BULK CREATOR: Create a script named 'setup_project.sh'.
   - Use a 'for' loop to create 5 directories named 
     'module_1' through 'module_5'.
   - Inside each directory, create an empty 'notes.md' file.
   - Print a success message for every directory created.

2. DIRECTORY CLEANER: Create a script named 'cleanup.sh'.
   - This script should look into a directory (provided as 
     an argument).
   - It should find all files ending in '.tmp' and delete them.
   - It should count how many files were deleted and print 
     the total to the user.
PART 4: THE "MASTER" SCRIPT (INTEGRATION)
------------------------------------------------------------
1. SYSTEM REPORT: Create a script named 'report.sh'.
   - This script should output the following to a file 
     named 'system_report.txt':
     - The current user logged in.
     - The current working directory.
     - The last 5 lines of your '.bash_history' or a list 
       of currently running processes (top/ps).
