/*** asmMult.s   ***/
/* SOLUTION; used to test C test harness
 * VB 10/14/2023
 */
    
/* Tell the assembler to allow both 16b and 32b extended Thumb instructions */
.syntax unified

#include <xc.h>

/* Tell the assembler that what follows is in data memory    */
.data
.align
 
/* define and initialize global variables that C can access */

.global a_Multiplicand,b_Multiplier,rng_Error,a_Sign,b_Sign,prod_Is_Neg,a_Abs,b_Abs,init_Product,final_Product
.type a_Multiplicand,%gnu_unique_object
.type b_Multiplier,%gnu_unique_object
.type rng_Error,%gnu_unique_object
.type a_Sign,%gnu_unique_object
.type b_Sign,%gnu_unique_object
.type prod_Is_Neg,%gnu_unique_object
.type a_Abs,%gnu_unique_object
.type b_Abs,%gnu_unique_object
.type init_Product,%gnu_unique_object
.type final_Product,%gnu_unique_object

/* NOTE! These are only initialized ONCE, right before the program runs.
 * If you want these to be 0 every time asmMult gets called, you must set
 * them to 0 at the start of your code!
 */
a_Multiplicand:  .word     0  
b_Multiplier:    .word     0  
rng_Error:       .word     0 
a_Sign:          .word     0  
b_Sign:          .word     0 
prod_Is_Neg:     .word     0 
a_Abs:           .word     0  
b_Abs:           .word     0 
init_Product:    .word     0
final_Product:   .word     0

 /* Tell the assembler that what follows is in instruction memory    */
.text
.align

 /* Make the following functions globally visible */
.global asmUnpack, asmAbs, asmMult, asmFixSign, asmMain
.type asmUnpack,%function
.type asmAbs,%function
.type asmMult,%function
.type asmFixSign,%function
.type asmMain,%function

/* function: asmUnpack
 *    inputs:   r0: contains the packed value. 
 *                  MSB 16bits is signed multiplicand (a)
 *                  LSB 16bits is signed multiplier (b)
 *              r1: address where to store unpacked, 
 *                  sign-extended 32 bit a value
 *              r2: address where to store unpacked, 
 *                  sign-extended 32 bit b value
 *    outputs:  r0: No return value
 *              memory: 
 *                  1) store unpacked A value in location
 *                     specified by r1
 *                  2) store unpacked B value in location
 *                     specified by r2
 */
asmUnpack:   
    
    /*** STUDENTS: Place your asmUnpack code BELOW this line!!! **************/
    push {r4-r11, lr}
    // copy r0 to a new register (r4) and (r5)
    mov r4, r0
    mov r5, r0

    // move the A bits into the LSB 16 bits of the r4 register
    asr r4, r4, #16
    // move the B bits to the MSB 16 bits then back to LSB 18 bits
    lsl r5, r5, #16
    asr r5, r5, #16

    // store contents for r4 to a_value in r1
    str r4, [r1]
    // store contents for r5 into b_value in r2
    str r5, [r2]
    
    // go back to asmMain function call
    pop {r4-r11, lr}
    bx lr
    
    /*** STUDENTS: Place your asmUnpack code ABOVE this line!!! **************/


    /***************  END ---- asmUnpack  ************/

 
/* function: asmAbs
 *    inputs:   r0: contains signed value
 *              r1: address where to store absolute value
 *              r2: address where to store sign bit:
 *                  0 = "+", 1 = "-"
 *    outputs:  r0: Absolute value of r0 input. Same value
 *                  as stored to location given in r1
 *              memory: 
 *                  1) store absolute value in location
 *                     given by r1
 *                  2) store sign bit in location 
 *                     given by r2
 */
asmAbs:  
    /*** STUDENTS: Place your asmAbs code BELOW this line!!! **************/
    push {r4-r11, lr}
    // copy c0 to a new register (r4) and r5 to be used later
    mov r4, r0
    mov r5, r0
    // compare r4 to zero
    cmp r4, #0
    // abs the value
    rsblt r4, r4, #0
    // store the abs value to r1
    str r4, [r1]
    // return back to r0
    mov r0, r4
    
    
    mov r6, #1	    // used for sign bit comparison
    // sign extension for 16 bit value
    asr r5, r5, #15
    // isolate sign bit
    ands r5, r5, r6
    // store sign bit to address (r2)
    str r5, [r2]
    // return back to asmMain function call
    pop {r4-r11, lr}
    bx lr

    /*** STUDENTS: Place your asmAbs code ABOVE this line!!! **************/


    /***************  END ---- asmAbs  ************/

 
/* function: asmMult
 *    inputs:   r0: contains abs value of multiplicand (a)
 *              r1: contains abs value of multiplier (b)
 *    outputs:  r0: initial product: r0 * r1
 */    
asmMult:   

    /*** STUDENTS: Place your asmMult code BELOW this line!!! **************/
    push {r4-r11, lr}
    // copy a_multiplicand to r4 and b_multiplier to r5
    mov r4, r0
    mov r5, r1

    // clear r8 to be used for sum
    mov r8, #0

iterate:    // procedes to iterate if multiplier is not zero
    cmp r5, #0
    beq store

    ands r9, r5, #1
    bne adding

add_ret:    // does appropriate shifts
    lsr r5, r5, #1
    lsl r4, r4, #1
    b iterate

adding:        // responsible for adding to the product result
    add r8, r8, r4
    b add_ret

store:        // put product to r0
    mov r0, r8
    // return to asmMain function call
    pop {r4-r11, lr}
    bx lr

    /*** STUDENTS: Place your asmMult code ABOVE this line!!! **************/
   
    /***************  END ---- asmMult  ************/


    
