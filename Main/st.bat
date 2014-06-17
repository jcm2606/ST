@echo off

setlocal EnableDelayedExpansion

REM	ST Interpreter
REM	ST (short for ScripT) is a lightweight script interpreter written in batch.
REM This is the only file ST uses and requires.

REM ST differentiates it's commands based on a specific set of starting strings.
REM To use a command, you must first start the line with "::", "##" or "//".
REM ST will recognise "::" or "#" and then take that line as a command, else it will take the line as a comment and ignore it.

if "%1"=="" (
	echo ERROR: ST requires you to pass a script file as a parameter.
	echo        For example, "st test_script.txt".
	
	for %%x in (%cmdcmdline%) do if /i "%%~x"=="/c" set DOUBLECLICKED=1
	if defined DOUBLECLICKED pause
	
	exit /b
)

set ST_SCRIPT=%1

set title=ST - Script: %ST_SCRIPT%

title !title!

if not "%~2"=="" (
	for %%a in (%~2) do (
		call :add "Stack_y", "%%a"
	)
)

set mode_nocomment=false

echo.

for /F "tokens=1* delims=]" %%a in ('type "%ST_SCRIPT%" ^| find /V /N ""') do (
	set title=ST - Script: %ST_SCRIPT% - Building script stack

	title !title!

	if "%%b"=="" (
		call :add "Stack_x", "NULL_LINE"
	) else (
		call :add "Stack_x", "%%b"
	)
)

set /a line=-1

:readStackX
set /a line+=1

for /f "tokens=1* eol=` delims= " %%a in ("!Stack_x[%line%]!") do (
	set title=ST - Script: %ST_SCRIPT% - Line: !line!

	title !title!

	set command=%%a
	set start=!command:~0,2!
	set command=!command:~2!

	if !mode_nocomment!==true (
		set command=%%a
	
		if /i !command!==~ext (
			exit /b
		)
	
		if "!command!"=="{" (
			set codeblock=true
		)
		
		if "!command!"=="}" (
			set "codeblock="
		)
		
		if not defined codeblock (
			call :commandHandling "!command!", "%%b"
		)
	) else (
		if !start!==:: (
			if /i !command!==~ext (
				exit /b
			)
		
			if "!command!"=="{" (
				set codeblock=true
			)
			
			if "!command!"=="}" (
				set "codeblock="
			)
			
			if not defined codeblock (
				call :commandHandling "!command!", "%%b"
			)
		)
		
		if !start!==## (
			if /i !command!==~ext (
				exit /b
			)
		
			if "!command!"=="{" (
				set codeblock=true
			)
			
			if "!command!"=="}" (
				set "codeblock="
			)
			
			if not defined codeblock (
				call :commandHandling "!command!", "%%b"
			)
		)
		
		if !start!==// (
			if /i !command!==~ext (
				exit /b
			)
		
			if "!command!"=="{" (
				set codeblock=true
			)
			
			if "!command!"=="}" (
				set "codeblock="
			)
			
			if not defined codeblock (
				call :commandHandling "!command!", "%%b"
			)
		)
	)
)

if !line! GEQ !Stack_x.length! (
	set title=ST - Script: %ST_SCRIPT% - Line: !line! - Ended

	title !title!

	exit /b
) else (
	goto :readStackX
)

:commandHandling
set cmd=%~1
set data=%~2

if /i %cmd%==~nc (
	set mode_nocomment=true
)

if /i %cmd%==~dbg (
	set mode_debug=true
)

REM	Console instructions

if %cmd%==@ (
	for %%a in (%data%) do (
		set "tempd=%%a"
		set "tempd_=!tempd:~1!"
		set "tempd=!tempd:~0,1!"
		
		if !tempd!==. (
			call :tostring "Stack_!tempd_!", "s"
			set d=!tempd_!!s!
		) else (
			set d=!R_%%a!
		)
		
		if defined d (
			echo !d!
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
	set /a line=%data%
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
			call :expandStack "%%c", "%%d", "%%e"
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
				echo Shifted and condensed stack data from '%%c' to '%%d'
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
				echo Shifted stack data from '%%c' to '%%d'
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
			set /p R_%%c=%%d
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
				set R_%%c=!Stack_%%c[%%d]!
				
				if !mode_debug!==true (
					echo Pushed data from stack '%%e' in index '%%d' to register '%%c'
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
		
			if defined valid (
				set R_%%e=!Stack_%%c[%%d]!
				
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
				call :add "Stack_%%c", "!R_%%c!"
				
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
					call :add "Stack_%%c", "!R_%%d!"
					
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
				if !R_%%d!==!R_%%e! (
					for /f "tokens=1* delims= " %%n in ("%%f") do (
						call :commandHandling "%%n", "%%o"
					)
				)
			)
			
			if "!cond!"=="/=" (
				if not !R_%%d!==!R_%%e! (
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
			set num_a=!R_%%d!
			set num_b=!R_%%e!
		
			set /a "R_%%c=num_a+num_b"
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
			set num_a=!R_%%d!
			set num_b=!R_%%e!
		
			set /a "R_%%c=num_a+num_b"
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
			set num_a=!R_%%d!
			set num_b=!R_%%e!
		
			set /a "R_%%c=num_a*num_b"
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
			set num_a=!R_%%d!
			set num_b=!R_%%e!
		
			set /a "R_%%c=num_a/num_b"
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
				echo !R_%%d!>>%%e
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

if %cmd%==L (
	for /f "tokens=1,2,3,4 delims= " %%c in ("%data%") do (
		if /i %%c==S (
			for /l %%n in (0, 1, !Stack_%%d.length!) do (
				if not "!Stack_%%d[%%n]!"=="" (
					set "R_z=!Stack_%%d[%%n]!"
					
					call :loop
				)
			)
		)
		
		if /i %%c==N (
			for /l %%n in (%%d, %%e, %%f) do (
				call :loop
			)
		)
		
		if /i %%c==W (
			if "%%e"=="_" (
				set "delim= "
			) else (
				set delim=%%e
			)
		
			for /f "tokens=%%d delims=!delim!" %%a in ("!R_%%f!") do (
				
			
				call :loop
			)
		)
	)
)

REM Misc instructions

if %cmd%==- (
	for /f "tokens=1,2 delims= " %%c in ("%data%") do (
		if %%d==r (
			set "R_%%c="
		) else (
			call :clear "Stack_%%c"
		)
	)
)

set "valid="

goto:EOF



:loop
for /l %%m in (!line!, 1, !Stack_x.length!) do (
	set code=!Stack_x[%%m]!

	if "!code!"=="}" (
		set "blockmode="
		
		goto:EOF
	)

	if "!code!"=="{" (
		set blockmode=true
	)

	if defined blockmode (
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