*&---------------------------------------------------------------------*
*& Report ZPROG_REGISTER_074
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZPROG_REGISTER_074.

TABLES: ztt_course_074, ztt_partcp_074.

DATA: gt_courses TYPE TABLE OF zde_course_code_074,
      gt_participants TYPE TABLE OF zde_partcp_id_074,
      lt_registrations TYPE ZTI_REGISTRATION_074,
      ls_registration TYPE ZST_REGISTRATION_074.

SELECT-OPTIONS: so_crs FOR ztt_course_074-code  NO INTERVALS OBLIGATORY,
                so_prtcp FOR ztt_partcp_074-partcp_id NO INTERVALS OBLIGATORY.

PARAMETERS: pa_regid TYPE zde_reg_id_074 OBLIGATORY,
            pa_date TYPE zde_date_074,
            pa_paid AS CHECKBOX.

START-OF-SELECTION.

  DATA: lv_success TYPE char1,
        lv_message TYPE char255.

  CLEAR: lt_registrations, ls_registration.

  ls_registration-reg_id = pa_regid.
  ls_registration-course_code = so_crs-low.
  ls_registration-partcp_id = so_prtcp-low.
  ls_registration-reg_date = pa_date.
  ls_registration-payment_status = COND #( WHEN pa_paid = 'X' THEN 'P' ELSE ' ' ).

  APPEND ls_registration TO lt_registrations.

  " Call the function module to register the participant
  CALL FUNCTION 'Z_FM_REGISTER_074'
    EXPORTING
      it_registrations = lt_registrations
    IMPORTING
      ev_success = lv_success
      ev_message = lv_message.

  IF lv_success = 'X'.
    MESSAGE lv_message TYPE 'S'.
  ELSE.
    MESSAGE lv_message TYPE 'E'.
  ENDIF.