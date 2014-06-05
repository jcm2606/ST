ST (ScripT) README file

TABLE OF CONTENTS
- What is ST?

- Coding with ST
    - Stacks
    - Registers
    - Instructions
    

    
WHAT IS ST?
    ST is an esoteric programming language (a programming language designed to push the boundaries, made for no purpose other then to push the limits and make a challenge) designed around the concept of Stacks.
    
CODING WITH ST
    ST is based solely around Stacks and Registers

    STACKS
        A stack is essentially a list in which data can be stored. In ST, a stack is the only place in memory a value can be placed within and persist over multiple instruction callbacks.
        
        There are 3 main stacks in ST, 'A', 'B' and 'C'. There are 2 system ones, 'X' and 'Y', these are not recommended to be accessed by scripts as ST uses these two stacks itself.
        
        Stacks are the best way to store data you need later.
        
    REGISTERS
        A register is a short-term temporary storage spot in memory for any value. You can load data out of a given index of a given stack into a register, then use the value stored in the register to do local calculations.
        
        Registers are only good for doing one-off instructions on, as in most cases, the moment you use a register, the register is cleared.
        
    INSTRUCTIONS
        + <stack> <value> :
            - Adds <value> to the given stack
            
        +. <stack 1> <stack 2> :
            - Condenses and shifts all values within <stack 1> into <stack 2>
            
        +.. <stack 1> <stack 2> :
            - Only shifts all values within <stack 1> into <stack 2>
            
        +~ <stack 1> <index> <stack 2>
            - Expands and shifts the value at index <index> from stack <stack 1> into stack <stack 2>
            
        $. <stack> <index> {register}
            - Loads the value from given index <index> from stack <stack> into given register {register}
            - {register} is optional
            - If no register is given, defaults to given stack
                - E.G. If <stack> was 'A', it would default to register 'A'
                
        $+ <register> {stack}
            - Adds the value within the register <register> to the given stack {stack}
            - {stack} is optional
            - If no register is given, defaults to given stack
                - E.G. If <register> was 'A', it would default to stack 'A'
                
        :+ <register 1> <register 2> <register 3>
            - Adds together arithmatically the values within registers <register 2> and <register 3> and stores the output in register <register 1>
            
        :- <register 1> <register 2> <register 3>
            - Subtracts arithmatically the values within registers <register 2> and <register 3> and stores the output in register <register 1>
            
        - <stack/register> {"r"}
            - Clears the given stack / register <stack/register>
            - If {"r"} (the quotation marks meaning literally the letter R) is supplied, logic applies to register <stack/register> instead
            
        @ <register> {register...}
            - Prints the value within register <register> to the console
            - If additional registers are supplied, prints values within those too, on separate lines
            - If <register> contains a '.' (period, full stop, dot) at the start, instead prints out the stack and includes an array list with individual values loaded in the given stack