@echo off

setlocal EnableDelayedExpansion

REM	ST Interpreter
REM	ST (short for ScripT) is a lightweight stack-oriented script interpreter written in batch.
REM This is the only file ST uses and requires.

REM ST differentiates it's commands based on a specific set of starting strings.
REM To use a command, you must first start the line with "::", "##" or "//".
REM ST will recognise "::" or "#" and then take that line as a command, else it will take the line as a comment and ignore it.

echo.

if "%1"=="" (
	echo ERROR: ST requires you to pass a script file or a command as a parameter.
	echo        For example, "st test_script.txt", or "st clear-env"
	
	for %%x in (%cmdcmdline%) do if /i "%%~x"=="/c" set DOUBLECLICKED=1
	if defined DOUBLECLICKED pause
	
	exit /b
)

if "%1"=="/?" (
	echo ST is a lightweight stack-oriented scripting language and interpreter
	echo written entirely in Batch. This is the only binaries file
	echo required to use ST.
	echo.
	echo ST is designed to work entirely from the command line, and as such
	echo all interfacing with ST will be done via the command line.
	echo.
	echo To interface with ST, use the command identifier "st", or "st.bat".
	echo.
	echo To run a script, use the command "st [script file] {parameters OPTIONAL}".
	echo.
	echo If a script has errored out, and hard-crashed ST, there's a good chance
	echo data was left over from the previous session, use the command
	echo "st clear-env" to clear the environment of any data.
	
	exit /b
)

set ST_SCRIPT=%1

set st.title=ST - Script: %ST_SCRIPT%

title !st.title!

if "%1"=="clear-env" (
	set st.title=ST - Clearing environment
	
	title !st.title!
	
	for /l %%a in (0, 1, !Stack_a.length!) do (
		set "Stack_a[%%a]="
	)
	set "Stack_a.length="

	for /l %%a in (0, 1, !Stack_b.length!) do (
		set "Stack_b[%%a]="
	)
	set "Stack_b.length="

	for /l %%a in (0, 1, !Stack_c.length!) do (
		set "Stack_c[%%a]="
	)
	set "Stack_c.length="

	for /l %%a in (0, 1, !Stack_x.length!) do (
		set "Stack_x[%%a]="
	)
	set "Stack_x.length="

	for /l %%a in (0, 1, !Stack_y.length!) do (
		set "Stack_y[%%a]="
	)
	set "Stack_y.length="

	for /l %%a in (0, 1, !Stack_z.length!) do (
		set "Stack_z[%%a]="
	)
	set "Stack_z.length="
	
	set "st.R_a="
	set "st.R_b="
	set "st.R_c="
	set "st.R_x="
	set "st.R_y="
	set "st.R_z="
	set "st.st.R_h="
	
	exit /b
)

if not "%~2"=="" (
	set "tempdata=%~2"

	for %%a in (!tempdata!) do (
		call :add "Stack_y", "%%a"
	)
	
	set "tempdata="
)

set st.mode_nocomment=false

for /F "tokens=1* delims=]" %%a in ('type "%ST_SCRIPT%" ^| find /V /N ""') do (
	set st.title=ST - Script: %ST_SCRIPT% - Building script stack

	title !st.title!

	if "%%b"=="" (
		call :add "Stack_x", "NULL_LINE"
	) else (
		call :add "Stack_x", "%%b"
	)
)

set /a st.line=-1

:readStackX
set /a st.line+=1

for /f "tokens=1* eol=' delims= " %%a in ("!Stack_x[%st.line%]!") do (
	set st.title=ST - Script: %ST_SCRIPT% - Executing - Line: !st.line!

	title !st.title!

	set st.command=%%a
	set start=!st.command:~0,2!
	set st.command=!st.command:~2!

	if !st.mode_nocomment!==true (
		set st.command=%%a
	
		if /i !st.command!==~ext (
			exit /b
		)
	
		if "!st.command!"=="{" (
			set st.codeblock=true
		)
		
		if "!st.command!"=="}" (
			set "st.codeblock="
		)
		
		if not defined st.codeblock (
			call :commandHandling "!st.command!", "%%b"
		)
	) else (
		if !start!==:: (
			if /i !st.command!==~ext (
				exit /b
			)
		
			if "!st.command!"=="{" (
				set st.codeblock=true
			)
			
			if "!st.command!"=="}" (
				set "st.codeblock="
			)
			
			if not defined st.codeblock (
				call :commandHandling "!st.command!", "%%b"
			)
		)
		
		if !start!==## (
			if /i !st.command!==~ext (
				exit /b
			)
		
			if "!st.command!"=="{" (
				set st.codeblock=true
			)
			
			if "!st.command!"=="}" (
				set "st.codeblock="
			)
			
			if not defined st.codeblock (
				call :commandHandling "!st.command!", "%%b"
			)
		)
		
		if !start!==// (
			if /i !st.command!==~ext (
				exit /b
			)
		
			if "!st.command!"=="{" (
				set st.codeblock=true
			)
			
			if "!st.command!"=="}" (
				set "st.codeblock="
			)
			
			if not defined st.codeblock (
				call :commandHandling "!st.command!", "%%b"
			)
		)
	)
)

