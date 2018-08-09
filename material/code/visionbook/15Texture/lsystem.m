function lsystem(s,rules,angle,n) ;
% LSYSTEM --- L-system interpreter
% CMP   Vision Algorithms http://visionbook.felk.cvut.cz
%   
% An L-system (Lindenmayer system)  
% is an example of a syntactic shape and
% texture description technique . 
% It is mostly based on a recursive, context-free,
% deterministic grammar  although context and
% stochastic versions also exist. The distinguishing
% feature of an L-system is that at each iteration:
%   all applicable rules 
%  are applied, and  all rules  are applied simultaneously,
% in parallel.   For example, given a starting symbol
% F and a rule F  F+F--F+F,
% the first two iterations are:
% 
%   0: F
%   1: F+F--F+F
%   2: F+F--F+F+F+F--F+F--F+F--F+F+F+F--F+F
%   ...
% 
% The expansion is stopped after a predetermined number of iterations and
% the resulting string is interpreted, one character at a time. We implement
% symbols given in the following table - it is a simplified version of the 
% interpretation used
% in  or by L-system interpreter programs such as
% Fractint (http://spanky.triumf.ca/www/fractint/fractint.html).
% 
%  Symbol  Action 
%  F  Draw a line of a unit length in a current direction.
%  f  Move forward by a unit length in a current direction.
%  +  Turn left by angle  phi.
%  -  Turn right by angle  phi.
%  [  Remember the current state (position and direction).
%  ]  Retrieve the remembered position.
%   other  No action (ignored).
%
% The implementation given here draws directly into a current Matlab
% figure, which can be saved to a file  using print.
% The drawing starts at point (0, 0) and the initial orientation is
% along the positive x-axis.
%    
% Usage: lsystem(s,rules,angle,n)
% Inputs:
%   s    The start symbol (axiom).
%   rules  struct  The grammar rules. A string rules(i).left 
%     contains the left side of a rule i, which must be a single
%     letter symbol. A string rules(i).right contains the
%     right side of a rule i. No two rules may have the same left side.
%   angle  1x1  Angle increment  in radians.
%   n  1x1  Number of iterations. As most L-systems increase the string
%    length exponentially, the number of iterations will rarely exceed 10.
% Outputs:
%     There are no output parameters.
% 
  
% We iterate n-times over the grammar production rules, expanding
% the string s.
% In each iteration we
% go over the current string s from the left, character by
% character. For each character, all rules are considered.
% If a rule matches, its expansion is appended to the output
% string os.
% If no rule matches, the input character is copied to the output string
% unchanged.
  
for i = 1:n
  os = [];
  for j = 1:length(s)
    subst = false;             % a flag - has any rule matched? 
    for k = 1:length(rules)
      if s(j)==rules(k).left   % rule matches
        os = [os rules(k).right];
        subst = true;  break;
      end
    end
    if not(subst)              % no rule matched so far
       os = [os s(j)];
    end
  end % for j loop
  s = os;
end % for i loop

% The expanded string s is now interpreted. The current position
% and orientation is stored in x, y, and d, while
% l contains the length of a unit step. Operation `['
% stores the current state into a stack and `]'
% retrieves it.

stackpos  = 1;                 % index to the stack
x = 0;
y = 0; 
d = 0;
l = 1;
clf                            % start with a clean figure

for i = 1:length(s)
  cmd = s(i);
  switch( cmd )
    case 'F'
      x1 = l*cos(d) + x;
      y1 = l*sin(d) + y;
      line( [x x1], [y y1], 'Color','k', 'LineWidth',2 ); % draw
      x = x1;  y = y1;
    case 'f'
      x = l*cos(d) + x;
      y = l*sin(d) + y;
   case '+'
      d = d+angle;
   case '-'
      d = d-angle;
   case '['
      stack(stackpos).x = x;
      stack(stackpos).y = y;
      stack(stackpos).d = d;
      stackpos = stackpos+1;
   case ']'
      if stackpos<2, error('lsystem: Stack empty.'); end
      stackpos = stackpos-1;
      x = stack(stackpos).x;
      y = stack(stackpos).y;
      d = stack(stackpos).d;
  end
end

