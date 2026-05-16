/******************************/
/* File: TINY.flex            */
/* Lex specification for TINY */
/* Compiler Construction:     */
/* Principles and Practice    */
/* Kenneth C. Louden          */
/******************************/

%{
#include "globals.h"
#include "util.h"
#include "scan.h"
#include "util.c"

/* lexeme of identifier or reserved word */
char tokenString[MAXTOKENLEN+1];
%}

digit       [0-9]
number      {digit}+
letter      [a-zA-Z]
identifier  {letter}+
newline     \n
whitespace  [ \t]+

%%

"if"        { return IF;    }
"then"      { return THEN;  }
"else"      { return ELSE;  }
"end"       { return END;   }
"while"     { return WHILE; }
"until"     { return UNTIL; }
"read"      { return READ;  }
"write"     { return WRITE; }
"int"       { return INT;   }
"void"      { return VOID;  }

"/*"        {  /* Skip C-style block comment */
               while(1) {
                   char c = input();
                   if (c == EOF) break;
                   if (c == '\n') lineno++;
                   if (c == '*' && (c = input()) == '/') break;
               }
            }

">="        { return GE;     }
"<="        { return LE;     }
"=="        { return EQEQ;   }
"<>"        { return NE;     }
">"         { return GT;     }
":="        { return ASSIGN; }
"="         { return EQ;     }
"<"         { return LT;     }
"+"         { return PLUS;   }
"-"         { return MINUS;  }
"*"         { return TIMES;  }
"/"         { return OVER;   }
"("         { return LPAREN; }
")"         { return RPAREN; }
";"         { return SEMI;   }

{number}    { return NUM;   }
{identifier}{ return ID;    }

{newline}   { lineno++; }
{whitespace}{ /* skip whitespace */ }

"{"         {  /* Skip TINY-style { } comment */
               char c;
               do {
                   c = input();
                   if (c == EOF) break;
                   if (c == '\n') lineno++;
               } while (c != '}');
            }

.           { return ERROR; }

%%

/****************************************************/
/* User code section                                */
/****************************************************/

TokenType getToken(void)
{
    static int firstTime = TRUE;
    TokenType currentToken;

    if (firstTime) {
        firstTime = FALSE;
        lineno++;
        yyin    = fopen("tiny.txt", "r+");
        yyout   = fopen("result.txt", "w+");
        listing = yyout;
    }

    currentToken = yylex();
    strncpy(tokenString, yytext, MAXTOKENLEN);

    fprintf(listing, "\t%d: ", lineno);
    printToken(currentToken, tokenString);

    return currentToken;
}

int main(void)
{
    printf("welcome to the flex scanner: ");
    while (getToken()) {
        printf("a new token has been detected...\n");
    }
    return 1;
}