if !st.line! GEQ !Stack_x.length! (
	call :clear "Stack_x"

	set st.title=ST - Script: %ST_SCRIPT% - Ended - Line: !st.line!

	title !st.title!

	exit /b
) else (
	goto :readStackX
)

:commandHandling
set cmd=%~1
set data=%~2

if /i %cmd%==~nc (
	set st.mode_nocomment=true
)

if /i %cmd%==~dbg (
	set mode_debug=true
)

REM	Console instructions

if %cmd%==@ (
	for %%a in (%data%) do (
		set "valid="
		set "tempd=%%a"
		set "tempd_=!tempd:~1!"
		set "tempd=!tempd:~0,1!"
		
		if !tempd_!==a (
			set valid=true
		)
		
		if !tempd_!==b (
			set valid=true
		)
		
		if !tempd_!==c (
			set valid=true
		)
		
		if !tempd_!==x (
			set valid=true
		)
		
		if !tempd_!==y (
			set valid=true
		)
		
		if !tempd_!==z (
			set valid=true
		)
		
		if %%a==a (
			set valid=true
		)
		
		if %%a==b (
			set valid=true
		)
		
		if %%a==c (
			set valid=true
		)
		
		if %%a==h (
			set valid=true
		)
		
		if %%a==x (
			set valid=true
		)
		
		if %%a==y (
			set valid=true
		)
		
		if %%a==z (
			set valid=true
		)
		
		if defined valid (
			if !tempd!==. (
				call :tostring "Stack_!tempd_!", "s"
				set d=!tempd_!!s!
			) else (
				set d=!st.R_%%a!
			)
			
			if defined d (
				echo !d!
			) else (
				echo ERROR IN INSTRUCTION
			)
		) else (
			echo ERROR IN INSTRUCTION
		)
		
		set "d="
		set "s="
		set "tempd="
		set "tempd_="
	)
)

if %cmd%==@_ (
	pause
)

REM Script instructions

if %cmd%==#~ (
	if !mode_debug!==true (
		echo Changed line pointer from line '!st.line!' to line '%data%'
	)

	set /a st.line=%data%
)

REM	Stack instructions

if %cmd%==+ (
	for /f "tokens=1,2 delims= " %%c in ("%data%") do (
		if /i %%c==a (
			set valid=true
		)
		
		if /i %%c==b (
			set valid=true
		)
		
		if /i %%c==c (
			set valid=true
		)
		
		if defined valid (
			set val=%%d
			set val=!val:~0,1!
			
			if !val!==_ (
				set "val= "
			)
			
			if !mode_debug!==true (
				echo Pushed '!val!' to stack '%%c'
			)
			
			call :add "Stack_%%c", "!val!"
		)
		
		set "val="
	)
)

if %cmd%==++ (
	for /f "tokens=1,2* delims= " %%c in ("%data%") do (
		if /i %%c==a (
			set valid=true
		)
		
		if /i %%c==b (
			set valid=true
		)
		
		if /i %%c==c (
			set valid=true
		)
		
		if /i %%c==x (
			set valid=true
		)
		
		if defined valid (
			set val=%%e
			
			if !val!==_ (
				set "val= "
			)
			
			if defined Stack_%%c[%%d] (
				if !mode_debug!==true (
					echo Set index '%%d' on stack '%%c' to '!val!'
				)
				
				set "Stack_%%c[%%d]=!val!"
			)
		)
		
		set "val="
	)
)

if "%cmd%"=="+~" (
	for /f "tokens=1,2,3 delims= " %%c in ("%data%") do (
		set tmp=!Stack_%%c[%%d]!;
		
		if %%e==a (
			set valid=true
		)
		
		if %%e==b (
			set valid=true
		)
		
		if %%e==c (
			set valid=true
		)
		
		if defined valid (
			if !mode_debug!==true (
				echo Expanded data in stack '%%c' at index '%%d' to stack '%%e'
			)
		
			call :expandStack "%%c", "%%d", "%%e"
		)
	)
)