/* function: asmFixSign
 *    inputs:   r0: initial product: 
 *              (abs value of A) * (abs value of B)
 *              r1: sign bit of originally unpacked value
 *                  of A
 *              r2: sign bit of originally unpacked value
 *                  of B
 *    outputs:  r0: final product:
 *                  sign-corrected version of initial product
 */ 
asmFixSign:   
    
    /*** STUDENTS: Place your asmFixSign code BELOW this line!!! **************/
    push {r4-r11, lr}
    // check if final result should be negative
    eor r4, r1, r2
    cmp r4, #1
    beq neg_prod
    
    // otherwise branch to fix_sign_end
    b fix_sign_end
    
neg_prod:
    // if final result should be negative
    rsb r0, r0, #0
    
fix_sign_end:
    // return back to function call in asmMain
    pop {r4-r11, lr}
    bx lr
    
    
    /*** STUDENTS: Place your asmFixSign code ABOVE this line!!! **************/


    /***************  END ---- asmFixSign  ************/



    
/* function: asmMain
 *    inputs:   r0: contains packed value to be multiplied
 *                  using shift-and-add algorithm
 *           where: MSB 16bits is signed multiplicand (a)
 *                  LSB 16bits is signed multiplier (b)
 *    outputs:  r0: final product: sign-corrected product
 *                  of the two unpacked A and B input values
 *    NOTE TO STUDENTS: 
 *           To implement asmMain, follow the steps outlined
 *           in the comments in the body of the function
 *           definition below.
 */
asmMain:   
    
    /*** STUDENTS: Place your asmMain code BELOW this line!!! **************/
   
    // initial push and pop
    push {r4-r11, lr}
    pop {r4-r11, lr}
    //bx lr
    
    /* Step 1:
     * call asmUnpack. Have it store the output values in 
     * a_Multiplicand and b_Multiplier.
     */
    
    // call asmUnpack by calling function on the stack
    push {r4-r11, lr}
    
    // load addresses to input variable registers
    ldr r1, =a_Multiplicand
    ldr r2, =b_Multiplier
    
    //push {r0-r2}
    // call asmUnpack
    bl asmUnpack
    //pop {r0-r2}
    
    // remove from stack
    //pop {r4-r11, lr}
    //bx lr


    /* Step 2a:
     * call asmAbs for the multiplicand (A). Have it store the
     * absolute value in a_Abs, and the sign in a_Sign.
     */

    // call asmAbs for multiplicand A to the stack
    //push {r4-r11, lr}
    
    // load input variables
    ldr r0, =a_Multiplicand	// multiplicand value
    ldr r0, [r0]
    ldr r1, =a_Abs		// address for a_Abs
    ldr r2, =a_Sign		// address for a_Sign
    
    //push {r0-r2}
    // call asmAbs
    bl asmAbs
    //pop {r0-r2}
    // remove from stack
    //pop {r4-r11, lr}
    //bx lr


    /* Step 2b:
     * call asmAbs for the multiplier (B). Have it store the
     * absolute value in b_Abs, and the sign in b_Sign.
     */
    
    // call asmAbs for multiplier B to the stack
    //push {r4-r11, lr}
    
    // load input variables
    ldr r0, =b_Multiplier	// multiplicand value
    ldr r0, [r0]
    ldr r1, =b_Abs		// address for a_Abs
    ldr r2, =b_Sign		// address for a_Sign
    
    //push {r0-r2}
    // call asmAbs
    bl asmAbs
    //pop {r0-r2}
    // remove from stack
    //pop {r4-r11, lr}
    //bx lr


    /* Step 3:
     * call asmMult. Pass a_Abs as the multiplicand, 
     * and b_Abs as the multiplier.
     * asmMult returns the initial (positive) product in r0.
     * Store the value returned in r0 to mem location 
     * init_Product.
     */

    // call asmMult to the stack
    //push {r4-r11, lr}

    // load input variables
    ldr r0, =a_Abs	// abs value of multiplicand (a)
    ldr r0, [r0]
    ldr r1, =b_Abs	// abs value of multiplier (b)
    ldr r1, [r1]
    
    // call asmMult
    //push {r0-r1}
    bl asmMult
    
    // store value to init_Product
    ldr r11, =init_Product
    str r0, [r11]
    //pop {r0-r1}
    
    // remove from stack
    //pop {r4-r11, lr}
    //bx lr

    /* Step 4:
     * call asmFixSign. Pass in the initial product, and the
     * sign bits for the original a and b inputs. 
     * asmFixSign returns the final product with the correct
     * sign. 
     * Store the value returned in r0 to mem location 
     * final_Product.
     */
    
    // call asmFixSign to stack
    //push {r4-r11, lr}
    
    // load input variables
    // load sign bit for A
    ldr r1, =a_Sign
    ldr r1, [r1]
    // load sign bit for B
    ldr r2, =b_Sign
    ldr r2, [r2]
    
    //push {r0-r2}
    // call asmFixSign
    bl asmFixSign
    
    // store value to final_Product
    ldr r11, =final_Product
    str r0, [r11]
    //pop {r0-r2}
    
    // remove from stack
    pop {r4-r11, lr}
    bx lr


    /* Step 5:
     * END! Return to caller. Make sure of the following:
     * 1) Stack has been correctly managed.
     * 2) the final answer is stored in r0, so that the C call
     *    can access it.
     */



    
    /*** STUDENTS: Place your asmMain code ABOVE this line!!! **************/


    /***************  END ---- asmMain  ************/

 
    
    
.end   /* the assembler will ignore anything after this line. */