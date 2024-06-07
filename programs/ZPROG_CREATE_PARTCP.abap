*&---------------------------------------------------------------------*
*& Report ZPROG_CREATE_PARTCP_074
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZPROG_CREATE_PARTCP_074.

DATA: lt_participants TYPE ZTI_PARTCP_074,
      ls_participant TYPE ZST_PARTCP_074.

PARAMETERS: p_last TYPE zde_name_074 OBLIGATORY,
            p_first TYPE zde_name_074 OBLIGATORY,
            p_phone TYPE zde_phone_074 OBLIGATORY,
            p_email TYPE zde_email_074 OBLIGATORY,
            p_news AS CHECKBOX.

START-OF-SELECTION.

  DATA: lv_success TYPE char1,
        lv_message TYPE char255.

  CLEAR: lt_participants, ls_participant.

  ls_participant-lastname = p_last.
  ls_participant-firstname = p_first.
  ls_participant-phone = p_phone.
  ls_participant-email = p_email.
  ls_participant-newsletter = COND #( WHEN p_news = abap_true THEN 'X' ELSE ' ' ).

  APPEND ls_participant TO lt_participants.

  CALL FUNCTION 'Z_FM_CREATE_PARTCP_074'
    EXPORTING
      it_participants = lt_participants
    IMPORTING
      ev_success = lv_success
      ev_message = lv_message.

  IF lv_success = 'X'.
    MESSAGE lv_message TYPE 'S'.
  ELSE.
    MESSAGE lv_message TYPE 'E'.
  ENDIF.