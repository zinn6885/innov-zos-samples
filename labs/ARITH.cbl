       Identification Division.
       Program-Id. ARITH.
      *****************************************************************
      * Follow the instructions given in source comments.
      *****************************************************************
       Data Division.
       Working-Storage Section.

       01  Work-Fields.
           05  Field-Length      pic 9(4).
           05  Value-1           pic S9(5) sign is leading
                                           separate character.
           05  Value-2-X         pic x(4).
           05  Value-2 redefines Value-2-X
                                 pic s9(7) packed-decimal.
           05  a                 pic s9(7) packed-decimal.
           05  b                 pic s9(7) packed-decimal.
           05  c                 pic s9(7) packed-decimal.
           05  Sale-Amount       pic s9(5)v99 packed-decimal.
           05  Tax-Rate          pic s9v9(4) packed-decimal.
           05  Total-Amount      pic s9(5)v99 packed-decimal.
           05  Display-Amount    pic $$,$$$,$$9.99.

       Procedure Division.

      * Use the appropriate intrinsic function to get the length of
      * field Value-1 and put the result in Field-Length.

      *    <your code goes here>
           compute Field-Length =
               function length(Value-1)
           end-compute 
      *    move function length(Value-1) to Field-Length
           display "length: " Field-Length

      * Display just the sign of field Value-1.
      * Use reference modification to extract the sign character.

           move 43546 to Value-1
           display "sign is " Value-1(1:1)

      * Complete the code in paragraph Numeric-or-Not to avoid
      * Data Exception (S0C7) abends.

           move 1234567 to Value-2
           perform Numeric-or-Not
           add 1 to Value-2
           display "Value-2 is " Value-2
           move "ABCD" to Value-2-X
           perform Numeric-or-Not
           add 1 to Value-2
           display "Value-2 is " Value-2

      * Code the equivalent of the COMPUTE statement below using only
      * ADD, SUBTRACT, and MULTIPLY

           move 5 to b
           move -8 to c

           compute a =
               ((b * 4) + c) - 2
           end-compute
           display "Result using COMPUTE is: " a

      * <your code goes here>
           multiply 4 by b 
               giving a 
           end-multiply
           add c to a 
               giving a 
           end-add
           subtract 2 from a 
               giving a 
           end-subtract
           display "Result is: " a

      * Determine whether Value-2 is an even multiple of 4 using
      * the DIVIDE statement instead of FUNCTION MOD.

           move 23 to Value-2
           compute Value-1 =
               function mod(Value-2 4)
           end-compute
           divide Value-2 by 4 
               giving Value-1 
               remainder Value-1 
           end-divide
           if Value-1 equal zero
               display "Value-2 (" Value-2 ")"
                       " is an even multiple of 4"
           else
               display "Value-2 (" Value-2 ")"
                       "is not an even multiple of 4"
           end-if

      * Complete the definition of field Display-Amount so that it
      * will show the total amount with a floating dollar sign,
      * a comma separating the thousands position from the hundreds
      * position, and a decimal point between the dollars and cents.
      *
      * Apply Tax-Rate to Sale-Amount to result in Total-Amount.
      * Round the result.
      *
      * Display the total amount formatted as currency.

           move 45856.92 to Sale-Amount
           move .0225 to Tax-Rate
      * <your code goes here>
           add 1 to Tax-Rate
           end-add
           multiply Sale-Amount by Tax-Rate
               giving Display-Amount
           end-multiply
           display "Total-Amount is " Display-Amount

           goback
           .
       Numeric-or-Not.
           if Value-2 is numeric        
               display "Field Value-2 is numeric"
           else
               display "Field Value-2 is not numeric"
                       ", defaulting to zero"
               move zero to Value-2
           end-if
           .
