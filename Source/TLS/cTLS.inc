{******************************************************************************}
{                                                                              }
{   Library:          Fundamentals TLS                                         }
{   File name:        cTLS.inc                                                 }
{   File version:     0.03                                                     }
{   Description:      TLS library defines                                      }
{                                                                              }
{******************************************************************************}

{.DEFINE DEBUG}
{.DEFINE SELFTEST}

{$INCLUDE cDefines.inc}

{$IFDEF DEBUG}
  {$DEFINE TLS_DEBUG}
{$ENDIF}

{$IFDEF DEBUG}
{$IFDEF SELFTEST}
  {$DEFINE TLS_SELFTEST}
{$ENDIF}
{$ENDIF}

