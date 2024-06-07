*&---------------------------------------------------------------------*
*& Report ZPROG_FLUSH_TABLE_074
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZPROG_FLUSH_TABLE_074.

START-OF-SELECTION.

  DELETE FROM ztt_regs_074.

  IF sy-subrc = 0.
    MESSAGE 'Delete successful' TYPE 'S'.
  ELSEIF sy-subrc = 4.
    MESSAGE 'No rows affected by the instruction' TYPE 'I'.
  ELSE.
    MESSAGE 'Delete failed' TYPE 'E'.
  ENDIF.