if "%cmd%"=="+-" (
	for /f "tokens=1,2 delims= " %%c in ("%data%") do (
		if %%c==a (
			set valid=true
		)
		
		if %%c==b (
			set valid=true
		)
		
		if %%c==c (
			set valid=true
		)
		
		if %%c==y (
			set valid=true
		)
		
		if defined valid (
			set /a length=!Stack_%%c.length! - 1
		
			for /l %%n in (0, 1, !length!) do (
				set data=!Stack_%%c[%%n]!
				
				if not %%n==%%d (
					call :add "StorageStack", "!data!"
				)
			)
			
			call :clear "Stack_%%c"
			
			set "length="
			
			set /a length=!StorageStack.length! - 1
			
			for /l %%n in (0, 1, !length!) do (
				set data=!StorageStack[%%n]!
				
				call :add "Stack_%%c", "!data!"
			)
			
			call :clear "StorageStack"
			
			if !mode_debug!==true (
				echo Removed item in stack '%%c' at index '%%d' and moved data up
			)
			
			set "length="
		)
	)
)

if "%cmd%"=="+." (
	for /f "tokens=1,2 delims= " %%c in ("%data%") do (
		if %%d==a (
			set valid=true
		)
		
		if %%d==b (
			set valid=true
		)
		
		if %%d==c (
			set valid=true
		)
		
		if defined valid (
			for /l %%a in (0, 1, !Stack_%%c.length!) do (
				set val=!val!!Stack_%%c[%%a]!
			)
			
			if !mode_debug!==true (
				echo Shifted and condensed stack data from stack '%%c' to stack '%%d'
			)
			
			call :add "Stack_%%d", "!val!"
		)
	)
	
	set "val="
)

if "%cmd%"=="+.." (
	for /f "tokens=1,2 delims= " %%c in ("%data%") do (
		if %%d==a (
			set valid=true
		)
		
		if %%d==b (
			set valid=true
		)
		
		if %%d==c (
			set valid=true
		)
		
		if defined valid (
			set /a len=!Stack_%%c.length!-1
	
			for /l %%a in (0, 1, !len!) do (
				call :add "Stack_%%d", "!Stack_%%c[%%a]!"
			)
			
			if !mode_debug!==true (
				echo Shifted stack data from stack '%%c' to stack '%%d'
			)
			
			set "len="
		)
	)
)

REM	Register instructions

if "%cmd%"=="$@" (
	for /f "tokens=1* delims= " %%c in ("%data%") do (
		if /i %%c==a (
			set valid=true
		)
		
		if /i %%c==b (
			set valid=true
		)
		
		if /i %%c==c (
			set valid=true
		)
		
		if defined valid (
			set /p st.R_%%c=%%d
		)
	)
)

if "%cmd%"=="$$" (
	for /f "tokens=1,2 delims= " %%c in ("%data%") do (
		if /i %%c==a (
			set valid=true
		)
		
		if /i %%c==b (
			set valid=true
		)
		
		if /i %%c==c (
			set valid=true
		)
	
		if defined valid (
			set st.R_%%c=!st.R_%%d!
			
			if !mode_debug!==true (
				echo Pushed data from register '%%d' to register '%%c'
			)
		)
	)
)

if "%cmd%"=="$." (
	for /f "tokens=1,2,3 delims= " %%c in ("%data%") do (
		if "%%e"=="" (
			if /i %%c==a (
				set valid=true
			)
			
			if /i %%c==b (
				set valid=true
			)
			
			if /i %%c==c (
				set valid=true
			)
		
			if defined valid (
				set st.R_%%c=!Stack_%%c[%%d]!
				
				if !mode_debug!==true (
					echo Pushed data from stack '%%c' in index '%%d' to register '%%c'
				)
			)
		) else (
			if /i %%e==a (
				set valid=true
			)
			
			if /i %%e==b (
				set valid=true
			)
			
			if /i %%e==c (
				set valid=true
			)
			
			if /i %%e==h (
				set valid=true
			)
		
			if defined valid (
				set st.R_%%e=!Stack_%%c[%%d]!
				
				if !mode_debug!==true (
					echo Pushed data from stack '%%c' in index '%%d' to register '%%e'
				)
			)
		)
	)
)

