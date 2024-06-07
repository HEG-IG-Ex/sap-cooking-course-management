FUNCTION Z_FM_REGISTER_074.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_REGISTRATIONS) TYPE  ZTI_REGISTRATION_074
*"  EXPORTING
*"     VALUE(EV_MESSAGE) TYPE  CHAR255
*"     VALUE(EV_SUCCESS) TYPE  CHAR1
*"----------------------------------------------------------------------

  DATA: lv_count TYPE i,
        ls_registration TYPE ZST_REGISTRATION_074.

  CONSTANTS: c_msg_class            TYPE symsgid VALUE 'ZMSG_REGS_074',
             c_msg_success          TYPE symsgno VALUE '004',
             c_msg_partcp_id_error  TYPE symsgno VALUE '003',
             c_msg_course_code_error TYPE symsgno VALUE '002',
             c_msg_registration_id_error TYPE symsgno VALUE '001',
             c_msg_insert_error     TYPE symsgno VALUE '000'.

  CLEAR: ev_success, ev_message.

  LOOP AT it_registrations INTO ls_registration.

    " Check if registration ID already exists
    SELECT COUNT(*) INTO lv_count FROM ztt_regs_074 WHERE reg_id = ls_registration-reg_id.
    IF lv_count > 0.
      ev_success = ' '.
      MESSAGE ID c_msg_class TYPE 'E' NUMBER c_msg_registration_id_error WITH ls_registration-reg_id INTO ev_message.
      RETURN.
    ENDIF.

    " Check if course code exists
    SELECT COUNT(*) INTO lv_count FROM ztt_course_074 WHERE code = ls_registration-course_code.
    IF lv_count = 0.
      ev_success = ' '.
      MESSAGE ID c_msg_class TYPE 'E' NUMBER c_msg_course_code_error WITH ls_registration-course_code INTO ev_message.
      RETURN.
    ENDIF.

    " Check if participant ID exists
    SELECT COUNT(*) INTO lv_count FROM ztt_partcp_074 WHERE partcp_id = ls_registration-partcp_id.
    IF lv_count = 0.
      ev_success = ' '.
      MESSAGE ID c_msg_class TYPE 'E' NUMBER c_msg_partcp_id_error WITH ls_registration-partcp_id INTO ev_message.
      RETURN.
    ENDIF.

    " Create the registration in the database
    TRY.
        INSERT INTO ztt_regs_074 VALUES ls_registration.
        IF sy-subrc = 0.
          ev_success = 'X'.
          MESSAGE ID c_msg_class TYPE 'S' NUMBER c_msg_success INTO ev_message.
        ELSE.
          ev_success = ' '.
          MESSAGE ID c_msg_class TYPE 'E' NUMBER c_msg_insert_error INTO ev_message.
          RETURN.
        ENDIF.
      CATCH CX_SY_OPEN_SQL_DB INTO DATA(lx_sql_error).
        ev_success = ' '.
        ev_message = lx_sql_error->get_text( ).
        RETURN.
    ENDTRY.

  ENDLOOP.

ENDFUNCTION.