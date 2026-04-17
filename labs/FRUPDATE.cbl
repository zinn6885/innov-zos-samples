       Identification Division.
       Program-Id. FRUPDATE.
      *****************************************************************
      * Follow the instructions given in source comments.
      *****************************************************************
       Environment Division.
       Input-Output Section.
       File-Control.
           Select KSDS-File
               Record Key FD-KSDS-Key
               Assign to "FRSEED"
               Organization Indexed
               Access Dynamic
               File Status KSDS-File-Status.
           SELECT Update-File
              ASSIGN to "FRUPDATE"
              Organization sequential
              Access Sequential 
              File Status Update-File-Status.

       Data Division.
       File Section.
       FD  KSDS-File.
       01  FD-KSDS-Record.
           copy FRTHROW.
       FD  Update-File
           Recording mode F
           Record contains 80 characters
           Block contains 0 records
           Data record Update-File-Record.
       01  Update-File-Record.
           copy FRUPDATE.

       Working-Storage Section.
       01  File-Status-Indicators.
           05  KSDS-File-Status           pic x(02).
               88  KSDS-OK                value "00".
               88  KSDS-EOF               value "10".
               88  KSDS-Duplicate-Key     value "22".
               88  KSDS-Record-Not-Found  value "23".
           05  Update-File-Status         pic x(02).
               88  Update-File-OK         value "00".
               88  Update-File-EOF        value "10".
       01  KSDS-Record.
           05  KSDS-Key                   pic x(40).
           05  KSDS-Info.
              10  KT-Games                   pic 9(05).
              10  KT-Attempts                pic 9(05).
              10  KT-Completed               pic 9(05).
              10  KT-Three-Pointers          pic 9(05).
              10  KT-Pct-Completed           pic 9(03)v9.
              10  KT-Avg-Points              pic 9(04)v9. 
              10  KT-Last-Update             pic x(08).
       01  WorkingVars.
           05 ActionNum                   pic s999.
           05 CheckDataStatus             pic s99.
       01  Date-and-Time.
           05  TodayDate.
              10  DT-Year               pic 9(04).
              10  DT-Month              pic 9(02).
              10  DT-Day-of-Month       pic 9(02).
           05  DT-Hour               pic 9(02).
           05  DT-Minute             pic 9(02).
           05  DT-Second             pic 9(02).
           05  DT-Hundredth          pic 9(02).
           05  filler                pic x.
               88  DT-Behind-GMT     value "-".
               88  DT-Ahead-of-GMT   value "+".
               88  DT-GMT            value "0".
           05  DT-GMT-Offset-Hours   pic 9(02).
           05  DT-GMT-Offset-Minutes pic 9(02).

       Procedure Division.
      * open update file and check status
           display "before open"
           open input Update-File
           open i-o KSDS-File
           perform File-Check-Update
           perform File-Check-KSDS
           display "after open"

      * read through the Update File and perform the actions
           move 0 to ActionNum
           read Update-File
           perform File-Check-Update
           perform with test before
              until Update-File-EOF
              add 1 to ActionNum
              display "before action"
              perform Read-Next-Update
              display "after action"
              end-perform
           perform File-Quit

      * read and display the updated KSDS file
           open i-o KSDS-File
           move low-values to FD-KSDS-Key
           start KSDS-File
              key is >= FD-KSDS-Key
           end-start
           display " "
           display "Reading KSDS File: "
           move 99 to ActionNum
      *     move "read" to FTU-Operation
           perform File-Check-KSDS
           display "File checked"
           perform Read-Next-KSDS
           perform with test before
              until KSDS-EOF
              display KSDS-Record
              perform Read-Next-KSDS
           end-perform

           close KSDS-File
           goback
           .

       Read-Next-KSDS.
           move spaces to KSDS-Info
           read KSDS-File next
               into KSDS-Record
           end-read
      *     display "Read next"
           perform File-Check-KSDS
           .

       Read-Next-Update.
           display "Before check"
           perform CheckData
           display "after check"
           if CheckDataStatus equal zero 
              display "Equal zero"
              EVALUATE true
                 WHEN FTU-ADD
                    display "ADD " FTU-Team-Name FTU-Player-Name
                       FTU-Games-X FTU-Attempts-X FTU-Completed-X 
                       FTU-Three-Pointers-X
                    perform ActionAdd
                 WHEN FTU-DELETE
                    display "Delete " FTU-Team-Name FTU-Player-Name
                    perform ActionDelete
                 WHEN FTU-UPDATE   
                    display "update" 
                    display "Update " FTU-Team-Name FTU-Player-Name
                       FTU-Games-X FTU-Attempts-X FTU-Completed-X 
                       FTU-Three-Pointers-X
                    perform ActionUpdate
                 WHEN other
                    display "invalid FTU-Operation " FTU-Operation
              END-EVALUATE
           else 
              display "Invalid Data input. Status: " CheckDataStatus
              display "On action: " ActionNum " " FTU-Operation
           end-if
      *     move zeros to Update-File-Record
           read Update-File
           perform File-Check-Update 
           .

       MoveKey.
           move FTU-Team-Name to FT-Team-Name
           move FTU-Player-Name to FT-Player-Name
           move FD-KSDS-Key to KSDS-Key
           .
       ComputeData.
           compute KT-Pct-Completed =
              KT-Completed * 100 / KT-Attempts
           end-compute
           compute KT-Avg-Points =
              (KT-Completed + (KT-Three-Pointers * 2)) / KT-Games
           end-compute
           move function current-date to Date-and-Time
           move TodayDate to KT-Last-Update
           . 

       CheckData.
           move zero to CheckDataStatus
           if not FTU-Games-X is numeric
              move 1 to CheckDataStatus
           end-if
           if not FTU-Attempts-X is numeric
              move 2 to CheckDataStatus
           end-if
           if not FTU-Completed-X is numeric
              move 3 to CheckDataStatus
           end-if
           if not FTU-Three-Pointers-X is numeric
              move 4 to CheckDataStatus
           end-if
           .
       UpdateData.
           compute KT-Games =
              KT-Games + FTU-Games
           end-compute
           compute KT-Attempts =
              KT-Attempts + FTU-Attempts
           end-compute
           compute KT-Completed =
              KT-Completed + FTU-Completed
           end-compute
           compute KT-Three-Pointers =
              KT-Three-Pointers + FTU-Three-Pointers
           end-compute
           perform ComputeData
           .
       
       MoveData.
           compute KT-Games = FTU-Games end-compute
           compute KT-Attempts = FTU-Attempts end-compute
           compute KT-Completed = FTU-Completed end-compute
           compute KT-Three-Pointers = FTU-Three-Pointers end-compute
           perform ComputeData
           .

       ReadFromKSDS.
           move spaces to KSDS-Info
           read KSDS-File into KSDS-Record
           end-read
           Perform File-Check-KSDS
           .

       ActionUpdate.
           perform MoveKey
      *     display "Update read step"
           perform ReadFromKSDS
           perform UpdateData
      *     display "Update rewrite step"
           rewrite FD-KSDS-Record from KSDS-Record
           end-rewrite
           perform File-Check-KSDS
           .

       ActionDelete.
           perform MoveKey
           delete KSDS-File record
           perform File-Check-KSDS
           .

       ActionAdd.
           perform MoveKey
           perform MoveData
           write FD-KSDS-Record from KSDS-Record
           end-write
           perform File-Check-KSDS
           .

       File-Check-KSDS.
           if not KSDS-OK and not KSDS-EOF
              display "KSDS file status: " KSDS-File-Status
              display "On action: " ActionNum " " FTU-Operation
              perform 9900-Tragic-Ending
           end-if
           .
       File-Check-Update.
           if not Update-File-OK and not Update-File-EOF
              display "Update file status: " Update-File-Status
              display "On action: " ActionNum
              perform 9900-Tragic-Ending
           end-if
           .
       
       File-Quit.
           close Update-File
           close KSDS-File
           .

       9900-Tragic-Ending.
           move 12 to return-code
           perform File-Quit
           goback
           .