if "%cmd%"=="$+" (
	for /f "tokens=1,2 delims= " %%c in ("%data%") do (
		if /i %%c==a (
			set valid=true
		)
		
		if /i %%c==b (
			set valid=true
		)
		
		if /i %%c==c (
			set valid=true
		)
		
		if defined valid (
			if "%%d"=="" (
				call :add "Stack_%%c", "!st.R_%%c!"
				
				if !mode_debug!==true (
					echo Pushed data from register '%%c' to stack '%%c'
				)
			) else (
				if /i %%d==a (
					set valid=true
				)
				
				if /i %%d==b (
					set valid=true
				)
				
				if /i %%d==c (
					set valid=true
				)
			
				if defined valid (
					call :add "Stack_%%c", "!st.R_%%d!"
					
					if !mode_debug!==true (
						echo Pushed data from register '%%d' to stack '%%c'
					)
				)
			)
		)
	)
)

REM Conditional IF instructions

if %cmd%==* (
	for /f "tokens=1,2,3* delims= " %%c in ("%data%") do (
		if /i "%%c"=="$*" (
			set v2=true
		)
		
		if /i "%%c"=="$/*" (
			set v2=true
		)
		
		if /i "%%c"=="=~" (
			set v2=true
		)
		
		if /i "%%c"=="/=~" (
			set v2=true
		)
		
		if /i "%%c"=="$#" (
			set v2=true
		)
		
		if /i "%%c"=="/$#" (
			set v2=true
		)
		
		if /i "%%c"==".*" (
			set v2=true
		)
		
		if /i "%%c"=="./*" (
			set v2=true
		)
	
		if /i %%d==a (
			set v1=true
		)
		
		if /i %%d==b (
			set v1=true
		)
		
		if /i %%d==c (
			set v1=true
		)
		
		if /i %%d==z (
			set v1=true
		)
		
		if /i %%d==h (
			set v1=true
		)
		
		if /i %%e==a (
			set v2=true
		)
		
		if /i %%e==b (
			set v2=true
		)
		
		if /i %%e==c (
			set v2=true
		)
		
		if /i %%e==z (
			set v2=true
		)
		
		if /i %%e==h (
			set v2=true
		)
		
		if defined v1 (
			if defined v2 (
				set valid=true
			)
		)
		
		set "v1="
		set "v2="
		
		if defined valid (
			set "cond=%%c"
			
			if "!cond!"=="=" (
				if !st.R_%%d!==!st.R_%%e! (
					for /f "tokens=1* delims= " %%n in ("%%f") do (
						call :commandHandling "%%n", "%%o"
					)
				)
			)
			
			if "!cond!"=="/=" (
				if not !st.R_%%d!==!st.R_%%e! (
					for /f "tokens=1* delims= " %%n in ("%%f") do (
						call :commandHandling "%%n", "%%o"
					)
				)
			)
			
			if "!cond!"=="$*" (
				if not "!st.R_%%d!"=="" (
					for /f "tokens=1* delims= " %%n in ("%%f") do (
						call :commandHandling "%%n", "%%o"
					)
				)
			)
			
			if "!cond!"=="$/*" (
				if "!st.R_%%d!"=="" (
					for /f "tokens=1* delims= " %%n in ("%%f") do (
						call :commandHandling "%%n", "%%o"
					)
				)
			)
			
			if "!cond!"=="=~" (
				if "!st.R_%%d!"=="%%e" (
					for /f "tokens=1* delims= " %%n in ("%%f") do (
						call :commandHandling "%%n", "%%o"
					)
				)
			)
			
			if "!cond!"=="/=~" (
				if not "!st.R_%%d!"=="%%e" (
					for /f "tokens=1* delims= " %%n in ("%%f") do (
						call :commandHandling "%%n", "%%o"
					)
				)
			)
			
			if "!cond!"=="$#" (
				for /f "delims=0123456789" %%i in ("!st.R_%%d!") do set var=%%i
				
				if not defined var (
					for /f "tokens=1* delims= " %%n in ("%%f") do (
						call :commandHandling "%%n", "%%o"
					)
				)
				
				set "var="
			)
			
			if "!cond!"=="/$#" (
				for /f "delims=0123456789" %%i in ("!st.R_%%d!") do set var=%%i
				
				if defined var (
					for /f "tokens=1* delims= " %%n in ("%%f") do (
						call :commandHandling "%%n", "%%o"
					)
				)
				
				set "var="
			)
			
			if "!cond!"==".*" (
				if defined Stack_%%d.length (
					for /f "tokens=1* delims= " %%n in ("%%f") do (
						call :commandHandling "%%n", "%%o"
					)
				)
			)
			
			if "!cond!"=="./*" (
				if not defined Stack_%%d.length (
					for /f "tokens=1* delims= " %%n in ("%%f") do (
						call :commandHandling "%%n", "%%o"
					)
				)
			)
		
			set "cond="
		)
	)
)

