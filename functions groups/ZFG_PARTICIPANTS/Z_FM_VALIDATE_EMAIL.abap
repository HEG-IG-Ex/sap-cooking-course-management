FUNCTION Z_FM_VALIDATE_EMAIL_074.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_EMAIL) TYPE  ZDE_EMAIL_074
*"  EXPORTING
*"     VALUE(EV_EMAIL_VALID) TYPE  ABAP_BOOL
*"----------------------------------------------------------------------


DATA: lv_pattern TYPE string,
      lv_email TYPE ZDE_EMAIL_074.

  lv_pattern = '\w+(\.\w+)*@(\w+\.)+((\l|\u){2,4})'.
  CONDENSE iv_email.

  FIND REGEX lv_pattern IN iv_email MATCH COUNT DATA(lv_match_count).

  IF lv_match_count > 0.
    ev_email_valid = abap_true.
  ELSE.
    ev_email_valid = abap_false.
  ENDIF.


ENDFUNCTION.