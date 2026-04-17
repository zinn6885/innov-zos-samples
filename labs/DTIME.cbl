       Identification Division.
       Program-Id. DTIME.
      *****************************************************************
      * Follow the instructions given in source comments.
      *****************************************************************
       Data Division.
       Working-Storage Section.

       01  Date-and-Time.
           05  DT-Year               pic 9(04).
           05  DT-Month              pic 9(02).
           05  DT-Day-of-Month       pic 9(02).
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

       01  Work-Dates.
           05  Date-1                pic 9(8).
           05  Date-2                pic 9(8).
           05  DateDiff              pic 9(8).
           05  IntDate1              pic 9(8).
           05  IntDate2              pic 9(8).

       01  Day-of-Week-Code          pic 9.
       01  GOF                       pic x(132).
       01  GMT-Text                  pic x(20).
       01  Day-of-Week-Values.
           05  filler pic x(9) value "Monday   ".
           05  filler pic x(9) value "Tuesday  ".
           05  filler pic x(9) value "Wednesday".
           05  filler pic x(9) value "Thursday ".
           05  filler pic x(9) value "Friday   ".
           05  filler pic x(9) value "Saturday ".
           05  filler pic x(9) value "Sunday   ".
       01  Day-of-Week-Table redefines Day-of-Week-Values.
           05  Day-Name    occurs 7 times
                           indexed by Day-Index
                           pic x(9).






       Procedure Division.

      * Use the appropriate intrinsic function to get the current
      * system date and time and place the value in Date-and-Time.
      * Display the date and time in the following format:
      *
      *          1         2         3         4         5         6
      * 123456789012345678901234567890123456789012345678901234567890
      * The date/time: YYYY-MM-DD hh:mm:ss HH before GMT
      *                                       after GMT
      *                                       GMT

      * <your code goes here>
           move function current-date to Date-and-Time
           EVALUATE true
               WHEN DT-Ahead-of-GMT
                  string DT-GMT-Offset-Hours delimited by size
                    " after GMT" delimited by size
                    into GMT-Text
                  end-string  
               WHEN DT-Behind-GMT
                  string DT-GMT-Offset-Hours delimited by size
                    " behind GMT" delimited by size
                    into GMT-Text
                  end-string 
               WHEN other
                  string " GMT" delimited by size
                    into GMT-Text
                  end-string 
                    
           END-EVALUATE
           
           string DT-Year delimited by size
              "-" delimited by size
              DT-Month delimited by size
              "-" delimited by size
              DT-Day-of-Month delimited by size
              " " delimited by size
              DT-Hour delimited by size
              ":" delimited by size
              DT-Minute delimited by size
              ":" delimited by size
              DT-Second delimited by size
              " " delimited by size
              GMT-Text delimited by size
              into GOF
           end-string
           display "The date/time: " GOF

      * Complete the code for Day-of-Week-Values, following the
      * pattern suggested by the incomplete code. Adjust the occurs
      * clause value in Day-of-Week-Table accordingly.
      * Use the appropriate ACCEPT statement to obtain the day of
      * week code for the current system date.
      * Display messages of the form:
      *
      *          1         2         3         4         5         6
      * 123456789012345678901234567890123456789012345678901234567890
      * Today is a Wednesday
      * Tomorrow will be a Thursday

      * <your code goes here>
           accept Day-of-Week-Code from DAY-OF-WEEK
           display "Today is a " Day-Name(Day-of-Week-Code)
           compute Day-of-Week-Code =
               function mod(Day-of-Week-Code 7)
           end-compute
           add 1 to Day-of-Week-Code
           display "Tomorrow will be a " Day-Name(Day-of-Week-Code)


      * Use the appropriate intrinsic functions and arithmetic
      * statements to calculate the number of days between two dates.

           move 20260524 to Date-1
           move 20251213 to Date-2
           compute IntDate1 =
              function integer-of-date(Date-1)
           end-compute
           compute IntDate2 =
              function integer-of-date(Date-2)
           end-compute
           subtract
              IntDate2 from IntDate1
              giving DateDiff
           end-subtract
           display "There are " DateDiff " days between " 
              Date-1 " and " Date-2


           move 20251031 to Date-1
           move 20240702 to Date-2
           compute IntDate1 =
              function integer-of-date(Date-1)
           end-compute
           compute IntDate2 =
              function integer-of-date(Date-2)
           end-compute
           subtract
              IntDate2 from IntDate1
              giving DateDiff
           end-subtract
           display "There are " DateDiff " days between " 
              Date-1 " and " Date-2


           goback
           .
