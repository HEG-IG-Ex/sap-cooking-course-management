FUNCTION Z_FM_CREATE_PARTCP_074.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IT_PARTICIPANTS) TYPE ZTI_PARTCP_074
*"  EXPORTING
*"     REFERENCE(EV_SUCCESS) TYPE  CHAR1
*"     REFERENCE(EV_MESSAGE) TYPE  CHAR255
*"----------------------------------------------------------------------

DATA: lv_partcp_id TYPE ZDE_PARTCP_ID_074,
      lv_email_valid TYPE abap_bool,
      ls_partcp TYPE ZST_PARTCP_074,
      lv_message TYPE char255.

CONSTANTS: c_msg_class   TYPE symsgid VALUE 'ZMSG_PARTCP_074',
           c_msg_email_error TYPE symsgno VALUE '000',
           c_msg_success TYPE symsgno VALUE '001',
           c_msg_insert_error TYPE symsgno VALUE '002'.

LOOP AT it_participants INTO ls_partcp.

  " Validate the email first
  CALL FUNCTION 'Z_FM_VALIDATE_EMAIL_074'
    EXPORTING
      iv_email = ls_partcp-email
    IMPORTING
      ev_email_valid = lv_email_valid.

  IF lv_email_valid = abap_false.
    ev_success = ' '.
    MESSAGE ID c_msg_class TYPE 'E' NUMBER c_msg_email_error WITH ls_partcp-email INTO lv_message.
    ev_message = lv_message.
    RETURN.
  ENDIF.

  CALL FUNCTION 'Z_FM_GENERATE_PARTCP_ID_074'
    EXPORTING
      iv_lastname = ls_partcp-lastname
      iv_firstname = ls_partcp-firstname
    IMPORTING
      ev_partcp_id = lv_partcp_id.

  ls_partcp-partcp_id = lv_partcp_id.

  " Create the participant in the database
  TRY.
      INSERT INTO ztt_partcp_074 VALUES ls_partcp.
      IF sy-subrc = 0.
        ev_success = 'X'.
        MESSAGE ID c_msg_class TYPE 'S' NUMBER c_msg_success WITH lv_partcp_id INTO lv_message.
        ev_message = lv_message.
      ELSE.
        ev_success = ' '.
        MESSAGE ID c_msg_class TYPE 'E' NUMBER c_msg_insert_error WITH sy-subrc INTO lv_message.
        ev_message = lv_message.
        RETURN.
      ENDIF.
    CATCH CX_SY_OPEN_SQL_DB INTO DATA(lx_sql_error).
      ev_success = ' '.
      ev_message = lx_sql_error->get_text( ).
      RETURN.
  ENDTRY.

ENDLOOP.

ENDFUNCTION.