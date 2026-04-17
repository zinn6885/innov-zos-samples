       Identification Division.
       Program-Id. TABSRCH.
      *****************************************************************
      * Follow the instructions given in source comments.
      *****************************************************************
       Environment Division.
       Input-Output Section.
       FILE-CONTROL.
           SELECT MTDATA
              ASSIGN to "MTDATA"
              Organization sequential
              Access Sequential 
              File Status MTDATA-Status.
      * <your code goes here - SELECT>

       Data Division.
       File Section.
       FD  MTDATA
           Recording mode F
           Record contains 80 characters
           Block contains 0 records
           Data record MTDATA-Input-Record.
       01  MTDATA-Input-Record         pic x(80).    

      * <your code goes here - FD>

       Working-Storage Section.
       01  Input-Record.
           copy TABREC.
       01  File-Status-Indicators.
           05 MTDATA-Status     pic x(2).
              88 MTDATA-OK      value "00".
              88 MTDATA-EOF     value "10".
       01  WorkingSpace.
           05 DisplayLine       pic x(100).
           05 Work1             pic x(20).
           05 Work2             pic x(20).
           05 Work3             pic x(20).
           05 Work4             pic x(20).
           05 FindMTN           pic x(30).
           05 UnstringSpaceIn   pic x(30).
           05 UnstringSpaceOut  pic x(30).
       01  MTDATA-Line-count    pic 9(2).
       01  Mt-Current.
           05 MT-StateC          pic x(2).
           05 MT-NameC           pic x(30).
           05 MT-HeightC         pic x(5).
       01  MT-Table.
           05 MT-Line occurs 1 to 50 times
                      depending on MTDATA-Line-count
                      ascending MT-Normalize
                      indexed by MT-Ix.
              10 MT-State          pic x(2).
                 88 AlaskaCode         value "AK".
              10 MT-Name           pic x(30).
              10 MT-Height         pic x(5).
              10 MT-Normalize      pic x(30).
      * <your code goes here - File Status field>

       Procedure Division.

      * Complete the missing code in the Environment Division,
      * Input-Output Section and the Data Division, File Section
      * to suport a sequential data set with fixed-blocked format
      * and 80-byte logical records. 
      * Specify a value for BLOCK CONTAINS that causes the program 
      * not to care what the actual block size is.
      *
      * Create a job in your JCL library to execute program TABSRCH.
      * Include a DD statement for the input data set named
      * <userid>.INNOV.TABDATA and give it a DDNAME that matches the
      * external name you coded on the SELECT statement for the file.
      * 
      * Code logic to open, read, and close the data set and to
      * populate a table in Working-Storage with the records from
      * the data set.
           display "before open"
           open input MTDATA
           perform File-Check
           display "after open"
           
           set MT-Ix to 1
           read MTDATA into MT-Line(MT-Ix)
           perform with test before
              varying MT-Ix from 1 by 1
              until MTDATA-EOF        
              perform File-Check
      *        move MTDATA-Input-Record(1:2) to MT-State(MT-Ix)
      *        move MTDATA-Input-Record(3:29) to MT-Name(MT-Ix)
      *        move MTDATA-Input-Record(33:5) to MT-Height(MT-Ix)
              add 1 to MTDATA-Line-count 
                 end-add
              read MTDATA into MT-Line(MT-Ix)
              display MT-Name(MT-Ix) 
                 " " MT-State(MT-Ix)
                 " " MT-Height(MT-Ix)
           end-perform
           perform File-Quit

      * Then code table search logic as described below. 
      *
      * Search #1 - serial search. 
      *
      * Find the US mountain outside of Alaska with the highest
      * elevation. Display its name, state abbreviation, and
      * elevation.
           set MT-Ix to 1
           search MT-Line
              varying MT-Ix
              at end display "No MTN found"
              when not AlaskaCode(MT-Ix)
                 string MT-Name(MT-Ix) delimited by "  "
                    " is in " delimited by size
                    MT-State(MT-Ix) delimited by size
                    " and is " delimited by size
                    MT-Height(MT-Ix) delimited by size
                    " meters tall" delimited by size
                 into DisplayLine
           end-search
           display DisplayLine
      *
      * Search #2 - binary search.
      * 
      * Note - The table is sorted descending by MTN-Elevation.
      *
      * Find the mountain with the highest elevation under 4500
      * meters. Display its name, state abbreviation, and
      * elevation.
      
           move spaces to DisplayLine
           move ZEROS to Mt-Current
           set MT-Ix to 1
           perform with test before
              varying MT-Ix from 1 by 1
              until MT-Ix greater than MTDATA-Line-count
              if MT-Height(MT-Ix) < 4500 AND 
                 MT-Height(MT-Ix) > MT-HeightC
                 move MT-Name(MT-Ix) to MT-NameC
                 move MT-State(MT-Ix) to MT-StateC
                 move MT-Height(MT-Ix) to MT-HeightC 
              end-if
           end-perform
           string MT-NameC delimited by "  "
              " is in " delimited by size
              MT-StateC delimited by size
              " and is " delimited by size
              MT-HeightC delimited by size
              " meters tall" delimited by size
           into DisplayLine
           display DisplayLine

      *
      * Search all for any mountain name
      * adjust the search key value so that it is normalized
      * dave made them all lowercase and no spaces
           perform PopulateNormalize
           move "Denali" to FindMTN
           perform SearchMountain
           move "Mount Williamson" to FindMTN
           perform SearchMountain
           move "Mount Bear" to FindMTN
           perform SearchMountain
           goback
           .

       SearchMountain.
           move FindMTN to UnstringSpaceIn
           perform UnstringSpace
           move UnstringSpaceOut to FindMTN
           set MT-Ix to 1
           search all MT-Line
              at end display "No MTN found"
              when MT-Normalize(MT-Ix) Equal FindMTN
                 display MT-State(MT-Ix) " " MT-Height(MT-Ix)
                    " " MT-Name(MT-Ix)
           end-search
           .

       UnstringSpace.
           move space to UnstringSpaceOut
           move spaces to Work1
           move spaces to Work2
           move spaces to Work3
           move spaces to Work4
           unstring UnstringSpaceIn delimited by all spaces
              into Work1 Work2 Work3 Work4
              move function lower-case(Work1) to Work1
              move function lower-case(Work2) to Work2
              move function lower-case(Work3) to Work3
              move function lower-case(Work4) to Work4
              string Work1 delimited by space 
                 Work2 delimited by space 
                 Work3 delimited by space 
                 Work4 delimited by space 
                 into UnstringSpaceOut
              end-string
           move spaces to UnstringSpaceIn
           .

       PopulateNormalize.
           perform with test before
              varying MT-Ix from 1 by 1
              until MT-Ix greater than MTDATA-Line-count
              move MT-Name(MT-Ix) to UnstringSpaceIn
              perform UnstringSpace
              move UnstringSpaceOut to MT-Normalize(MT-Ix)
      *        display MT-Line(MT-Ix)
           end-perform
           .

       File-Quit.
           close MTDATA
           .

       File-Check.
           if not MTDATA-OK
              display MTDATA-Status
              perform 9900-Tragic-Ending
           end-if
           .

       9900-Tragic-Ending.
           move 12 to return-code
           display "Error with input file"
           perform File-Quit
           goback
           .