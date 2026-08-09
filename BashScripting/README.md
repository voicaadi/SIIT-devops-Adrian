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