REM Maths instructions

if %cmd%==:+ (
	for /f "tokens=1,2,3 delims= " %%c in ("%data%") do (
		if /i %%c==a (
			set valid=true
		)
		
		if /i %%c==b (
			set valid=true
		)
		
		if /i %%c==c (
			set valid=true
		)
		
		if defined valid (
			set num_a=!st.R_%%d!
			set num_b=!st.R_%%e!
		
			set /a "st.R_%%c=num_a+num_b"
			
			if !mode_debug!==true (
				echo Adding values of registers '%%d' and '%%e' together and offloading output to register '%%c'
			)
		)
		
		set "num_a="
		set "num_b="
	)
)

if %cmd%==:- (
	for /f "tokens=1,2,3 delims= " %%c in ("%data%") do (
		if /i %%c==a (
			set valid=true
		)
		
		if /i %%c==b (
			set valid=true
		)
		
		if /i %%c==c (
			set valid=true
		)
		
		if defined valid (
			set num_a=!st.R_%%d!
			set num_b=!st.R_%%e!
		
			set /a "st.R_%%c=num_a-num_b"
			
			if !mode_debug!==true (
				echo Subtracting values of registers '%%d' and '%%e' together and offloading output to register '%%c'
			)
		)
		
		set "num_a="
		set "num_b="
	)
)

if %cmd%==:* (
	for /f "tokens=1,2,3 delims= " %%c in ("%data%") do (
		if /i %%c==a (
			set valid=true
		)
		
		if /i %%c==b (
			set valid=true
		)
		
		if /i %%c==c (
			set valid=true
		)
		
		if defined valid (
			set num_a=!st.R_%%d!
			set num_b=!st.R_%%e!
		
			set /a "st.R_%%c=num_a*num_b"
			
			if !mode_debug!==true (
				echo Multiplying values of registers '%%d' and '%%e' together and offloading output to register '%%c'
			)
		)
		
		set "num_a="
		set "num_b="
	)
)

if %cmd%==:/ (
	for /f "tokens=1,2,3 delims= " %%c in ("%data%") do (
		if /i %%c==a (
			set valid=true
		)
		
		if /i %%c==b (
			set valid=true
		)
		
		if /i %%c==c (
			set valid=true
		)
		
		if defined valid (
			set num_a=!st.R_%%d!
			set num_b=!st.R_%%e!
		
			set /a "st.R_%%c=num_a/num_b"
			
			if !mode_debug!==true (
				echo Dividing values of registers '%%d' and '%%e' together and offloading output to register '%%c'
			)
		)
		
		set "num_a="
		set "num_b="
	)
)

REM File instructions

if "%cmd%"=="F" (
	for /f "tokens=1,2,3 delims= " %%c in ("%data%") do (
		if %%c==+ (
			if %%d==a (
				set valid=true
			)
			
			if %%d==b (
				set valid=true
			)
			
			if %%d==c (
				set valid=true
			)
			
			if defined valid (
				echo !st.R_%%d!>>%%e
			)
		)
		
		if %%c==$ (
			if %%d==a (
				set valid=true
			)
			
			if %%d==b (
				set valid=true
			)
			
			if %%d==c (
				set valid=true
			)
			
			if defined valid (
				for /f "usebackq tokens=*" %%n in ("%%e") do (
					call :add "Stack_%%d", "%%n"
				)
			)
		)
	)
)

REM Loop instructions

if /i %cmd%==L (
	for /f "tokens=1,2,3,4 delims= " %%c in ("%data%") do (
		if /i %%c==S (
			if !mode_debug!==true (
				echo Looping through stack '%%d'
			)
		
			for /l %%n in (0, 1, !Stack_%%d.length!) do (
				if not "!Stack_%%d[%%n]!"=="" (
					set "st.R_z=!Stack_%%d[%%n]!"
					
					call :loop
				)
			)
		)
		
		if /i %%c==N (
			if !mode_debug!==true (
				echo Looping through integer range, start '%%d', step '%%e', end '%%f'
			)
			
			set /a end=%%f
			
			if %%f==a (
				set /a end=!st.R_%%f!
			)
			
			if %%f==b (
				set /a end=!st.R_%%f!
			)
			
			if %%f==c (
				set /a end=!st.R_%%f!
			)
			
			if %%f==h (
				set /a end=!st.R_%%f!
			)
		
			for /l %%n in (%%d, %%e, !end!) do (
				call :loop
			)
			
			set "end="
		)
		
		if /i %%c==W (
			if "%%e"=="_" (
				set "delim= "
			) else (
				set delim=%%e
			)
			
			for /f "tokens=1,2 delims=," %%A in ("!st.R_%%f!") do (
				for %%n in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
					set char=%%n
					set "val=^%%^%char%"
					echo %%A !val!
					
					set "char="
				)
			)
		)
	)
)

REM Misc instructions

if %cmd%==- (
	for /f "tokens=1,2 delims= " %%c in ("%data%") do (
		if %%d==r (
			if !mode_debug!==true (
				echo Pulling item within register '%%c'
			)
		
			set "st.R_%%c="
		) else (
			if !mode_debug!==true (
				echo Clearing stack '%%c'
			)
		
			call :clear "Stack_%%c"
		)
	)
)

set "valid="

goto:EOF



:loop
for /l %%m in (!st.line!, 1, !Stack_x.length!) do (
	set code=!Stack_x[%%m]!

	if "!code!"=="}" (
		set "blockmode="
		
		goto:EOF
	)

	if "!code!"=="{" (
		set blockmode=true
	)

	if defined blockmode (
		set st.title=ST - Script: %ST_SCRIPT% - Executing - Line: %%m

		title !st.title!
	
		for /f "tokens=1* delims= " %%o in ("!code!") do (
			call :commandHandling "%%o", "%%p"
		)
	)
)

goto:EOF



:expandStack
set stackName=%~1
set index=%~2
set targetStack=%~3

set tmp=!Stack_%stackName%[%index%]!

:loopExpand

set char=!tmp:~0,1!

set tmp=!tmp:~1!

call :add "Stack_%targetStack%", "!char!"

if not "!tmp!"=="%EOLChar%" goto :loopExpand

goto:EOF













REM Start array handlers

:add
REM Adds a new item at the end of an array
REM Arguments: (
REM name As "Array Name",
REM value As "New value"
REM )
set array.name=%~1
set array.value=%~2
set "array.value=%array.value:"=%"
if defined %array.name%[0] (
	set /a array.index=%array.name%.length
) else (
	set array.index=0
)
set /a "%array.name%.length+=1"
set %array.name%[%array.index%]=%array.value%
set /a array.index=0
goto :eof


:getitem
REM Get value of index in array.
REM Arguments: (
REM name As "Array Name",
REM index As "Item Index",
REM var As "Output Variable"
REM )
set array.name=%~1
set array.index=%~2
set array.var=%~3
set "%array.var%=!%array.name%[%array.index%]!"
goto :eof

:tostring
REM Get a string value of the array
REM Arguments: (
REM name AS "Array Name"
REM var AS "Output Variable"
REM )
set array.name=%~1
set array.var=%~2
set data=[
if defined %array.name%[0] (
	for /l %%a in (0, 1, !%array.name%.length!) do (
		if %%a==0 (
			set data=!data!!%array.name%[%%a]!
		) else (
			if %%a==!%array.name%.length! (
				set data=!data!!%array.name%[%%a]!
			) else (
				set data=!data!,!%array.name%[%%a]!
			)
		)
	)
)
set data=!data!]
set %array.var%=!data!
goto :eof

:clear
REM Clears out all entries in the array
REM Arguments: (
REM name AS "Array Name"
REM )
set array.name=%~1
if defined %array.name%[0] (
	for /l %%a in (0, 1, !%array.name%.length!) do (
		set "%array.name%[%%a]="
	)
	set "%array.name%.length="
)
goto :eof

:set
REM Sets the given index of the array to the given value
REM Arguments: (
REM name AS "Array Name"
REM index AS "Index"
REM data AS "Data"
REM )
set array.name=%1
set array.index=%2
set data=%3
set "%array.name%[%array.index%]=%data%"
goto :eof

:loop
REM Loops through all array values and allows you to do what you wish with them
REM Arguments: (
REM name AS "Array Name"
REM code AS "MS-DOS Code"
REM )
set array.name=%1
set code=%2
for /f "tokens=1,2,3 delims=[=]" %%a in ('set %array.name%[') do (
	echo %%c
)
goto :eof